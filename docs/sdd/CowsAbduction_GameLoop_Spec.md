# 📱 Especificação da Funcionalidade: Game Loop de Abdução de Vacas com Gestos CoreML

> **Status:** Em Revisão (Fase 2 - Design)
> **Data:** 27/07/2026
> **Módulo:** Game Loop / SpriteKit / CoreML / SwiftUI

---

## 1. Visão Geral (Overview)
Substituição da mecânica de estourar orbs por um **Game Loop de Abdução Alienígena de Vacas**, no qual discos voadores (UFOs) surgem na cena e feixes de abdução levantam as vacas pelo pasto. Para salvar cada vaca, o jogador deve executar o gesto desenhado no ar correspondente à nave captora (Quadrado, Círculo, Triângulo, V, Z, Infinito), detectado em tempo real por IA via `CoreMLService` e `VisionService`.

---

## 2. Requisitos (Requirements)

- **O que deve ter:** 
  - **Spawning Dinâmico de OVNIs/Naves**: Naves alienígenas surgem no topo da tela em posições aleatórias acima do pasto.
  - **Feixe Trator & Animação de Flutuação**: Cada nave ativa um feixe de abdução neon e atrai uma vaca, fazendo-a flutuar verticalmente do chão até a nave.
  - **Identificador Visual do Gesto**: Cada nave exibe um indicador visual (ícone/símbolo) referente ao gesto exigido para libertá-la (Square, Circle, Triangle, V, Z, Infinity).
  - **Reconhecimento de Gestos via CoreML**: Integração contínua com a trajetória da mão via `VisionService` e `CoreMLService` para identificar o gesto desenhado.
  - **Mecânica de Sucesso (Resgate)**: Ao acertar o gesto exigido por uma nave ativa:
    - O feixe de abdução é desativado.
    - A nave desmaterializa/decola para fora da tela.
    - A vaca flutua/cai suavemente de volta ao pasto em segurança.
    - O jogador recebe pontos.
  - **Mecânica de Falha & Sistema de Vidas**:
    - O jogador inicia a partida com 3 Vidas (3 vacas permitidas para perda).
    - Cada abdução possui um tempo limite ajustável (ex: 4.0 a 5.0 segundos).
    - Se o tempo esgotar sem o gesto correto, a vaca é abduzida (entra na nave), a nave foge e o jogador perde 1 Vida.
    - O jogo encerra em Game Over quando as 3 vidas chegam a zero.
  - **Dificuldade Progressiva**: Conforme a pontuação aumenta, a taxa de spawn de novas naves aumenta e o tempo de abdução encurta sutilmente.
  - **Overlay de Desenho / Traçado da Mão**: Exibição visual em tempo real do traçado que o usuário está desenhando no ar.
  - **Suporte a Variantes de Vacas**: Suporte a sprites de `VacaMalhada` e `VacaMarrom`.

- **O que NÃO deve ter (Não-Escopo):**
  - Compras in-app ou modo multiplayer online.
  - Mais de 5 naves abduzindo simultaneamente na primeira versão (v1.0) para preservar o equilíbrio de gameplay.

---

## 3. Arquitetura e Padrões (Architecture & Patterns)

- **Padrão de Projeto:** MVVM + Service + Game Engine (SpriteKit Integration)
- **UI Framework:** SwiftUI (`CowsGameView`) encapsulando SpriteKit (`SpriteView`).
- **Game Engine Scene:** `CowsGameScene` (`SKScene`).
- **Gerenciamento de Estado do Jogo:** `CowsGameViewModel` (`@Observable`), responsável pela pontuação, contador de vidas (3), estado do jogo (`.playing`, `.gameOver`, `.paused`) e pela comunicação entre as predições de IA do `CoreMLService` e os nós da cena em SpriteKit.
- **Machine Learning & Visão Computacional:** `VisionService` (captura de pose das mãos em tempo real) e `CoreMLService` (classificação temporal de ações no modelo `MagicHandsML`).

