package com.example.api.Repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Component;

import com.example.api.Model.Corporation;

@Component
public interface CorporationRepository extends JpaRepository<Corporation, UUID>{

    @Query(value = "SELECT * FROM corporation WHERE corp_id = :corp_id AND user_id = :user_id", nativeQuery = true)
    Corporation findByUserId(@Param("corp_id") UUID corp_id, @Param("user_id") UUID userId);

    @Query(value = "SELECT user_id FROM corporation WHERE corp_id = :corp_id", nativeQuery = true)
    List<UUID> getUserIdByCorpId (@Param("corp_id") UUID corp_id);

}