# 📱 Especificação da Funcionalidade: Cenário 2D em SpriteKit (Abdução de Vacas)

> **Status:** Proposto (Fase 2 - Design)
> **Data:** 25/07/2026
> **Módulo:** SpriteKit / UI (Game Scene)

---

## 1. Visão Geral (Overview)
Transição do motor de renderização do jogo de SwiftUI puro para **SpriteKit (`SKScene` + `SpriteView`)**. Esta especificação define a criação do cenário base 2D utilizando as camadas de assets fornecidas (`Ceu`, `NuvensBranca`, `Relevo` e `Pasto`), preparando a estrutura para o futuro loop de abdução de vacas por OVNIs.

---

## 2. Camadas do Cenário (Z-Ordering & Nodes)

A cena do SpriteKit (`CowsGameScene`) será composta pelas seguintes camadas empilhadas:

| Camada | Asset Name | Node Type | Z-Position | Descrição / Comportamento |
|---|---|---|---|---|
| **1. Céu** | `Ceu` | `SKSpriteNode` | `0` | Fundo principal da cena, escalado para cobrir a tela inteira. |
| **2. Nuvens** | `NuvensBranca` | `SKSpriteNode` | `1` | Nuvens no topo/céu. Movimento sutil de paralaxe horizontal (drift contínuo). |
| **3. Relevo** | `Relevo` | `SKSpriteNode` | `2` | Montanhas/colinas de fundo posicionadas no terço médio. |
| **4. Pasto** | `Pasto` | `SKSpriteNode` | `3` | Chão/gramado no primeiro plano, base onde as vacas ficarão no futuro. |

---

## 3. Arquitetura do Componente

- **`CowsGameScene.swift` (`SKScene`)**:
  - Responsável por montar a hierarquia de `SKSpriteNode`s.
  - Ajuste dinâmico de tamanho (`didChangeSize`) para responsividade em qualquer resolução de janela do macOS (`scaleMode = .resizeFill` ou `.aspectFill`).
  - Animação simples de movimento horizontal para as nuvens.

- **`CowsGameView.swift` (SwiftUI View)**:
  - Encapsula a cena através de `SpriteView(scene: scene)`.
  - Permite sobrepor a camada de Visão/Câmera e HUD de pontuação futuramente via `ZStack`.

---

## 4. Plano de Tarefas (Tasks - Fase 3)

1. [ ] Criar a classe `CowsGameScene.swift` (`SKScene`).
2. [ ] Configurar o posicionamento e escala das 4 camadas (`Ceu`, `NuvensBranca`, `Relevo`, `Pasto`).
3. [ ] Adicionar movimento contínuo/paralaxe para as nuvens brancas.
4. [ ] Criar a view SwiftUI `CowsGameView.swift` com `SpriteView`.
5. [ ] Integrar a nova cena no `HomeView.swift` para visualização.

---

## 5. Histórico de Alterações (Changelog)
| Data | Versão | Autor | Descrição |
|---|---|---|---|
| 25/07/2026 | 1.0 | Leonel / AI | Criação da especificação da cena SpriteKit com as camadas Ceu, NuvensBranca, Relevo e Pasto. |
