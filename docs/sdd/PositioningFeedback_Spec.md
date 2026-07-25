# 📱 Especificação de UX: Feedback de Posicionamento e Rastreio Sem Câmera (Positioning & Spatial Feedback)

> **Status:** Especificado (Fase 2 - Design)
> **Data:** 24/07/2026
> **Módulo:** UI / UX Rastreamento Espacial (Vision + macOS)

---

## 1. Visão Geral (Overview)
Como o aplicativo migrará para uma experiência onde a câmera de vídeo real pode ficar oculta (para focar na estética 8-Bit/Retro do jogo ou rodar via MenuBar em plano de fundo), o usuário perde a referência visual direta do seu corpo.

Esta especificação define os 3 mecanismos fundamentais de **Feedback de Posicionamento Espacial** para garantir que o usuário sempre saiba onde sua mão está apontando e seja alertado caso saia do enquadramento da câmera.

---

## 2. Requisitos Detalhados

### 🎯 Requisito 1: Rastreio Contínuo (Cursor / Retículo da Mão)
- **Descrição:** Mesmo quando o usuário não estiver realizando a pinça (mão aberta/livre), o sistema exibirá um cursor sutil em tempo real na tela (ex: mira em pixel art 8-bit, retículo neon ou brilho pulsante).
- **Comportamento:**
  - Segue a posição `(X, Y)` normalizada da ponta do indicador/pulso convertida para as coordenadas da janela.
  - Altera de estado visual quando a pinça é ativada (ex: o retículo ganha brilho intenso ou vira o traçado neon).
  - Garante que o usuário nunca fique "às cegas" antes de iniciar um gesto.

---

### 🚨 Requisito 2: Sistema de Alerta de Bordas (Border Warning System)
- **Descrição:** Se a mão do usuário se aproximar dos limites do enquadramento da câmera, o app fornecerá um aviso periférico sutil para que ele retorne a mão ao centro da tela.
- **Regra de Negócio (Limiares):**
  - Se `x < 0.05` ou `x > 0.95` ou `y < 0.05` ou `y > 0.95` em coordenadas normalizadas Vision.
- **Feedback Visual:**
  - Uma borda avermelhada em néon (`Red Glowing Border`) pisca suavemente nos cantos da janela do jogo.
  - Exibe um pequeno indicador de seta/alerta apontando para o centro: *"Centralize a mão"*.

---

### 📷 Requisito 3: Fade-in de Calibração de Postura (Calibration Check)
- **Descrição:** Ao acionar o jogo (seja pelo aplicativo principal ou pelo atalho da MenuBar), o feed da câmera real aparece visível com **30% de opacidade** durante os primeiros 2 segundos de partida.
- **Comportamento:**
  - **0s - 2s:** Câmera semi-transparente (30%) + retículo da mão calibrando a posição da cadeira.
  - **Após 2s (ou ao fazer o primeiro aceno/pinça):** Transição fluída (`withAnimation(.easeInOut)`) de fade-out da câmera para 0% de opacidade, deixando apenas o mundo 8-Bit / retículo visual ativo.

---

## 3. Arquitetura e Modelos de Estado

```swift
import Foundation

/// Estado de calibração e posicionamento espacial do rastreador
@Observable
class SpatialTrackerState {
    var handCursorPosition: CGPoint = .zero
    var isHandNearBorder: Bool = false
    var isCalibrationPhase: Bool = true
    var cameraOpacity: Double = 0.3
}
```

---

## 4. Histórico de Alterações (Changelog)
| Data | Versão | Autor | Alteração |
|---|---|---|---|
| 24/07/2026 | 1.0 | Leonel / AI | Criação da especificação de Feedback de Posicionamento Espacial e Calibração. |

---
*Ref: Integrar futuramente no ciclo de implementação da UI do Jogo 8-Bit / MenuBar.*
