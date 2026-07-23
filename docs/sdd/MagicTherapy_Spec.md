# 📱 Especificação da Funcionalidade: Magic Therapy (Fisioterapia Gamificada)

> **Status:** Implementado (Fase 4)
> **Data:** 15/07/2026

## 1. Visão Geral (Overview)
Aplicativo gamificado para movimentos da mão, no futuro, quero expandir para reabilitação motora e fisioterapia. O usuário realiza gestos e movimentos rastreados pela câmera do dispositivo para interagir com elementos virtuais (como estourar balões). O objetivo inicial é focar em movimentos abrangentes e simples (posição da mão), priorizando macOS com futura expansão para iPadOS.

## 2. Requisitos (Requirements)
- **O que deve ter:** 
  - **Captura e Rastreamento:** Uso de `AVFoundation` para câmera e `Vision` (`VNDetectHumanHandPoseRequest`) para rastrear a posição da mão/dedos.
  - **Mecânica Inicial (Sem Treinamento CoreML):** Interação baseada no reconhecimento de gestos simples feitos no ar (ex: mão aberta, punho fechado, ou movimentos básicos) que correspondem ao "símbolo/gesto" exigido pelo balão para estourá-lo, independente de onde o balão esteja na tela. A lógica não é baseada em colisão (levar a mão até o balão).
  - **Gamificação:** Sistema de pontuação e spawn (geração) de balões aleatórios na tela.
  - **Plataforma:** Projeto multi-plataforma focado primariamente em macOS.
  - **App Intents:** Suporte à Siri (ex: "Quantos balões eu estourei?", "Iniciar sessão de fisioterapia").
- **O que NÃO deve ter (Não-Escopo):**
  - Modelos CoreML customizados para reconhecimento complexo de trajetórias (nesta versão 1.0).
  - Funcionalidades exclusivas de iOS (como ARKit).

## 3. Arquitetura e Padrões (Architecture & Patterns)
- **Padrão de Projeto:** MVVM (Model-View-ViewModel) + Service Pattern.
- **UI Framework:** SwiftUI.
- **Gerenciamento de Estado:** `@Observable` (ou `@StateObject` / `@Published`).
- **Injeção de Dependência:** Simples, inicializando os serviços nas ViewModels.

## 4. Modelos de Dados (Data Models)

```swift
import Foundation

/// Representa um balão (ou inimigo) na tela
struct Balloon: Identifiable, Equatable {
    let id: UUID = UUID()
    var position: CGPoint // Posição normalizada (0.0 a 1.0) para se adaptar a qualquer tamanho de tela
    var isPopped: Bool = false
    var symbol: String = "🎈" // Pode ser expandido futuramente para tipos de inimigos
}

/// Representa a sessão atual do jogo/fisioterapia
struct GameSession {
    var score: Int = 0
    var activeBalloons: [Balloon] = []
    var isPlaying: Bool = false
}
```

## 5. Estrutura de Telas / UI (Views)
- **`HomeView`:** Tela inicial com um botão para "Iniciar Sessão" e exibir a pontuação total.
- **`GameView`:** Tela principal do jogo.
  - Fundo: Feed de vídeo da câmera do Mac (`CameraPreview`).
  - Overlay (ZStack): Os `Balloon`s posicionados na tela, além de um cursor visual mostrando onde a mão do usuário está sendo detectada.
  - UI Superior: Placar atual e botão de "Encerrar Sessão".
- **Componente `CameraPreview`:** Uma view auxiliar que envelopa a camada do `AVCaptureVideoPreviewLayer`.

## 6. Lógica de Negócio e Estados (ViewModels & Services)
- **`VisionService`:**
  - Responsabilidade: Configurar a câmera, processar os frames via `AVCaptureVideoDataOutput`, e rodar o `VNHumanHandPoseObservation`.
  - Callback: Em vez de apenas emitir coordenadas, o serviço analisa a pose da mão em tempo real através de cálculos heurísticos (distância entre pontas dos dedos e punho) e emite um `Gesto Detectado` (ex: `enum HandGesture { case openHand, fist, unknown }`). Futuramente, isso será substituído por um modelo CoreML para trajetórias complexas.
- **`GameViewModel`:**
  - Propriedades: `session` (Estado do jogo), `currentGesture` (Último gesto reconhecido no ar).
  - Funções:
    - `startGame()`: Inicia o VisionService e o spawn de balões.
    - `spawnBalloon()`: Adiciona um balão que exige um gesto específico para ser estourado (ex: um balão com símbolo de "Mão Fechada").
    - `processGesture(_ gesture: HandGesture)`: Verifica se o gesto feito no ar corresponde ao gesto exigido pelo balão mais antigo/próximo na tela. Se bater com o alvo, estoura o balão e aumenta o score.
    - `endGame()`: Para a câmera e salva a pontuação total.
- **`AppIntents` (Intents Extension):**
  - `CheckScoreIntent`: Consulta os UserDefaults ou SwiftData para retornar a pontuação acumulada.
  - `StartSessionIntent`: Redireciona via Deeplink para a `GameView`.

## 7. Casos Extremos e Tratamento de Erros (Edge Cases)
- **Permissão de Câmera:** O app deve solicitar permissão e, se negado, exibir uma View instruindo o usuário a ir aos Ajustes do Mac.
- **Perda de Rastreamento:** Se a mão sair do quadro, o jogo continua, mas o "cursor visual" da mão desaparece.
- **Limites de Tela:** O sistema de colisão deve traduzir as coordenadas normalizadas (do Vision) para o tamanho real da janela do Mac no momento.

---

## 8. Estratégia de Testes (QA Strategy)
- **Unit Tests:** Lógica de negócio da `GameViewModel`, como o cálculo de pontuação (`score`) e limites de tela.
- **Testes Manuais / UI:** Testar estabilidade do Vision Tracking sob luzes variadas e verificar overlay de balões.

## 9. Histórico de Revisões (Changelog)
| Data       | Versão | Autor          | Descrição das Alterações                          |
|------------|--------|----------------|---------------------------------------------------|
| 15/07/2026 | 1.0    | Leonel         | Criação inicial do documento de especificação.    |
| 23/07/2026 | 1.1    | AI / Leonel    | Status alterado para Implementado. Adicionado seção QA e Changelog. |