---

## 4. Modelos de Dados (Data Models)

```swift
import Foundation

/// Tipos de gestos reconhecidos pelo modelo CoreML
enum GestureType: String, CaseIterable, Identifiable {
    case square = "Square"
    case circle = "Circle"
    case triangle = "Triangle"
    case vShape = "V"
    case zShape = "Z"
    case infinity = "Infinity"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .square: return "square"
        case .circle: return "circle"
        case .triangle: return "triangle"
        case .vShape: return "v.circle"
        case .zShape: return "z.circle"
        case .infinity: return "infinity"
        }
    }
}

/// Estado do Jogo
enum GameState {
    case idle
    case playing
    case gameOver
}

/// Representa a estrutura de dados de uma nave abduzindo na cena
struct AbductionTarget: Identifiable {
    let id: UUID
    let gestureRequired: GestureType
    var timeRemaining: TimeInterval
    var totalDuration: TimeInterval
    var isRescued: Bool
    var isAbducted: Bool
}
```

---

## 5. Estrutura de Telas / UI (Views)

- **`CowsGameView`**:
  - `SpriteView(scene: gameScene)` renderizado em tela cheia.
  - **Overlay Superior de HUD**:
    - Marcador de pontuação.
    - Contador de vidas (Ícones de vacas).
    - Display discreto da última predição de gesto reconhecida pelo CoreML.
  - **Canvas de Traçado (Overlay)**: Exibe a linha do desenho feito no ar pela mão do usuário durante a pinça.
  - **Modal de Game Over**: Exibida quando `lives == 0`, oferecendo pontuação alcançada e botão de "Jogar Novamente".

---

## 6. Lógica de Negócio e Estados (ViewModels)

- **`CowsGameViewModel`**:
  - `score: Int`: Pontuação acumulada.
  - `lives: Int`: Começa em 3.
  - `gameState: GameState`: Estado atual da partida.
  - `activeAbductions: [AbductionTarget]`: Lista de abduções em andamento.
  - `func handleGestureRecognized(_ prediction: GesturePrediction)`:
    - Valida se a predição possui confiança superior a 0.65.
    - Verifica se o rótulo da predição corresponde ao `gestureRequired` de alguma nave ativa.
    - Em caso afirmativo, envia sinal para a `CowsGameScene` para desativar a nave e resgatar a vaca (+pontos).
  - `func onCowAbducted(targetId: UUID)`:
    - Reduz `lives` em 1.
    - Se `lives == 0`, altera `gameState = .gameOver`.

---

## 7. Casos Extremos e Tratamento de Erros (Edge Cases)

- **Perda de rastreamento da mão (Mão sai da câmera):** O buffer do `VisionService` e o traçado visual são limpos para evitar disparos falsos de gestos incompletos.
- **Predições com baixa confiança (< 65%):** O gesto é ignorado e o feixe/nave continua abduzindo sem penalização adicional.
- **Sem vacas disponíveis no pasto:** O temporizador de spawn de naves aguarda até que haja pelo menos uma vaca em estado normal no solo antes de spawnar uma nova nave.

---

## 8. Estratégia de Testes (QA Strategy)

- **Unit Tests (`CowsGameViewModelTests`):**
  - Cobertura da redução de vidas e término de jogo (`lives == 0`).
  - Cobertura do cálculo e incremento de pontuação ao resgatar vaca com gesto correto.
  - Validação da associação entre `GesturePrediction` e `GestureType`.
- **Testes Manuais / UI:**
  - Testar a fluidez da animação de elevação e queda da vaca em SpriteKit.
  - Verificar a clareza e visibilidade dos ícones de gestos acima do raio trator da nave.
  - Testar o reconhecimento de todos os 6 gestos no ar com a câmera em tempo real.

---

## 9. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 27/07/2026 | 1.0 | Leonel / AI | Especificação inicial da arquitetura do Game Loop de Abdução de Vacas. |
