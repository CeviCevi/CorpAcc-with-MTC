package com.example.api.Service;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import lombok.extern.slf4j.Slf4j;

@Slf4j 
@Component
public class WebSocketHandler extends TextWebSocketHandler {

    private final AtomicReference<WebSocketSession> webSocketSession = new AtomicReference<>();

    @Override
    public void handleTransportError(WebSocketSession session,Throwable exception) throws Exception {
        webSocketSession.compareAndSet(session, null);
        if (session.isOpen()) {session.close();}
        System.err.println("Error WebSocket: " + exception.getMessage());
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        webSocketSession.set(session);
        log.info("websocket connected: sessionId={}", session.getId());
    }

    public void sendUuid(UUID id) {
        WebSocketSession session = webSocketSession.get();

        if (session == null || !session.isOpen()) {
            log.warn("cannot send task: audioId={}, websocket unavailable", id);
            webSocketSession.compareAndSet(session, null);
            throw new IllegalStateException("Not connected");
        }

        String json = "{\"id\":\"" + id + "\"}";

        try {
            synchronized (session) {
                log.info("sending websocket task: audioId={}, sessionId={}", id, session.getId());
                session.sendMessage(new TextMessage(json));
            }
        } catch (Exception e) {
            log.error("websocket send failed: audioId={}, sessionId={}", id, session.getId(), e);
            webSocketSession.compareAndSet(session, null);
            throw new IllegalStateException("Error while sending UUID", e);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        log.info("websocket message received: sessionId={}, payload={}", session.getId(), message.getPayload());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        webSocketSession.compareAndSet(session, null);
        log.info("websocket disconnected: sessionId={}, status={}", session.getId(), status);
    }
}
