# 📋 Lista de Tarefas (Tasks): Falling Orbs Game Loop

> **Status:** Aguardando Aprovação (Fase 3)
> **Ref:** `docs/sdd/FallingOrbs_GameLoop_Spec.md`

## Checklist de Implementação

- [ ] **Passo 1: Modelos de Dados (Data Models)**
  - Criar o arquivo `AIChallenge/Models/FallingOrb.swift`.
  - Definir `GestureType` (com `.circle`, `.square`, `.triangle`, `.lineV`, `.lineZ`, `.infinite`).
  - Definir `FallingOrb` (struct identificável com `positionX`, `positionY`, `targetGesture`).
  - Definir `GameState` (`.ready`, `.playing`, `.gameOver`).

- [ ] **Passo 2: ViewModel do Jogo (Business Logic & Game Loop)**
  - Criar o arquivo `AIChallenge/ViewModels/FallingOrbsGameViewModel.swift` usando a macro `@Observable`.
  - Implementar o loop de atualização (`updateGameLoop`) com aceleração progressiva de velocidade com teto (`maxSpeed`).
  - Implementar lógica de Spawn aleatório no topo.
  - Implementar lógica de destruição: ao reconhecer o gesto, destruir **todos** os orbs ativos que possuem aquele mesmo gesto na tela (conforme regra atualizada no Spec).
  - Implementar lógica de perda de vidas (ao atingir `positionY >= 1.0`) e acionamento do Game Over.

- [ ] **Passo 3: Componente Visual do Orb (UI Element)**
  - Criar a view reutilizável `AIChallenge/Views/Components/OrbView.swift`.
  - Renderizar o formato visual do orb (esfera colorida com sombra/brilho) contendo o símbolo do gesto (`GestureType`).

- [ ] **Passo 4: Tela Principal do Jogo (Game View & Overlays)**
  - Criar o arquivo `AIChallenge/Views/FallingOrbsGameView.swift`.
  - Integrar o `CameraPreview` no fundo.
  - Renderizar a camada de `ZStack` contendo os `OrbView`s caindo e o rastro do desenho feito no ar.
  - Adicionar o HUD superior (Placar de Pontuação + Vidas ❤️❤️❤️ + Velocidade).
  - Adicionar o Overlay de Game Over com botão de reiniciar partida.

- [ ] **Passo 5: Conexão com CoreMLService**
  - Conectar as predições do `CoreMLService` com o método `onGestureRecognized` da `FallingOrbsGameViewModel`.
