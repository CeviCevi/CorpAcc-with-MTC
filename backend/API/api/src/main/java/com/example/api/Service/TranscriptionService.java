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

import com.example.api.Model.Transcription;
import com.example.api.Repository.TranscriptionRepository;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class TranscriptionService {

    private TranscriptionRepository transcriptionRepository;

    public Transcription createTranscription(Transcription transcription) {
        return transcriptionRepository.save(transcription);
    }

    public Transcription deleteTranscription(Long id) {
    transcriptionRepository.deleteById(id);
    }

    public Transcription updateTranscription(Transcription transcription) {
        return transcriptionRepository.save(transcription);
    }

    public Transcription getTranscription(Long id) {

    return transcriptionRepository.findById(id).get();

}
}