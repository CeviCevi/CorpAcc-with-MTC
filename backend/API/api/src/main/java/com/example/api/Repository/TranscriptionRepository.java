package com.example.api.Repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Component;

import com.example.api.Model.Transcription;

@Component
public interface TranscriptionRepository extends JpaRepository<Transcription, UUID>{

    @Query(value = "SELECT * FROM transcription WHERE audio_id = :audio_id", nativeQuery = true)
    Transcription findByAudio(@Param("corp_id") UUID audio_id);

    @Query(value = "SELECT * FROM transcription WHERE creator_id = :creator_id", nativeQuery = true)
    List<Transcription> findByUser(@Param("creator_id") UUID creator_id);
}