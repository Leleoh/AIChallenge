# 📱 Especificação da Funcionalidade: Magic Therapy - CoreML Gestures (Desenho no Ar)

> **Status:** Em Revisão (Fase 2)
> **Data:** 16/07/2026

## 1. Visão Geral (Overview)
Expansão do MVP atual do *Magic Therapy* para introduzir o reconhecimento de trajetórias complexas (desenhar formas no ar como quadrados, círculos, etc.) usando Inteligência Artificial (CoreML). O objetivo é fornecer uma mecânica mais refinada e aplicável à fisioterapia, permitindo medir a amplitude e coordenação dos movimentos.

## 2. Requisitos (Requirements)
- **O que deve ter:** 
  - **Modo Sandbox/Coleta:** Um modo específico no app para testar o modelo CoreML e extrair dados, se necessário.
  - **Gatilho de Desenho:** Uso de um gesto de gatilho (ex: Pinça / *Pinch*) para iniciar e finalizar a gravação da trajetória. 
  - **Integração com CoreML:** Uso de um modelo treinado (`.mlmodel` / `.mlpackage`) usando a estrutura nativa da Apple.
  - **Reconhecimento de Trajetórias (Ação):** O app deve analisar uma janela de frames no tempo (Time-Series) e não apenas um frame isolado.
- **O que NÃO deve ter (Não-Escopo):**
  - Integração imediata com o sistema de balões/poderes nesta primeira iteração (o foco é apenas a prova de conceito do CoreML).

## 3. Arquitetura e Padrões (Architecture & Patterns)
- **Padrão de Projeto:** MVVM + Service Pattern
- **UI Framework:** SwiftUI
- **Gerenciamento de Estado:** `@Observable`
- **Machine Learning:** CoreML, Create ML (ferramenta para treino de Action Classification), Vision (`VNHumanHandPoseObservation`).

## 4. Modelos de Dados (Data Models)
```swift
/// Representa o estado do desenho
enum DrawingState {
    case idle
    case drawing // O usuário está com a 'pinça' fechada
    case analyzing // O modelo CoreML está processando os frames
}

/// Representa a predição do CoreML
struct GesturePrediction {
    let label: String // ex: "Square", "Triangle", "Circle"
    let confidence: Double // ex: 0.95
}
```

## 5. Estrutura de Telas / UI (Views)
- **`CoreMLSandboxView`**: Nova tela dedicada para testes.
  - Fundo: Feed da câmera em tempo real.
  - Overlay: Uma linha (Path) desenhada na tela seguindo o dedo indicador enquanto o estado for `drawing`.
  - UI Superior: O rótulo da predição atual (ex: "Isso é um Quadrado (98%)").

## 6. Lógica de Negócio e Estados (ViewModels & Services)
- **`CoreMLService`**: 
  - Serviço responsável por carregar o modelo treinado e realizar predições.
- **`VisionService` (Atualização)**:
  - Precisará manter um *buffer* (histórico) dos últimos frames do movimento (uma Action).
  - Detectar quando os dedos se tocam (Pinça) para iniciar e terminar o desenho.
- **`SandboxViewModel`**:
  - Controla o `DrawingState`.
  - Gerencia o traçado visual na tela (`Path`).

## 7. Casos Extremos e Tratamento de Erros (Edge Cases)
- **Mão sai da tela durante o desenho:** O traçado deve ser cancelado automaticamente.
- **Modelo CoreML não encontrado:** Exibir um aviso amigável na tela informando que o modelo `.mlmodel` ainda não foi adicionado ao Xcode.
- **Baixa confiança:** Se a predição for inferior a um limite (ex: 60%), classificar como "Forma Desconhecida".
