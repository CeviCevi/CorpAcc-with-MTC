package com.example.api.Service;

import java.util.UUID;

import org.springframework.stereotype.Service;


import com.example.api.Model.User;
import com.example.api.Repository.UserRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class UserService {

    private UserRepository userRepository;

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(UUID id) {
         userRepository.deleteById(id);
    }

    public User getUser(UUID id) {

    return userRepository.findById(id).get();

}
}
