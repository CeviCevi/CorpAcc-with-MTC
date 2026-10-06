package com.example.api.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;


import com.example.api.Model.User;
import com.example.api.Model.UserStatus;
import com.example.api.Repository.UserRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class UserService {

    private UserRepository userRepository;

    private CorporationService corporationService;

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void destroyUser(UUID id) {
        userRepository.deleteById(id);
    }

    public User setStatus(UUID id, UserStatus status){
        User user = userRepository.findById(id).get();
        user.setStatus(status);
        return userRepository.save(user);
    }

    public User deleteUser(UUID id){
        return setStatus(id, UserStatus.DELETED);
    }

    public User getUser(UUID id) {
        return userRepository.findById(id).get();
    }

    public User getUserByEmail(String email){
        return userRepository.findByEmail(email);
    }

    public User reg(User userReq){
        User user = userRepository.findByEmail(userReq.getEmail());
        if (user != null) {
            return null;
        } else {
            return userRepository.save(user);
        }
    }

    public User enter(User userReq){
        User user = userRepository.findByEmail(userReq.getEmail());
        if (user != null && user.getPassword() == userReq.getPassword()){
            return user;
        } else {
            return null;
        }
    }

    public List<User> getUsersByCorpId(UUID corpId){
        List<UUID> userId = corporationService.getUsersIdByCorpId(corpId);
        List<User> users = new ArrayList<>();
        for (UUID id : userId) {
            users.add(userRepository.findById(id).get());
        }
        return users;
    }
}
