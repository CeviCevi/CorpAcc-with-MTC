package com.example.api.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.api.Model.Audio;
import com.example.api.Model.Transcription;
import com.example.api.Repository.TranscriptionRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class TranscriptionService {

    private TranscriptionRepository transcriptionRepository;

    private CorporationService corporationService;

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

    public Transcription getTranscriptionByAudio(UUID audioId){
        return transcriptionRepository.findByAudio(audioId);
    }

    public List<Transcription> getTranscriptionsByUser(UUID creatorId){
        return transcriptionRepository.findByUser(creatorId);
    }

    public List<Transcription> getTranscriptionsByCorp(UUID corpId){
        List<UUID> user = corporationService.getUsersIdByCorpId(corpId);
        List<Transcription> list = new ArrayList<>();
        for (UUID i : user) {
            list.addAll(transcriptionRepository.findByUser(i));
        }
        return list;
    }
}