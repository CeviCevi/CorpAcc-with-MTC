package com.example.api.Service;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import tools.jackson.databind.ObjectMapper;

@Service
public class FileService {

    private static final String AUDIO_PREFIX = "audios/";
    private static final String TRANSCRIPTION_PREFIX = "transcriptions/";
    private static final String CONTRACT_PREFIX = "contracts/";

    private final Path audioDirectory;
    private final Path transcriptionDirectory;
    private final Path contractDirectory;

    private final ObjectMapper objectMapper;

    public FileService(
            @Value("${app.storage.root-directory:/data/uploads}") String rootDirectory, ObjectMapper objectMapper) {

        Path storageRoot = Path.of(rootDirectory)
                .toAbsolutePath()
                .normalize();

        this.audioDirectory = storageRoot.resolve("audios");
        this.transcriptionDirectory = storageRoot.resolve("transcriptions");
        this.contractDirectory = storageRoot.resolve("contracts");
        this.objectMapper = objectMapper;

        try {
            Files.createDirectories(audioDirectory);
            Files.createDirectories(transcriptionDirectory);
            Files.createDirectories(contractDirectory);
        } catch (IOException e) {
            throw new IllegalStateException("Не удалось создать папки для файлов", e);
        }
    }

    public String saveAudio(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Загружаемый файл пустой");
        }

        UUID fileId = UUID.randomUUID();
        Path destination = audioDirectory.resolve(fileId.toString());

        try {
            file.transferTo(destination);
            return AUDIO_PREFIX + fileId;
        } catch (IOException | IllegalStateException e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Не удалось сохранить", e);
        }
    }

    public Resource getAudio(String link) {
        if (link == null || !link.startsWith(AUDIO_PREFIX)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Некорректная ссылка на файл");
        }

        String fileId = link.substring(AUDIO_PREFIX.length());

        try {
            UUID uuid = UUID.fromString(fileId);
            Path filePath = audioDirectory.resolve(uuid.toString()).normalize();

            if (!filePath.startsWith(audioDirectory)) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Некорректный путь к файлу");
            }

            Resource resource = new UrlResource(filePath.toUri());

            if (!resource.exists() || !resource.isReadable()) {
                throw new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Файл не найден");
            }

            return resource;
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Некорректный идентификатор файла", e);
        } catch (MalformedURLException e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Не удалось прочитать файл", e);
        }
    }

    public String saveTranscription(String text) {
        return saveText(text, transcriptionDirectory, TRANSCRIPTION_PREFIX, ".txt");
    }

    public String getTranscription(String link) {
        return getText(link, transcriptionDirectory, TRANSCRIPTION_PREFIX, ".txt");
    }

    public <T> String saveContract(T contract) {
        try {
            String json = objectMapper.writeValueAsString(contract);
            return saveText(json, contractDirectory, CONTRACT_PREFIX, ".json");
        } catch (Exception e) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Не удалось преобразовать контракт в JSON", e);
        }
    }

    public <T> T getContract(String link, Class<T> type) {
        String json = getText(link, contractDirectory, CONTRACT_PREFIX, ".json");

        try {
            return objectMapper.readValue(json, type);
        } catch (Exception e) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Не удалось прочитать JSON контракта", e);
        }
    }

    private String saveText(
        String text, Path directory, String linkPrefix, String extension) {

        if (text == null || text.isBlank()) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Содержимое файла пустое");
        }

        UUID fileId = UUID.randomUUID();
        Path destination = directory.resolve(fileId + extension);

        try {
            Files.writeString(destination, text, StandardCharsets.UTF_8);
            return linkPrefix + fileId;
        } catch (IOException e) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR, "Не удалось сохранить файл", e);
        }
    }

    private String getText(
            String link, Path directory, String linkPrefix, String extension) {

        UUID uuid = parseId(link, linkPrefix);
        Path filePath = directory.resolve(uuid + extension).normalize();

        if (!filePath.startsWith(directory.normalize())) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Некорректный путь к файлу");
        }   

        try {
            if (!Files.isRegularFile(filePath) || !Files.isReadable(filePath)) {
                throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Файл не найден");
            }

            return Files.readString(filePath, StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new ResponseStatusException(
                HttpStatus.INTERNAL_SERVER_ERROR, "Не удалось прочитать файл", e);
        }
    }   

    private UUID parseId(String link, String linkPrefix) {
        if (link == null || !link.startsWith(linkPrefix)) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Некорректная ссылка на файл");
        }

        try {
            return UUID.fromString(link.substring(linkPrefix.length()));
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST, "Некорректный идентификатор файла", e);
        }
    }
}
