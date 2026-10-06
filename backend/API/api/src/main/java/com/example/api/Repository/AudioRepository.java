package com.example.api.Repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Component;

import com.example.api.Model.Audio;

@Component
public interface AudioRepository extends JpaRepository<Audio, UUID>{

    @Query(value = "SELECT * FROM audio WHERE creator_id = :creator_id", nativeQuery = true)
    List<Audio> findByUser(@Param("creator_id") UUID creator_id);
}