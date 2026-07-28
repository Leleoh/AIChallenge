# 📝 Plano de Tarefas (Tasks): Cena Única Contínua & Menu de Pausa

> **Status:** Aprovado (Fase 3 - Tasks v1.2)
> **Data:** 27/07/2026
> **Spec de Referência:** `docs/sdd/CowreML_MainMenu_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [ ] **1. Unificar o Estado da Cena (`CowsGameScene.swift`)**:
  - [ ] Integrar nó do título **M.O.O.V.N.I.** e feixe decorativo diretamente em `CowsGameScene`.
  - [ ] Criar métodos `transitionToGame()` e `transitionToMenu()` com animações suaves de `fadeIn`/`fadeOut`.
  - [ ] Adicionar suporte ao estado `.paused` congelando a física e os timers (`isPaused = true`).

- [ ] **2. Atualizar o ViewModel (`CowsGameViewModel.swift`)**:
  - [ ] Adicionar suporte a `pauseGame()` e `resumeGame()`.
  - [ ] Gerenciar alternância suave entre estados `.menu`, `.playing`, `.paused` e `.gameOver`.

- [ ] **3. Implementar Menu de Pausa (`CowsGameView.swift`)**:
  - [ ] Substituir o botão de sair direto por botão de Pausa **"⏸ Pausar"**.
  - [ ] Criar overlay de Pausa com opções **"Continuar"** e **"Voltar ao Menu"**.

- [ ] **4. Simplificar `CowsGameMenuView.swift`**:
  - [ ] Conectar diretamente a `CowsGameView` como container principal unificado da experiência M.O.O.V.N.I.

- [ ] **5. Validação e QA**:
  - [ ] Compilar com `xcodebuild` e testar a transição sem cortes e a pausa.
