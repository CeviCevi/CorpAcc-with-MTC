package com.example.api.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.api.Model.Audio;
import com.example.api.Model.Contract;
import com.example.api.Model.Transcription;
import com.example.api.Repository.ContractRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class ContractService {

    private ContractRepository contractRepository;

    private CorporationService corporationService;

    public Contract createContract(Contract contract) {
        return contractRepository.save(contract);
    }

    public void deleteContract(UUID id) {
        contractRepository.deleteById(id);
    }

    public Contract updateContract(Contract contract) {
        return contractRepository.save(contract);
    }

    public Contract getContract(UUID id) {
        return contractRepository.findById(id).get();
    }

    public Contract getContractByAudio(UUID audioId){
        return contractRepository.findByAudio(audioId);
    }

    public List<Contract> getContractsByUser(UUID creatorId){
        return contractRepository.findByUser(creatorId);
    }

    public List<Contract> getContractsByCorp(UUID corpId){
        List<UUID> user = corporationService.getUsersIdByCorpId(corpId);
        List<Contract> list = new ArrayList<>();
        for (UUID i : user) {
            list.addAll(contractRepository.findByUser(i));
        }
        return list;
    }
}