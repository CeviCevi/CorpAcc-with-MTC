package com.example.api.Controller;

import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.api.Model.Audio;
import com.example.api.Model.Contract;
import com.example.api.Model.Transcription;
import com.example.api.Model.User;
import com.example.api.Service.AudioService;
import com.example.api.Service.ContractService;
import com.example.api.Service.FileService;
import com.example.api.Service.TranscriptionService;
import com.example.api.Service.UserService;
import com.example.api.Service.WebSocketHandler;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.web.bind.annotation.RequestParam;

@Slf4j 
@RestController 
@RequestMapping ("/api/audios")
@AllArgsConstructor
public class AudioController {

    private AudioService audioService;
    private UserService userService;
    private TranscriptionService transcriptionService;
    private ContractService contractService;
    private FileService fileService;
    private WebSocketHandler webSocketHandler;

    @PostMapping 
    public ResponseEntity<?> createAudio (@Valid @RequestBody Audio AudioReq){
        try {
            Audio  audio = audioService.createAudio(AudioReq);
            return ResponseEntity.ok(audio);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAudio(@PathVariable UUID id) {
        try {
            audioService.deleteAudio(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PutMapping
    public ResponseEntity<?> updateAudio(@RequestBody Audio audioReq)
    {
        try {
            Audio audio = audioService.updateAudio(audioReq);
            return ResponseEntity.ok(audio);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getAudio(@PathVariable UUID id) {
        try {
            Audio audio = audioService.getAudio(id);
            return ResponseEntity.ok(audio);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
        
    }

    @GetMapping("/user/{id}")
    public ResponseEntity<?> getAudiosByUser(@PathVariable UUID creatorId) {
        try {
            List<Audio> list = audioService.getAudiosByUser(creatorId);
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
    @GetMapping("/corp/{id}")
    public ResponseEntity<?> getAudiosByCorp(@PathVariable UUID corpId) {
        try {
            List<Audio> list = audioService.getAudiosByCorp(corpId);
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PostMapping(value = "/save/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> saveFile(@PathVariable("id") UUID id,@RequestParam("file") MultipartFile file) {
        try {
            User user = userService.getUser(id);
            Audio audio = audioService.createAudio(new Audio(user, "name"));

            String link = fileService.saveAudio(file);
            audio.setLink(link);
            audio = audioService.updateAudio(audio);

            transcriptionService.createTranscription(new Transcription(user, audio, "name"));
            contractService.createContract(new Contract(user, audio, "name"));

            webSocketHandler.sendUuid(audio.getId());
            log.info("websocket task sent: audioId={}, elapsedMs={}",audio.getId());

            return ResponseEntity.status(HttpStatus.CREATED).body(audio);
        } catch (Exception e) {
            log.error("audio upload failed: creatorId={}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/get/{id}")
    public ResponseEntity<?> downloadFile(@PathVariable UUID id) {
        try {
            Resource file = fileService.getAudio(audioService.getAudio(id).getLink());
            //Resource file = fileService.getAudio("audios/" + id);
            return ResponseEntity.ok()
                .header("Content-Disposition",
                        "attachment; filename=\"" + id + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(file);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/retry/{id}")
    public ResponseEntity<?> getMethodName(@PathVariable UUID id) {
        try {
            webSocketHandler.sendUuid(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
    
    
}
