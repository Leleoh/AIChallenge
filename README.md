# 🎈 Magic Therapy (AI Challenge)

**Magic Therapy** é um aplicativo macOS gamificado focado em ML. O projeto utiliza a câmera do dispositivo em conjunto com Inteligência Artificial para rastrear movimentos e gestos das mãos no ar, permitindo que os usuários interajam com elementos virtuais (como estourar balões e desenhar formas) de maneira divertida. No futuro pretende-se expandir para uso fisioterapeutico.

---

## 🌟 Principais Funcionalidades

- **Rastreamento de Mãos em Tempo Real:** Utiliza a câmera do Mac e o framework `Vision` para mapear os pontos anatômicos das mãos (`VNHumanHandPoseObservation`) com alta precisão e sem necessidade de sensores externos (como luvas ou controles).
- **Reconhecimento de Trajetórias (CoreML):** Integração avançada com **CoreML** rodando em uma janela de análise contínua (*Sliding Window* de 60 frames) para prever e entender formas desenhadas no ar pelo usuário.
- **Gamificação Fisioterápica:** Sistema de *spawn* de alvos (balões) baseados em gestos específicos, gerando engajamento e transformando exercícios monótonos em um jogo.
- **Alta Performance:** Processamento de câmera em tempo real (`AVFoundation`) com injeção direta de memória e ponteiros (`Float32`) no pipeline de Machine Learning, garantindo análise fluida e preditiva.

## Tecnologias e Arquitetura

O projeto foi construído seguindo padrões arquiteturais modernos do ecossistema Apple e impulsionado por uma abordagem **Spec-Driven Development (SDD)**.

- **Linguagem:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Arquitetura:** MVVM (Model-View-ViewModel) + Service Pattern
- **Gerenciamento de Estado:** Macro `@Observable`
- **Machine Learning & Visão Computacional:** `CoreML`, `Vision`, `AVFoundation`

### Spec-Driven Development (SDD)
Este repositório atua como um laboratório prático para o SDD. Antes de qualquer linha de código ser escrita, as funcionalidades são rigorosamente documentadas na pasta `docs/sdd/`. Estas especificações em formato Markdown atuam como a "Fonte da Verdade" (Source of Truth) do projeto. Assistentes de IA são então guiados (usando o fluxo customizado na pasta `.agents/`) para codificar e refatorar a arquitetura seguindo estritamente estes contratos.

## Como Executar o Projeto

1. Clone este repositório.
2. Abra o arquivo `AIChallenge.xcodeproj` no **Xcode** (requer Xcode 15 ou superior).
3. Selecione o seu Mac como target (macOS).
4. Rode o projeto (`Cmd + R`). O macOS solicitará a permissão de acesso à **Câmera** na primeira execução.
5. Para focar nos testes de ML, navegue pelo app até a tela de Sandbox (se disponível) para testar os desenhos no ar em tempo real.

