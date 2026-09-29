package com.example.api.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.api.Model.Audio;
import com.example.api.Service.AudioService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@RestController 
@RequestMapping ("/api/audios")
@AllArgsConstructor 


public class AudioController {
    @Autowired 
    private AudioService audioService;

    @PostMapping 
    public ResponseEntity<?> createAudio (@Valid @RequestBody Audio AudioReq){
        
        Audio  audio = audioService.createAudio(AudioReq);

        return ResponseEntity.status(HttpStatus.OK).body(audio);

    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {

        audioService.deleteAudio(id);

        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAudio(
            @PathVariable Long id,
            @RequestBody Audio audioReq
    ) {

        audioReq.setId(id);

        Audio audio = audioService.updateAudio(audioReq);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(audio);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getAudio(@PathVariable Long id) {

        Audio audio = audioService.getAudio(id);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(audio);
    }

}
