package com.example.api.Controller;

import java.util.UUID;

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

import com.example.api.Model.Transcription;
import com.example.api.Service.TranscriptionService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@RestController 
@RequestMapping ("/api/transcriptions")
@AllArgsConstructor 


public class TranscriptionController {
    @Autowired 
    private TranscriptionService transcriptionService;

    @PostMapping 
    public ResponseEntity<?> createTranscription (@Valid @RequestBody Transcription TranscriptionReq){
        
        Transcription  transcription = transcriptionService.createTranscription(TranscriptionReq);

        return ResponseEntity.status(HttpStatus.OK).body(transcription);

    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable UUID id) {

        transcriptionService.deleteTranscription(id);

        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTranscription(
            @PathVariable UUID id,
            @RequestBody Transcription transcriptionReq
    ) {

        transcriptionReq.setId(id);

        Transcription transcription = transcriptionService.updateTranscription(transcriptionReq);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(transcription);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTranscription(@PathVariable UUID id) {

        Transcription transcription = transcriptionService.getTranscription(id);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(transcription);
    }

}
