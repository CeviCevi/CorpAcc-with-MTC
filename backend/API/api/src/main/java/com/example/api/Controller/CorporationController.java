package com.example.api.Controller;

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

import com.example.api.Model.Corporation;
import com.example.api.Service.CorporationService;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;


@RestController 
@RequestMapping ("/api/corporations")
@AllArgsConstructor
public class CorporationController {

    private CorporationService corporationService;

    @PostMapping 
    public ResponseEntity<?> createCorporation (@Valid @RequestBody Corporation corporationReq){
        try {
            Corporation corporation = corporationService.createCorporation(corporationReq);
            return ResponseEntity.ok(corporation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCorporation(@PathVariable UUID id) {
        try {
            corporationService.deleteCorporation(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PutMapping
    public ResponseEntity<?> updateCorporation(@RequestBody Corporation corporationReq)
    {
        try {
            Corporation corporation = corporationService.updateCorporation(corporationReq);
            return ResponseEntity.ok(corporation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getCorporation(@PathVariable UUID id) {
        try {
            Corporation corporation = corporationService.getCorporation(id);
            return ResponseEntity.ok(corporation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
