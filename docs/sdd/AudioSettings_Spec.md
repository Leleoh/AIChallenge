# 📱 Especificação da Funcionalidade: Controles de Áudio (Música & Efeitos Sonoros)

> **Status:** Aprovado (Fase 2 - Design v1.0)
> **Data:** 29/07/2026
> **Módulo:** SoundService / SwiftUI UI / macOS

---

## 1. Visão Geral (Overview)
Implementação de controles para ativas e desativar independentemente a **Música de Fundo (BGM)** e os **Efeitos Sonoros (SFX)**. As preferências do usuário são persistidas no `UserDefaults` do macOS via `@AppStorage`.

---

## 2. Componentes e Regras de Estado

### 2.1. Persistence Keys (`UserDefaults`)
- `"isMusicEnabled"`: `Bool` (Padrão: `true`).
- `"isSFXEnabled"`: `Bool` (Padrão: `true`).

### 2.2. SoundService
- `isMusicEnabled`: `Bool` (propriedade observável). Quando alterada para `false`, chama `stopBGM()`. Quando alterada para `true`, chama `playBGM()`.
- `isSFXEnabled`: `Bool`. Quando `false`, impede a execução de `playSFX` e `playUfoSFX`.

### 2.3. Interface do Usuário (UI)
- **Menu Principal (`CowsGameMenuView.swift`)**: Botões compactos de alternância com ícones SF Symbols (`music.note` e `speaker.wave.2.fill`) no canto superior.
- **Modal de Pausa (`CowsGameView.swift`)**: Controles de áudio equivalentes para ajuste durante a partida.

---

## 3. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 29/07/2026 | 1.0 | Leonel / AI | Especificação inicial do gerenciador e toggles de áudio. |
