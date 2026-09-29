package com.example.api.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.api.Model.User;
import com.example.api.Service.UserService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@RestController 
@RequestMapping ("/api/users")
@AllArgsConstructor 


public class UserController {
    @Autowired 
    private UserService userService;

    @PostMapping 
    
    public ResponseEntity<?> createUser (@Valid @RequestBody User UserReq){
        
        User  user = userService.createUser(UserReq);

        return ResponseEntity.status(HttpStatus.OK).body(user);


    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {

        userService.deleteUser(id);

        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable Long id,
            @RequestBody User userReq
    ) {

        userReq.setId(id);

        User user = userService.updateUser(userReq);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(user);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {

        User user = userService.getUser(id);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(user);
    }

}