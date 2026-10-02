package com.example.api.Service;

import java.util.UUID;

import org.springframework.stereotype.Service;


import com.example.api.Model.Audio;
import com.example.api.Repository.AudioRepository;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class AudioService {

    private AudioRepository audioRepository;

    public Audio createAudio(Audio audio) {
        return audioRepository.save(audio);
    }

    public boolean deleteAudio(UUID id) {
        try {
            audioRepository.deleteById(id);
            return true;
        } catch (Exception e) {
            return false;   
        }
    }

    public Audio updateAudio(Audio audio) {
        return audioRepository.save(audio);
    }

    public Audio getAudio(UUID id) {

    return audioRepository.findById(id).get();

}
}

