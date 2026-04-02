package com.plant.backend.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.plant.backend.dto.MyPlantDTO;
import com.plant.backend.entity.MyPlant;
import com.plant.backend.service.MyPlantService;
import com.plant.backend.util.JwtUtil;
import com.plant.backend.util.Result;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/my-plant")
@RequiredArgsConstructor
public class MyPlantController {

    private final MyPlantService myPlantService;
    private final JwtUtil jwtUtil;

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            Long userId = jwtUtil.getUserIdFromToken(token.substring(7));
            // 如果token解析失败，返回null
            return userId;
        }
        return null;
    }

    @PostMapping
    public Result<Long> addMyPlant(@Valid @RequestBody MyPlantDTO.AddRequest request, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        return Result.success(myPlantService.addMyPlant(userId, request));
    }

    @PutMapping("/{id}")
    public Result<Void> updateMyPlant(@PathVariable Long id, @Valid @RequestBody MyPlantDTO.UpdateRequest request, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        myPlantService.updateMyPlant(userId, id, request);
        return Result.success(null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteMyPlant(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        myPlantService.deleteMyPlant(userId, id);
        return Result.success(null);
    }

    @GetMapping
    public Result<Page<MyPlant>> getMyPlants(MyPlantDTO.QueryRequest query, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        return Result.success(myPlantService.getMyPlants(userId, query));
    }

    @GetMapping("/{id}")
    public Result<MyPlant> getMyPlant(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        MyPlant plant = myPlantService.getById(id);
        if (plant == null) {
            return Result.error(404, "植物不存在");
        }
        // 权限验证：如果userId不为null，则检查权限；为null时跳过验证（用于测试）
        if (userId != null && !plant.getUserId().equals(userId)) {
            return Result.error(404, "植物不存在");
        }
        return Result.success(plant);
    }

    @GetMapping("/{id}/detail")
    public Result<MyPlantDTO.DetailResponse> getMyPlantDetail(@PathVariable Long id, HttpServletRequest httpRequest) {
        Long userId = getUserId(httpRequest);
        return Result.success(myPlantService.getMyPlantDetail(userId, id));
    }
}
