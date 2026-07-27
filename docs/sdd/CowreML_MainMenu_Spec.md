# 📱 Especificação da Funcionalidade: Tela de Menu Inicial (M.O.O.V.N.I.)

> **Status:** Aprovado (Fase 2 - Design v1.1)
> **Data:** 27/07/2026
> **Módulo:** Menu Principal / UI SwiftUI / SpriteKit Scene

---

## 1. Visão Geral (Overview)
Criação da tela de Menu Inicial do jogo **M.O.O.V.N.I. (Moo-tion Operation & Vision Neural Interface)**. O menu combina uma cena SpriteKit animada ao fundo (cenário 8-Bit com vacas caminhando no pasto, nuvens em paralaxe e OVNI flutuando decorativamente) com uma interface SwiftUI limpa, moderna e responsiva na camada frontal.

---

## 2. Requisitos (Requirements)

- **O que deve ter:**
  - **Título 8-Bit Destacado**: Exibição do título principal **"M.O.O.V.N.I."** com o subtítulo neon **"MOO-TION OPERATION & VISION INTERFACE"**.
  - **Cenário de Fundo Animado (`CowsMenuScene`)**:
    - Reuso dos assets Pixel Art existentes (`Ceu`, `Relevo`, `Pasto`, `NuvensBranca`).
    - Nuvens deslizando em movimento paralaxe contínuo.
    - Vacas caminhando pelo pasto e vaca dormindo no centro.
    - OVNI decorativo flutuando no céu com feixe neon sutil.
  - **Botão Principal "JOGAR"**:
    - Inicia o Game Loop de abdução de vacas (`CowsGameView`).
  - **Modal "COMO JOGAR" (Guia de Gestos)**:
    - Exibe um modal pop-up visual mostrando os 6 gestos Mágicos CoreML (Quadrado ⏹, Círculo ⏺, Triângulo ▲, V, Z, Infinito ∞) e como usar a pinça da mão para desenhar.
  - **Placar de Recorde (High Score)**:
    - Exibição do recorde de vacas resgatadas via `@AppStorage("cowsHighScore")`.
  - **Integração com `HomeView`**:
    - Substituir a chamada direta em `HomeView.swift` para que a tela do menu **M.O.O.V.N.I.** seja a experiência inicial de abertura do jogo.

---

## 3. Arquitetura e Componentes (Architecture & Components)

```
AIChallenge/
  ├── Views/
  │   ├── CowsGameMenuView.swift       # View SwiftUI da Interface de Menu
  │   ├── CowsMenuScene.swift          # Scene SpriteKit do Fundo Animado
  │   └── GesturesGuideModalView.swift # Modal Guia Visual de Gestos CoreML
  └── ViewModels/
      └── CowsGameViewModel.swift      # ViewModel existente
```

---

## 4. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 27/07/2026 | 1.0 | Leonel / AI | Especificação inicial do Menu Principal CowreML. |
| 27/07/2026 | 1.1 | Leonel / AI | Atualizado título oficial do jogo para M.O.O.V.N.I. |
