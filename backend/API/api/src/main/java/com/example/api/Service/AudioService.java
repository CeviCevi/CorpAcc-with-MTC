package com.example.api.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.api.Model.Audio;
import com.example.api.Repository.AudioRepository;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class AudioService {

    private AudioRepository audioRepository;

    public Audio createAudio(Audio audio) {
        return audioRepository.save(audio);
    }

    public Audio deleteAudio(Long id) {
    audioRepository.deleteById(id);
    }

    public Audio updateAudio(Audio audio) {
        return audioRepository.save(audio);
    }

    public Audio getAudio(Long id) {

    return audioRepository.findById(id).get();

}
}

