package com.example.api.Model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "contract")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Contract {

    public Contract (User user, Audio audio, String name){
        this.audio = audio;
        this.creator = user;
        this.name = name;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "creator_id", nullable = false)
    private User creator;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "audio_id", nullable = false)
    private Audio audio;

    @Column(name = "link", unique = true)
    private String link;

    @Column(name = "description")
    private String description = "text";

    @Column(name = "name", nullable = false)
    private String name = "text";

    @Column(name = "x")
    private String x = "text";

    @Column(name = "y")
    private String y = "text";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
        if (x == null) x = "text";
        if (y == null) y = "text";
    }
}
