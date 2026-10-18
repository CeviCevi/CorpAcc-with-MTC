package com.example.api.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;


import com.example.api.Model.Audio;
import com.example.api.Repository.AudioRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class AudioService {

    private AudioRepository audioRepository;
    private CorporationService corporationService;

    public Audio createAudio(Audio audio) {
        return audioRepository.save(audio);
    }

    public boolean deleteAudio(UUID id) {
        try {
            audioRepository.deleteById(id);
            return true;
        } catch (Exception e) {
            throw e; 
        }
    }

    public Audio updateAudio(Audio audioReq) {
        if (audioReq.getId() == null) {
            throw new IllegalArgumentException("Для обновления нужен id аудио");
        }

        Audio audio = audioRepository.findById(audioReq.getId())
                .orElseThrow(() -> new EntityNotFoundException(
                    "Audio not found: " + audioReq.getId()
            ));

        audio.setName(audioReq.getName());
        audio.setDescription(audioReq.getDescription());

    return audioRepository.save(audio);
}

    public Audio getAudio(UUID id) {
        return audioRepository.findById(id).get();
    }

    public List<Audio> getAudiosByUser(UUID creatorId){
        return audioRepository.findByUser(creatorId);
    }

    public List<Audio> getAudiosByCorp(UUID corpId){
        List<UUID> user = corporationService.getUsersIdByCorpId(corpId);
        List<Audio> list = new ArrayList<>();
        for (UUID i : user) {
            list.addAll(audioRepository.findByUser(i));
        }
        return list;
    }
}

