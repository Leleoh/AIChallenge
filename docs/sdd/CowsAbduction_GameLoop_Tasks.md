# 📝 Plano de Tarefas (Tasks): Game Loop de Abdução de Vacas v1.2

> **Status:** Aprovado (Fase 3 - Tasks v1.2)
> **Data:** 27/07/2026
> **Spec de Referência:** `docs/sdd/CowsAbduction_GameLoop_Spec.md`

---

## Checklist de Implementação (Fase 4 - Execute)

- [x] **1. Otimização de Performance e Multithreading**:
  - [x] Ingestão da câmera em background queue (`onObservationBackground`).
  - [x] Pré-carregamento GPU das texturas (`ufoTexture`, `cow1Textures`, `sleepTextures`, `brownCowTextures`).
  - [x] Isolamento do `SpriteView` contra re-avaliações do SwiftUI (`IsolatedSpriteView`).

- [x] **2. Rastreamento e Espelhamento de Gestos**:
  - [x] Espelhamento nativo da câmera (`.scaleEffect(x: -1, y: 1)`).
  - [x] Re-amostragem instantânea ao soltar a pinça (0ms delay no envio ao CoreML).

- [x] **3. Tracking Dinâmico dos OVNIs & Vacas**:
  - [x] Vacas caminhando pelo pasto.
  - [x] OVNIs acompanhando o eixo X da vaca alvo em tempo real.

- [ ] **4. Contagem Regressiva 3...2...1... JÁ!**:
  - [ ] Implementar overlay de contagem regressiva em SwiftUI (`countdownText`) controlado por timer antes de dar o `startSpawningUFOs()`.

- [ ] **5. Troca Dinâmica "Dormir -> Acordar -> Dormir"**:
  - [ ] Ao capturar a vaca dormindo (`VacaMalhadaDormindo`), alterar sua textura para caminhando (`VacaMalhadaCaminhando`) enquanto flutua.
  - [ ] Ao ser resgatada e pousar no solo, voltar para a animação dormindo.

- [ ] **6. Feixe Trator Suavizado (Soft Gradient Beam)**:
  - [ ] Remover contornos e bordas rígidas dos cones (`strokeColor = .clear`).
  - [ ] Criar gradiente de transparência (fade vertical do topo ao solo) para que o feixe se dissolva naturalmente na grama.

- [ ] **7. Ciclo Dinâmico de Dia e Noite**:
  - [ ] Adicionar camada `dayNightOverlayNode` em `CowsGameScene` com transição de cor suave de iluminação (Dia -> Entardecer -> Noite -> Dia).

- [ ] **8. Validação e QA**:
  - [ ] Compilar com `xcodebuild` e validar usabilidade e 60 FPS.
