// File: backend/src/main/java/com/example/demo/HelloController.java

package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/api")
    public String hello() {
        return "Hello from Backend";
    }
}
