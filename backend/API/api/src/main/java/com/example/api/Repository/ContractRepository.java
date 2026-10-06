package com.example.api.Repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Component;

import com.example.api.Model.Audio;
import com.example.api.Model.Contract;

@Component
public interface ContractRepository extends JpaRepository<Contract, UUID>{

    @Query(value = "SELECT * FROM contract WHERE audio_id = :audio_id", nativeQuery = true)
    Contract findByAudio(@Param("corp_id") UUID audio_id);

    @Query(value = "SELECT * FROM contract WHERE creator_id = :creator_id", nativeQuery = true)
    List<Contract> findByUser(@Param("creator_id") UUID creator_id);
}