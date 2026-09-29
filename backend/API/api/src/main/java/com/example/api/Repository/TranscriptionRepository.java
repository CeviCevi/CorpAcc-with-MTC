package com.example.api.Repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Component;

import com.example.api.Model.Transcription;

@Component
public interface TranscriptionRepository extends JpaRepository<Transcription, UUID>{

}