package com.example.api.Controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.api.Model.Corporation;
import com.example.api.Model.User;
import com.example.api.Model.UserStatus;
import com.example.api.Service.CorporationService;
import com.example.api.Service.UserService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@RestController 
@RequestMapping ("/api/users")
@AllArgsConstructor 


public class UserController {

    private UserService userService;

    private CorporationService corporationService;

    @PostMapping 
    public ResponseEntity<?> createUser (@Valid @RequestBody User UserReq){
        try {
            User  user = userService.createUser(UserReq);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @DeleteMapping("/destroy/{id}")
    public ResponseEntity<?> destroyUser(@PathVariable UUID id){
        try {
            userService.destroyUser(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable UUID id){
        try {
            User user = userService.deleteUser(id);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage()); 
        }
    }

    @PutMapping
    public ResponseEntity<?> updateUser(@RequestBody User userReq){
        try {
            User user = userService.updateUser(userReq);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable UUID id) {
        try {
            User user = userService.getUser(id);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PostMapping("/registration")
    public ResponseEntity<?> registration(@RequestBody User userReq) {
        try {
            User user = userService.reg(userReq);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("Already exist");
            } else {
                return ResponseEntity.ok(user);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
    @PostMapping("/entrance")
    public ResponseEntity<?> entrance(@RequestBody User userReq) {
        try {
            User user = userService.enter(userReq);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            } else {
                return ResponseEntity.ok(user);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/allUsers/{corpId}")
    public ResponseEntity<?> getUsersInCorp(@PathVariable UUID corpId) {
        try {
            List<User> users = userService.getUsersByCorpId(corpId);
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PostMapping("/addToCorp/{corpId}/{email}")
    public ResponseEntity<?> addToCorp(@PathVariable UUID corpId, @PathVariable String email) {
        try {
            User user = userService.setStatus(userService.getUserByEmail(email).getId(), UserStatus.INCORP);
            Corporation corporation = corporationService.createCorporation(new Corporation(userService.getUser(corpId), user));
            return ResponseEntity.ok(corporation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
}