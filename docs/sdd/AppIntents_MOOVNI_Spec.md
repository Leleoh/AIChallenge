# 📱 Especificação da Funcionalidade: Integração com App Intents & Siri / Spotlight / Prompt Waiter

> **Status:** Aprovado (Fase 2 - Design v1.1)
> **Data:** 28/07/2026
> **Módulo:** AppIntents / Siri / Spotlight / Shortcuts / macOS

---

## 1. Visão Geral (Overview)
Implementação do framework nativo **App Intents** da Apple para o aplicativo **M.O.O.V.N.I.** no macOS. Permite que o usuário acione o jogo por voz (Siri), por busca de texto (Spotlight do Mac), por atalhos globais de teclado ou durante a espera de um prompt de IA (Prompt Waiter).

---

## 2. Requisitos de Intents (AppIntents)

### Ação 1: `StartResgateIntent` (Iniciar Resgate Padrão)
- **Frases de Ativação**:
  - *"Iniciar resgate no M.O.O.V.N.I."*
  - *"Resgatar vacas no M.O.O.V.N.I."*
  - *"Jogar M.O.O.V.N.I."*
- **Comportamento**: Abre o aplicativo e inicia a partida imediatamente na contagem 3... 2... 1... JÁ!

### Ação 2: `QuickBreakIntent` ("Prompt Waiter / Pausa da IA")
- **Frases de Ativação**:
  - *"Jogar enquanto a IA pensa no M.O.O.V.N.I."*
  - *"Pausa de prompt no M.O.O.V.N.I."*
  - *"Resgate rápido no M.O.O.V.N.I."*
- **Comportamento**: Abre o jogo diretamente para uma rodada rápida de descompressão enquanto o desenvolvedor aguarda a resposta de um prompt longo do Claude / LLM.

---

## 3. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 28/07/2026 | 1.0 | Leonel / AI | Especificação inicial de App Intents, Siri, Spotlight e Prompt Waiter. |
| 28/07/2026 | 1.1 | Leonel / AI | Simplificação para focar nos 2 Intents de inicialização imediata. |
