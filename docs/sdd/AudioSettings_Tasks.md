# 📝 Plano de Tarefas (Tasks): Controles de Áudio (Música & Efeitos Sonoros)

> **Status:** Concluído (Fase 4 - Execute v1.0)
> **Data:** 29/07/2026
> **Spec de Referência:** `docs/sdd/AudioSettings_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [x] **1. Atualizar o `SoundService.swift`**:
  - [x] Adicionar propriedades observáveis `@Published var isMusicEnabled` e `@Published var isSFXEnabled` com sincronização no `UserDefaults`.
  - [x] Atualizar `playBGM`, `playSFX` e `playUfoSFX` para respeitar as preferências ativas.

- [x] **2. Atualizar a UI do Menu Principal (`CowsGameMenuView.swift`)**:
  - [x] Adicionar os botões de alternância de Música e SFX no canto superior com animação e feedback visual.

- [x] **3. Atualizar a UI do Menu de Pausa (`CowsGameView.swift`)**:
  - [x] Adicionar os toggles equivalentes no overlay de pausa (`pauseOverlayView`).

- [x] **4. Validação e QA**:
  - [x] Compilar com `xcodebuild`.
  - [x] Validar a alternância de som e persistência ao reiniciar o app.
