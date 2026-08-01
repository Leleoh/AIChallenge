# 🛸 M.O.O.V.N.I. — Alien Cow Rescue Game

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue.svg)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org/)
[![CoreML](https://img.shields.io/badge/CoreML-Spatial%20ML-green.svg)](https://developer.apple.com/documentation/coreml)
[![Vision](https://img.shields.io/badge/Vision-Hand%20Pose-purple.svg)](https://developer.apple.com/documentation/vision)
[![SpriteKit](https://img.shields.io/badge/SpriteKit-2D%20Engine-brightgreen.svg)](https://developer.apple.com/documentation/spritekit)

> **M.O.O.V.N.I.** é um jogo arcade retrô *hands-free* desenvolvido nativamente para macOS. O aplicativo combina **Visão Computacional em tempo real** e **Machine Learning (Core ML)** para permitir que o jogador resgate vacas e porquinhos prestes a serem abduzidos por naves alienígenas — tudo desenhando gestos espaciais com os dedos no ar, sem tocar no teclado ou mouse!

---

## 🎮 Como Funciona o Jogo

Um OVNI alienígena sobrevoa um pasto 2D dinâmico e projeta seu feixe de abdução sobre os animais da fazenda (vacas malhadas, vacas marrons e porquinhos). 

Cada nave exibe o **símbolo do gesto espacial** necessário para desligar seu feixe trator. O jogador deve:
1. **Juntar o polegar e o indicador (gesto de pinça 👌)** para ativar a caneta espacial virtual.
2. **Desenhar o gesto correspondente no ar** com a mão (esquerda ou direita).
3. Ao reconhecer o gesto com alta precisão, o feixe do OVNI se apaga e o animal cai em segurança no pasto, somando **+100 pontos**!

---

## ✍️ Gestos Suportados pela IA

O modelo próprio treinado via **Create ML** reconhece 6 gestos espaciais em uma janela deslizante (*Sliding Window*) de 60 quadros:

| Gesto | Símbolo | Cor do Feixe / Badge | Descrição |
| :--- | :---: | :---: | :--- |
| **Quadrado** | `◻` | Cyan `#00E5FF` | Desenhe 4 lados retos no ar |
| **Círculo** | `◯` | Magenta `#E040FB` | Desenhe uma volta redonda |
| **Triângulo** | `△` | Laranja `#FF9100` | Desenhe um triângulo com 3 pontas |
| **Letra V** | `V` | Verde `#00E676` | Movimento rápido em V |
| **Letra Z** | `Z` | Amarelo `#FFD600` | Desenhe um Z contínuo no ar |
| **Infinito** | `∞` | Rosa `#FF1744` | Desenhe um laço em 8 deitado |

---

## 🌟 Principais Funcionalidades

- 👁️ **Visão Computacional a 30 FPS (`Vision` Framework):** Mapeamento em tempo real dos 21 pontos anatômicos da mão (`VNHumanHandPoseObservation`) via câmera do Mac ou Câmera de Continuidade (iPhone).
- 🧠 **Inferência Core ML em Tempo Real:** Modelo `HandGestureClassifier.mlmodel` com pré-processamento de *sliding window*, limiares dinâmicos de confiança e desacoplamento de concorrência (`autoreleasepool`).
- 🎮 **SpriteKit 2D Engine:** Pasto interativo de 60 FPS com animações em pixel art, máquina de estados para animais (caminhar, parar, dormir), feixe pulsante com partículas e efeito parallax.
- 🎙️ **Integração com Siri & App Intents:** Suporte a atalhos nativos do macOS (`AppShortcutsProvider`). Diga *"E aí Siri, iniciar resgate no MOOVNI"* para entrar direto no jogo.
- ⏸️ **Modo "Prompt Waiter":** Recurso de pausa rápida desenhado para quem está aguardando o processamento de respostas longas em IAs (como ChatGPT/Claude). Permite jogar uma partida de 1 a 3 minutos enquanto a IA responde!
- 🎵 **Trilha & Efeitos Chiptune:** Músicas e sons retrô 8-bit com controles independentes de áudio e salvamento automático em `UserDefaults`.
- 🔒 **Privacidade 100% On-Device:** Nenhuma imagem da câmera é gravada ou enviada para a internet. Todo o processamento ocorre exclusivamente dentro da memória do Mac.

---

## 🏗️ Arquitetura & Tecnologias

O projeto adota a arquitetura **MVVM (Model-View-ViewModel)** com **Service Pattern** e segue a metodologia **Spec-Driven Development (SDD)**:

```
AIChallenge/
├── AIChallengeApp.swift            # Ponto de entrada e manipulador de App Intents
├── Models/                         # Modelos de dados (GestureType, GameState, AbductionTarget)
├── Services/
│   ├── VisionService.swift         # Captura de câmera AVFoundation + Vision Hand Pose
│   ├── CoreMLService.swift         # Pipeline de inferência com HandGestureClassifier
│   └── SoundService.swift          # Gerenciamento de áudio BGM e SFX
├── ViewModels/
│   └── CowsGameViewModel.swift     # Regras de negócio, pontuação, timers e estado
├── Views/
│   ├── CowsGameView.swift          # Overlay SwiftUI, HUD de pontuação e modais
│   ├── CowsGameScene.swift         # Cena 2D SpriteKit (pasto, vacas, naves e animações)
│   ├── CowsMenuScene.swift         # Menu inicial interativo em SpriteKit
│   └── GesturesGuideModalView.swift# Modal explicativo de gestos
└── Intents/
    └── MOOVNIIntents.swift         # AppIntents para Siri e Atalhos do macOS
```

### Spec-Driven Development (SDD)
Todas as especificações técnicas, modelos de dados e planos de execução estão documentados na pasta `docs/sdd/`:
- [`SpriteKit_CowsGame_Spec.md`](docs/sdd/SpriteKit_CowsGame_Spec.md): Especificação completa do pasto e motor 2D.
- [`AppIntents_MOOVNI_Spec.md`](docs/sdd/AppIntents_MOOVNI_Spec.md): Integração com Siri e comandos de voz.
- [`AudioSettings_Spec.md`](docs/sdd/AudioSettings_Spec.md): Especificação do sistema de som.
- [`VisualRefinements_Spec.md`](docs/sdd/VisualRefinements_Spec.md): Guia de UX e refinamentos visuais.

---

## 🚀 Como Executar o Projeto

1. **Requisitos:**
   - Mac com **macOS 13.0 (Ventura)** ou superior (suporta chips Apple Silicon M1/M2/M3/M4 e Intel).
   - **Xcode 15.0** ou superior.
   - Câmera integrada do Mac ativa ou Câmera de Continuidade com iPhone.

2. **Passos:**
   ```bash
   git clone https://github.com/Leleoh/AIChallenge.git
   cd AIChallenge
   open AIChallenge.xcodeproj
   ```
3. No Xcode, selecione o target **My Mac** e pressione `Cmd + R` para compilar e rodar.
4. Na primeira execução, autorize o acesso à **Câmera** quando solicitado.
5. No menu principal, clique em **COMO JOGAR** para ver os gestos ou clique em **INICIAR RESGATE** para começar a jogar!

---

## 👨‍💻 Autor

Desenvolvido por **Leonel Ferraz Hernandez**  
- 🎓 Estudante de Engenharia de Computação (UFRGS) & Desenvolvedor iOS na Apple Developer Academy.
- 🔗 Portfolio: [Leleoh.github.io](https://leonelhernandez.com.br)
