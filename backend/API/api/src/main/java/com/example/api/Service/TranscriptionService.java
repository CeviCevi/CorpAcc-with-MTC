package com.example.api.Service;

import java.util.UUID;

import org.springframework.stereotype.Service;


import com.example.api.Model.Transcription;
import com.example.api.Repository.TranscriptionRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class TranscriptionService {

    private TranscriptionRepository transcriptionRepository;

    public Transcription createTranscription(Transcription transcription) {
        return transcriptionRepository.save(transcription);
    }

    public void deleteTranscription(UUID id) {
        transcriptionRepository.deleteById(id);
    }

    public Transcription updateTranscription(Transcription transcription) {
        return transcriptionRepository.save(transcription);
    }

    public Transcription getTranscription(UUID id) {

    return transcriptionRepository.findById(id).get();

}
}