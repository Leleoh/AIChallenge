# 📝 Plano de Tarefas (Tasks): Refinamentos Visuais e UX do Pasto e Telas

> **Status:** Concluído (Fase 4 - Execute v1.0)
> **Data:** 30/07/2026
> **Spec de Referência:** `docs/sdd/VisualRefinements_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [x] **1. Adicionar Sombras aos Animais no Pasto (`CowsGameScene.swift`)**:
  - [x] Criar nós de sombra oval (`SKShapeNode`) para cada animal no `setupCows`.
  - [x] Garantir que a sombra acompanhe o movimento dos animais caminhando.
  - [x] Tratar transparência da sombra quando o animal for elevado pelo feixe do OVNI.

- [x] **2. Padronizar Altura dos Botões do Menu (`CowsGameView.swift`)**:
  - [x] Ajustar botões do `menuOverlayView` para altura idêntica `height: 54`.

- [x] **3. Inverter Ordem dos Botões de Game Over (`CowsGameView.swift`)**:
  - [x] Reordenar botões no `gameOverOverlayView` colocando "Voltar ao Menu" em 1º e "Jogar Novamente" em 2º, mantendo suas cores originais.

- [x] **4. Ampliar Texto de Instrução no Guia (`GesturesGuideModalView.swift`)**:
  - [x] Aumentar tamanho e peso da fonte da instrução do polegar e indicador.

- [x] **5. Validação e QA**:
  - [x] Compilar com `xcodebuild` e validar renderização no macOS.
