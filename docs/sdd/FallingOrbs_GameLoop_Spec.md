# 📱 Especificação da Funcionalidade: Falling Orbs Game Loop (Magic Therapy)

> **Status:** Em Revisão (Fase 2 - Design)
> **Data:** 23/07/2026

## 1. Visão Geral (Overview)
Implementação do loop principal de gameplay gamificado do *Magic Therapy*. Esferas/Orbs contendo gestos geométricos caem do topo da tela. O jogador deve realizar o gesto no ar correspondente (reconhecido por CoreML) antes que o orb atinja o limite inferior da tela. O objetivo é acumular a maior pontuação possível enquanto gerencia um sistema de 3 vidas.

## 2. Requisitos (Requirements)
- **O que deve ter:** 
  - **Sistema de Spawn de Orbs:** Orbs aparecem no topo em posições X aleatórias e caem continuamente em direção à parte inferior.
  - **Velocidade Dinâmica (Progressiva com Cap):** A velocidade de queda aumenta gradualmente conforme a pontuação sobe, travando em um limite máximo seguro (*speed cap*) para evitar exaustão física do paciente.
  - **Reconhecimento via CoreML:** Quando o jogador completa um desenho no ar (reconhecido via `CoreMLService`), qualquer orb na tela cujo símbolo coincida com o gesto reconhecido é destruído.
  - **Sistema de Vidas (3 Vidas):** Cada orb que toca o limite inferior faz o jogador perder 1 vida. Com 0 vidas, a partida termina (Game Over).
  - **Pontuação (Score):** Cada orb destruído soma pontos.
  - **Game Over & Reinício:** Tela/Overlay simples exibindo a pontuação final e botão de "Jogar Novamente".
- **O que NÃO deve ter (Não-Escopo):**
  - Múltiplos gestos no mesmo orb (nesta versão 1.0, 1 orb = 1 gesto único).
  - Animações complexas de física/colisão rigorosa entre orbs.

## 3. Arquitetura e Padrões (Architecture & Patterns)
- **Padrão de Projeto:** MVVM (Model-View-ViewModel) + Service Pattern.
- **UI Framework:** SwiftUI.
- **Gerenciamento de Estado:** Macro `@Observable` (para a ViewModel do jogo).
- **Game Engine Lógica:** `TimelineView` / `Timer` em Swift rodando na ViewModel para atualização fluida do loop de física/queda.

## 4. Modelos de Dados (Data Models)

```swift
import Foundation

/// Representa o tipo de gesto exigido por um Orb
enum GestureType: String, CaseIterable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case lineV = "V"
    case lineZ = "Z"
    case infinite = "Infinite"
}

/// Representa um Orb/Inimigo caindo na tela
struct FallingOrb: Identifiable, Equatable {
    let id: UUID = UUID()
    var positionY: Double // Posição normalizada (0.0 no topo, 1.0 no fundo)
    let positionX: Double // Posição X normalizada (0.1 a 0.9)
    let targetGesture: GestureType
    var isPopped: Bool = false
}

/// Estado do Game Loop
enum GameState {
    case ready
    case playing
    case gameOver
}
```

## 5. Estrutura de Telas / UI (Views)
- **`FallingOrbsGameView`**: Tela principal do jogo.
  - Layer 1 (Fundo): Feed de vídeo da câmera (`CameraPreview`).
  - Layer 2 (Overlay de Jogo): `ZStack` renderizando os `FallingOrb`s caindo e o traçado atual da mão do usuário.
  - Layer 3 (HUD): Contador de Vidas (❤️❤️❤️), Placar no topo e Velocidade atual.
  - Layer 4 (Overlay Game Over): Exibido quando `gameState == .gameOver`, mostrando pontuação final e botão "Tentar Novamente".

## 6. Lógica de Negócio e Estados (ViewModels & Services)
- **`FallingOrbsGameViewModel`**:
  - Propriedades reativas (`@Observable`):
    - `orbs: [FallingOrb]` (Esferas ativas na tela)
    - `score: Int` (Pontuação atual)
    - `lives: Int = 3` (Vidas restantes, inicia com 3)
    - `gameState: GameState` (Estado do jogo: ready, playing, gameOver)
    - `currentSpeed: Double` (Velocidade atual com limite teto)
  - Funções principais:
    - `startGame()`: Reseta vidas para 3, score para 0 e inicia os timers de spawn e queda.
    - `updateGameLoop(deltaTime: Double)`: Atualiza a `positionY` de todos os orbs. Se `positionY >= 1.0`, remove o orb e decrementa 1 vida. Se `lives == 0`, dispara `endGame()`.
    - `onGestureRecognized(_ gestureLabel: String)`: Chamado quando o `CoreMLService` reconhece um gesto. Encontra o orb mais baixo correspondente àquele gesto e o destrói, somando pontos.
    - `endGame()`: Altera `gameState = .gameOver` e para a movimentação.

## 7. Casos Extremos e Tratamento de Erros (Edge Cases)
- **Perda da Mão pela Câmera:** Se o Vision perder a mão, os orbs continuam caindo, porém o traçado do desenho é pausado até a mão reaparecer.
- **Dois Orbs com o Mesmo Gesto:** Se houver mais de um orb com o mesmo gesto na tela, o sistema destrói os dois orbs.
- **Exaustão / Cap de Velocidade:** A velocidade de queda tem um valor teto (`maxSpeed`) inultrapassável para garantir ergonomia.

## 8. Estratégia de Testes (QA Strategy)
- **Unit Tests:**
  - Testar `updateGameLoop`: verificar se a vida cai quando `positionY >= 1.0`.
  - Testar `onGestureRecognized`: verificar se o orb correto (mais próximo do chão) é destruído.
  - Testar trava de velocidade teto (`maxSpeed`).
- **Testes Manuais / UI:**
  - Testar jogabilidade real com câmera, fazendo gestos reais gravados no CoreML.
  - Verificar se a tela de Game Over aparece corretamente com 0 vidas.

## 9. Histórico de Revisões (Changelog)
| Data       | Versão | Autor          | Descrição das Alterações                          |
|------------|--------|----------------|---------------------------------------------------|
| 23/07/2026 | 1.0    | Leonel / AI    | Criação da especificação do Game Loop (Falling Orbs). |

---
*Nota para a IA:* Ao implementar esta especificação, siga estritamente as decisões arquiteturais acima e informe se encontrar qualquer inconsistência antes de escrever o código.
