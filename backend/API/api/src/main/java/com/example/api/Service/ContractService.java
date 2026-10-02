package com.example.api.Service;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.api.Model.Contract;
import com.example.api.Repository.ContractRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class ContractService {

    private ContractRepository contractRepository;

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
}