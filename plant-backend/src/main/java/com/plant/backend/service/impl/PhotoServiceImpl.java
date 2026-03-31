package com.plant.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.plant.backend.dto.PhotoDTO;
import com.plant.backend.entity.PlantPhoto;
import com.plant.backend.exception.BusinessException;
import com.plant.backend.mapper.PlantPhotoMapper;
import com.plant.backend.mapper.OfficialPlantMapper;
import com.plant.backend.service.PhotoService;
import com.plant.backend.util.ResultCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PhotoServiceImpl extends ServiceImpl<PlantPhotoMapper, PlantPhoto> implements PhotoService {

    @Value("${app.file-upload-path}")
    private String uploadPath;

    private final OfficialPlantMapper officialPlantMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PlantPhoto upload(PhotoDTO.UploadRequest request, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ResultCode.PARAM_ERROR.getCode(), "文件为空");
        }

        boolean isChunked = request.getChunks() != null && request.getChunks() > 1;
        File finalFile = null;

        try {
            if (isChunked) {
                finalFile = handleChunk(file, request);
                if (finalFile == null) {
                    return null;
                }
            } else {
                String fileName = UUID.randomUUID().toString().replace("-", "") + "_" + request.getFileName();
                File dest = new File(uploadPath, fileName);
                if (!dest.isAbsolute()) {
                    dest = dest.getAbsoluteFile();
                }
                FileUtils.forceMkdirParent(dest);
                file.transferTo(dest);
                finalFile = dest;
            }

            LocalDateTime captureTime = extractCaptureTime(finalFile);

            PlantPhoto photo = new PlantPhoto();
            photo.setUserId(request.getUserId());
            photo.setPlantId(request.getPlantId());
            photo.setPlantSource(request.getPlantSource());
            photo.setIsPublic(request.getIsPublic() == null ? 0 : request.getIsPublic());
            photo.setRemarks(request.getRemarks());
            photo.setFilePath(finalFile.getAbsolutePath());
            photo.setUrl("/uploads/" + finalFile.getName());
            photo.setCaptureTime(captureTime != null ? captureTime : LocalDateTime.now());

            save(photo);
            return photo;

        } catch (IOException e) {
            log.error("文件上传失败", e);
            throw new BusinessException(ResultCode.SYSTEM_ERROR.getCode(), "文件上传失败");
        }
    }

    private File handleChunk(MultipartFile file, PhotoDTO.UploadRequest request) throws IOException {
        String tempDirName = request.getUserId() + "_" + request.getFileName();
        File tempDir = new File(uploadPath + "/temp/" + tempDirName);
        FileUtils.forceMkdir(tempDir);

        File chunkFile = new File(tempDir, String.valueOf(request.getChunk()));
        if (!chunkFile.isAbsolute()) {
            chunkFile = chunkFile.getAbsoluteFile();
        }
        file.transferTo(chunkFile);

        if (tempDir.listFiles().length == request.getChunks()) {
            return mergeChunks(tempDir, request.getFileName());
        }

        return null;
    }

    private File mergeChunks(File tempDir, String originalFileName) throws IOException {
        String fileName = UUID.randomUUID().toString().replace("-", "") + "_" + originalFileName;
        File destFile = new File(uploadPath, fileName);

        try (var outputStream = new java.io.FileOutputStream(destFile, true)) {
            for (int i = 0; i < tempDir.listFiles().length; i++) {
                File chunk = new File(tempDir, String.valueOf(i));
                FileUtils.copyFile(chunk, outputStream);
            }
        }

        FileUtils.deleteDirectory(tempDir);
        return destFile;
    }

    private LocalDateTime extractCaptureTime(File file) {
        try {
            Metadata metadata = ImageMetadataReader.readMetadata(file);
            ExifSubIFDDirectory directory = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
            if (directory != null) {
                Date date = directory.getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL);
                if (date != null) {
                    return LocalDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault());
                }
            }
        } catch (Exception e) {
            log.warn("从{}中提取 EXIF 信息失败", file.getName());
        }
        return null;
    }

    @Override
    public Page<PlantPhoto> queryPhotos(PhotoDTO.Query query, Long currentUserId, String currentRole) {
        Page<PlantPhoto> page = new Page<>(query.getPageNum(), query.getPageSize());
        LambdaQueryWrapper<PlantPhoto> wrapper = new LambdaQueryWrapper<>();

        if (!"ADMIN".equals(currentRole)) {
            if (query.getUserId() != null && !query.getUserId().equals(currentUserId)) {
                throw new BusinessException(ResultCode.FORBIDDEN);
            }
            if (query.getUserId() == null) {
                query.setUserId(currentUserId);
            }
        }

        if (query.getUserId() != null)
            wrapper.eq(PlantPhoto::getUserId, query.getUserId());
        if (query.getPlantId() != null)
            wrapper.eq(PlantPhoto::getPlantId, query.getPlantId());
        if (query.getPlantSource() != null)
            wrapper.eq(PlantPhoto::getPlantSource, query.getPlantSource());
        if (query.getIsPublic() != null)
            wrapper.eq(PlantPhoto::getIsPublic, query.getIsPublic());

        if (org.apache.commons.lang3.StringUtils.isNotBlank(query.getKeyword()))
            wrapper.like(PlantPhoto::getRemarks, query.getKeyword());
        if (query.getStartDate() != null)
            wrapper.ge(PlantPhoto::getCaptureTime, query.getStartDate().atStartOfDay());
        if (query.getEndDate() != null)
            wrapper.le(PlantPhoto::getCaptureTime, query.getEndDate().atTime(23, 59, 59));

        wrapper.orderByDesc(PlantPhoto::getCaptureTime);

        Page<PlantPhoto> result = page(page, wrapper);

        if (result.getRecords() != null && !result.getRecords().isEmpty()) {
            for (PlantPhoto photo : result.getRecords()) {
                if ("OFFICIAL".equals(photo.getPlantSource())) {
                    com.plant.backend.entity.OfficialPlant p = officialPlantMapper.selectById(photo.getPlantId());
                    if (p != null) {
                        photo.setPlantName(p.getName());
                    }
                }
            }
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PlantPhoto updatePhoto(PhotoDTO.UpdateRequest request, Long userId) {
        PlantPhoto photo = getById(request.getId());
        if (photo == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "照片不存在");
        }
        if (!photo.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }

        if (request.getRemarks() != null) {
            photo.setRemarks(request.getRemarks());
        }
        if (request.getIsPublic() != null) {
            photo.setIsPublic(request.getIsPublic());
        }

        updateById(photo);
        return photo;
    }

    @Override
    public File getPhotoFile(String filename) {
        if (filename.contains(".."))
            return null;
        return new File(uploadPath, filename);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deletePhoto(Long id, Long userId) {
        PlantPhoto photo = getById(id);
        if (photo == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "照片不存在");
        }
        if (!photo.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }

        if (photo.getFilePath() != null) {
            File file = new File(photo.getFilePath());
            if (file.exists()) {
                file.delete();
            }
        }

        removeById(id);
    }
}
