package com.example.api.Service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.api.Model.CorpStatus;
import com.example.api.Model.Corporation;
import com.example.api.Model.UserStatus;
import com.example.api.Repository.CorporationRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class CorporationService {

    private CorporationRepository corporationRepository;

    public Corporation createCorporation(Corporation corporation) {
        return corporationRepository.save(corporation);
    }

    public void deleteCorporation(UUID id) {
        corporationRepository.deleteById(id);
    }

    public Corporation updateCorporation(Corporation corporation) {
        return corporationRepository.save(corporation);
    }

    public Corporation getCorporation(UUID id) {
        return corporationRepository.findById(id).get();
    }

    public Corporation setStatus(UUID corpId, UUID userId, CorpStatus status){
        Corporation corporation = corporationRepository.findByUserId(corpId, userId);
        corporation.setStatus(status);
        return corporationRepository.save(corporation);
    }

    public Corporation deleteFromCorporation(UUID corpId, UUID userId){
        return setStatus(corpId, userId, CorpStatus.DELETED);
    }

    public List<UUID> getUsersIdByCorpId (UUID corpId){
        return corporationRepository.getUserIdByCorpId(corpId);
    }
}