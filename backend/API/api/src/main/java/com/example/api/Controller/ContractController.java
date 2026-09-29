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

import com.example.api.Model.Contract;
import com.example.api.Service.ContractService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;

@RestController 
@RequestMapping ("/api/contracts")
@AllArgsConstructor 


public class ContractController {
    @Autowired 
    private ContractService contractService;

    @PostMapping 
    public ResponseEntity<?> createContract (@Valid @RequestBody Contract ContractReq){
        
        Contract  contract = contractService.createContract(ContractReq);

        return ResponseEntity.status(HttpStatus.OK).body(contract);

    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteContract(@PathVariable Long id) {

        contractService.deleteContract(id);

        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateContract(
            @PathVariable Long id,
            @RequestBody Contract contractReq
    ) {

        contractReq.setId(id);

        Contract contract = contractService.updateContract(contractReq);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(contract);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getContract(@PathVariable Long id) {

        Contract contract = contractService.getContract(id);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(contract);
    }

}

