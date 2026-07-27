# 📝 Plano de Tarefas (Tasks): Menu Inicial CowreML (Moo Liberation)

> **Status:** Proposta (Fase 3 - Tasks v1.0)
> **Data:** 27/07/2026
> **Spec de Referência:** `docs/sdd/CowreML_MainMenu_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [ ] **1. Criar `CowsMenuScene.swift` (SpriteKit Background)**:
  - [ ] Montar cenário com céu, nuvens em paralaxe, relevo e pasto.
  - [ ] Adicionar vacas malhada, marrom e dormindo se movimentando de forma decorativa.
  - [ ] Adicionar OVNI decorativo flutuando suavemente no céu.

- [ ] **2. Criar `GesturesGuideModalView.swift` (Modal Como Jogar)**:
  - [ ] Criar modal pop-up com a explicação da pinça da mão (Thumb & Index tip).
  - [ ] Renderizar os 6 gestos (Quadrado ⏹, Círculo ⏺, Triângulo ▲, V, Z, Infinito ∞) com ícones e nomes.

- [ ] **3. Criar `CowsGameMenuView.swift` (Interface Principal em SwiftUI)**:
  - [ ] Integrar `CowsMenuScene` isolada via `Equatable` ao fundo.
  - [ ] Renderizar Título 8-Bit **"CowreML: Moo Liberation"**.
  - [ ] Criar botões **"JOGAR"** e **"COMO JOGAR"**.
  - [ ] Exibir recorde de pontos via `@AppStorage("cowsHighScore")`.
  - [ ] Apresentar `CowsGameView` via sheet/fullScreenCover ao clicar em "JOGAR".

- [ ] **4. Atualizar `HomeView.swift`**:
  - [ ] Conectar o botão do menu principal à nova `CowsGameMenuView`.

- [ ] **5. Validação e QA**:
  - [ ] Executar build via `xcodebuild` e validar usabilidade.
