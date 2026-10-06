package com.example.api.Controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.api.Model.Audio;
import com.example.api.Model.Transcription;
import com.example.api.Service.TranscriptionService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;


@RestController 
@RequestMapping ("/api/transcriptions")
@AllArgsConstructor 


public class TranscriptionController {

    private TranscriptionService transcriptionService;

    @PostMapping 
    public ResponseEntity<?> createTranscription (@Valid @RequestBody Transcription TranscriptionReq){
        try {
            Transcription  transcription = transcriptionService.createTranscription(TranscriptionReq);
            return ResponseEntity.ok(transcription);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable UUID id) {
        try {
            transcriptionService.deleteTranscription(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTranscription(@RequestBody Transcription transcriptionReq) {
        try {
            Transcription transcription = transcriptionService.updateTranscription(transcriptionReq);
            return ResponseEntity.ok(transcription);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTranscription(@PathVariable UUID id) {
        try {
            Transcription transcription = transcriptionService.getTranscription(id);
            return ResponseEntity.ok(transcription);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/audio/{id}")
    public ResponseEntity<?> getTranscriptionByAudio(@PathVariable UUID audioId) {
        try {
            Transcription transcription = transcriptionService.getTranscriptionByAudio(audioId);
            return ResponseEntity.ok(transcription);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
    @DeleteMapping("/audio/{id}")
    public ResponseEntity<?> deleteTranscriptionByAudio(@PathVariable UUID audioId) {
        try {
            transcriptionService.deleteTranscription(transcriptionService.getTranscriptionByAudio(audioId).getId());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/user/{id}")
    public ResponseEntity<?> getContractsByUser(@PathVariable UUID creatorId) {
        try {
            List<Transcription> list = transcriptionService.getTranscriptionsByUser(creatorId);
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
    @GetMapping("/corp/{id}")
    public ResponseEntity<?> getContractsByCorp(@PathVariable UUID corpId) {
        try {
            List<Transcription> list = transcriptionService.getTranscriptionsByCorp(corpId);
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
