# 📱 Especificação da Funcionalidade: Magic Therapy (Fisioterapia Gamificada)

> **Status:** Em Revisão (Fase 1/2)
> **Data:** 14/07/2026

## 1. Visão Geral (Overview)
Aplicativo gamificado para reabilitação motora e fisioterapia. Inspirado em mecânicas de "Magic Touch Wizard", o usuário usa gestos capturados pela câmera para desenhar símbolos e derrotar inimigos/estourar balões, estimulando movimentos corretos das mãos, dedos ou braços.

## 2. Requisitos (Requirements)
- **O que deve ter:** 
  - Captura de câmera em tempo real.
  - Rastreamento de mãos/corpo usando Vision Framework.
  - Classificação de gestos (possivelmente usando CoreML).
  - Gamificação (Inimigos, balões, pontuação).
  - Suporte a App Intents (ex: Iniciar sessão via Siri).
- **O que NÃO deve ter (Não-Escopo):**
  - Modelos de fundação generativos (LLMs), a não ser que haja um chat. O foco de IA aqui é Visão Computacional.

## 3. Arquitetura e Padrões (Architecture & Patterns)
- **Padrão de Projeto:** MVVM (Model-View-ViewModel)
- **UI Framework:** SwiftUI Multiplataforma (macOS + iOS/iPadOS)
- **Câmera/IA:** `AVFoundation` para o feed de vídeo, `Vision` para extração de pontos anatômicos, `CoreML` para inferência de gestos.

*(As seções de Modelos de Dados e Estrutura de Telas serão preenchidas após a resposta às Perguntas Abertas).*
