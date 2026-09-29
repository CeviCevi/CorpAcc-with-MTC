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

import com.example.api.Model.Contract;
import com.example.api.Repository.ContractRepository;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor 
public class ContractService {

    private ContractRepository contractRepository;

    public Contract createContract(Contract contract) {
        return contractRepository.save(contract);
    }

    public Contract deleteContract(Long id) {
    contractRepository.deleteById(id);
    }

    public Contract updateContract(Contract contract) {
        return contractRepository.save(contract);
    }

    public Contract getContract(Long id) {

    return contractRepository.findById(id).get();

}
}