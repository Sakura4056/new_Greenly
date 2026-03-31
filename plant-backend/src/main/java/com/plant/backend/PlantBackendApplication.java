package com.plant.backend;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * @author Sun
 */
@EnableScheduling
@SpringBootApplication
@MapperScan("com.plant.backend.mapper")
public class PlantBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlantBackendApplication.class, args);
    }

}
