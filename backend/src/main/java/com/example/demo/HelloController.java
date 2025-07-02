package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    // Root URL mapping
    @GetMapping("/")
    public String root() {
        return "Backend is running";
    }

    // /api mapping
    @GetMapping("/api")
    public String hello() {
        return "Hello from Backend";
    }
}
