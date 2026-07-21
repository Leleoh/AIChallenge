# 📋 Fase 3: Planejamento de Tarefas (Magic Therapy)

Aqui está o detalhamento de como construiremos a arquitetura definida na Especificação. Marcaremos cada etapa com `[x]` conforme avançamos para garantir que o código seja altamente modular.

- [x] **Etapa 1: Setup da Arquitetura e Models**
  - [x] Criar estrutura de pastas (Models, ViewModels, Services, Views, Intents).
  - [x] Criar Enum `HandGesture` (`openHand`, `fist`, `unknown`).
  - [x] Criar struct `Balloon` (com a propriedade `requiredGesture` e UI associada ao símbolo).
  - [x] Criar struct `GameSession`.

- [x] **Etapa 2: A IA da Câmera (Vision Service)**
  - [x] Criar classe `VisionService` injetável.
  - [x] Configurar `AVCaptureSession` para pegar o feed da câmera do Mac de forma assíncrona.
  - [x] Implementar o `VNDetectHumanHandPoseRequest`.
  - [x] Escrever a **Heurística de Gestos**: calcular a distância entre os dedos e o punho para determinar se a mão está Aberta (OpenHand) ou Fechada (Fist).

- [x] **Etapa 3: Lógica do Jogo (GameViewModel)**
  - [x] Criar a `GameViewModel` com `@Observable`.
  - [x] Conectar o callback do `VisionService` à ViewModel.
  - [x] Implementar loop de tempo para gerar balões na tela (`spawnBalloon`).
  - [x] Implementar `processGesture(_ gesture: HandGesture)` para estourar o balão correto caso o usuário acerte o gesto.

- [x] **Etapa 4: Interface do Usuário (Views)**
  - [x] Criar componente auxiliar `CameraPreview` (ponte entre `AVCaptureVideoPreviewLayer` e SwiftUI via `NSViewRepresentable`).
  - [x] Criar a `GameView`: Renderizar a câmera no fundo e os `Balloons` num `ZStack` por cima, com animações.
  - [x] Criar a `HomeView`: Tela inicial de boas vindas mostrando o score e botão para iniciar o jogo.

- [ ] **Etapa 5: Siri e Atalhos (App Intents)**
  - [ ] Implementar persistência simples do score (AppStorage/UserDefaults).
  - [ ] Criar a Extensão e os structs de `AppIntents` (`StartSessionIntent` e `CheckScoreIntent`).

- [x] **Etapa 6: CoreML Gestures (Desenho no Ar)**
  - [x] Confirmar adição do modelo `MagicHandsML` ao target do Xcode.
  - [x] Criar `CoreMLService` para processar a janela de frames e invocar o modelo Action Classifier.
  - [x] Atualizar `VisionService` para detectar o gatilho (Pinça) e manter o buffer de histórico de frames.
  - [x] Criar `SandboxViewModel` para gerenciar os estados de desenho e gerar o Path do traçado.
  - [x] Criar a view `CoreMLSandboxView` com câmera, overlay do traçado e exibição do resultado da predição.
