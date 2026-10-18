package com.example.api.Repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Component;

import com.example.api.Model.User;

@Component
public interface UserRepository extends JpaRepository<User, UUID>{

    @Query(value = "SELECT * FROM users WHERE email = :email", nativeQuery = true)
    User findByEmail(@Param("email") String email);

}