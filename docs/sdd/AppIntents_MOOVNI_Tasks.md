# 📝 Plano de Tarefas (Tasks): App Intents, Siri & Prompt Waiter

> **Status:** Concluído (Fase 4 - Execute v1.0)
> **Data:** 28/07/2026
> **Spec de Referência:** `docs/sdd/AppIntents_MOOVNI_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [x] **1. Criar o Arquivo de Intents (`AIChallenge/Intents/MOOVNIIntents.swift`)**:
  - [x] Implementar `StartResgateIntent` (Iniciar Resgate Padrão).
  - [x] Implementar `GetHighScoreIntent` (Consultar Recorde do Usuário).
  - [x] Implementar `QuickBreakIntent` ("Pausa da IA / Prompt Waiter").
  - [x] Implementar `MOOVNIShortcuts` (`AppShortcutsProvider`) com as frases sugeridas para Siri/Spotlight.

- [x] **2. Conectar com o App (`AIChallengeApp.swift` & `CowsGameView.swift`)**:
  - [x] Adicionar suporte ao escutador de notificações `NotificationCenter` para disparar `startSeamlessGame()` instantaneamente quando um Intent for ativado.

- [x] **3. Validação e QA**:
  - [x] Compilar com `xcodebuild` e validar extração de metadados (`Metadata.appintents`).
  - [x] Testar os Atalhos e Intents via App Atalhos / Siri / Spotlight no macOS.
