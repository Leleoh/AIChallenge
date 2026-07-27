# 📝 Plano de Tarefas (Tasks): Game Loop de Abdução de Vacas

> **Status:** Em Revisão (Fase 3 - Tasks)
> **Data:** 27/07/2026
> **Spec de Referência:** `docs/sdd/CowsAbduction_GameLoop_Spec.md`

---

## Checklist de Implementação (Passo a Passo)

### 🟢 Etapa 1: Modelos de Dados (Models)
- [ ] **1.1** Criar o arquivo `AIChallenge/Models/CowsGameModels.swift`.
- [ ] **1.2** Definir o enum `GestureType` contendo as 6 formas reconhecidas pelo CoreML (`square`, `circle`, `triangle`, `vShape`, `zShape`, `infinity`) com mapeamento de ícones SFSymbols.
- [ ] **1.3** Definir os enums `GameState` (`.idle`, `.playing`, `.gameOver`) e a struct `AbductionTarget` para rastrear naves ativas e timers de abdução.

### 🟢 Etapa 2: ViewModel do Jogo (ViewModel)
- [ ] **2.1** Criar o arquivo `AIChallenge/ViewModels/CowsGameViewModel.swift` anotado com `@Observable`.
- [ ] **2.2** Adicionar propriedades `score`, `lives` (inicial 3), `gameState` e `activeAbductions`.
- [ ] **2.3** Criar método `handleGestureRecognized(_ prediction: GesturePrediction)` para validar a confiança (> 65%) e acionar o resgate da nave correspondente ao gesto.
- [ ] **2.4** Criar método `onCowAbducted(targetId: UUID)` para decremento de vidas e disparo de Game Over quando `lives == 0`.
- [ ] **2.5** Criar métodos `startGame()` e `restartGame()`.

### 🟢 Etapa 3: Integração SpriteKit (CowsGameScene)
- [ ] **3.1** Atualizar `AIChallenge/Views/CowsGameScene.swift` para suportar criação e destruição dinâmica de nós de OVNIs (`SKSpriteNode`) e badges de gestos (`SKNode` / `SKLabelNode` / `SKSpriteNode`).
- [ ] **3.2** Criar método `spawnUFOAbduction(target: AbductionTarget, position: CGPoint)`:
  - Criar OVNI + feixe trator neon (`beamNode`).
  - Renderizar o ícone do gesto exigido no topo da nave.
  - Iniciar animação de elevação da vaca em direção ao OVNI.
- [ ] **3.3** Criar método `performRescueAnimation(targetId: UUID)`:
  - Desligar o feixe trator e animar o OVNI subindo rápido para fora da tela.
  - Animar a vaca descendo suavemente ao solo e retomando seu estado normal.
- [ ] **3.4** Criar método `performAbductionAnimation(targetId: UUID)`:
  - Fazer a vaca sumir dentro da nave e o OVNI desaparecer.
  - Notificar a ViewModel da perda de vida.

### 🟢 Etapa 4: Interface SwiftUI e Overlays (Views & Services)
- [ ] **4.1** Atualizar `AIChallenge/Views/CowsGameView.swift` para integrar o `CowsGameViewModel`, `VisionService` e `CoreMLService`.
- [ ] **4.2** Criar o HUD superior de estatísticas (Placar, 3 Vidas em forma de vacas, status da predição).
- [ ] **4.3** Garantir a exibição em tempo real do traçado/canvas de desenho da pinça sobre a cena do jogo.
- [ ] **4.4** Implementar a View de Game Over com o placar final e botão de reiniciar a partida.

### 🟢 Etapa 5: Validação e Testes (QA)
- [ ] **5.1** Compilar o projeto e verificar ausência de warnings ou erros de build.
- [ ] **5.2** Validar a fluidez do game loop completo (spawn de naves -> desenho no ar -> resgate/abdução -> Game Over).
