# 📱 Especificação da Funcionalidade: Cenário 2D Pixel Art em SpriteKit (Abdução de Vacas)

> **Status:** Aprovado / Implementado (Fase 4 - Execute v4.0)
> **Data:** 25/07/2026
> **Módulo:** SpriteKit / Assets / UI (Game Scene)

---

## 1. Visão Geral (Overview)
Adição de animação do sprite da vaca (`VacaMalhadaCaminhando`) sobre a camada de pasto, alternando entre os 5 frames de caminhada e movimentando a vaca horizontalmente pelo cenário.

---

## 2. Requisitos (Requirements)

- **O que deve ter:**
  - **Animação de Caminhada (5 Frames)**: Carregar as texturas `VacaMalhadaCaminhando1` até `VacaMalhadaCaminhando5` com `filteringMode = .nearest`.
  - **Loop de Animação**: Executar `SKAction.animate(with: textures, timePerFrame: 0.15)` em loop infinito.
  - **Movimentação no Pasto**: Posicionar a vaca no primeiro plano (`zPosition = 4`), caminhando suavemente da esquerda para a direita no pasto.
  - **Limpeza de Alpha 1-Bit**: Preservar bordas 1-bit secas sem contorno branco nos sprites da vaca.

---

## 3. Arquitetura e Padrões (Architecture & Patterns)

- **Engine:** SpriteKit (`CowsGameScene`)
- **Node:** `vacaNode` (`SKSpriteNode`) adicionado ao `gameLayer` em `zPosition = 4`.
- **Animação:** `SKAction.repeatForever(SKAction.animate(...))`

---

## 4. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 25/07/2026 | 1.0 | Leonel / AI | Especificação inicial da cena SpriteKit. |
| 25/07/2026 | 2.0 | Leonel / AI | Limpeza de transparência 1-bit nos PNGs. |
| 25/07/2026 | 3.0 | Leonel / AI | Arquitetura de Container Node (`gameLayer`) + Aspect Fill manual. |
| 25/07/2026 | 4.0 | Leonel / AI | Adição da vaca animada (`VacaMalhadaCaminhando` 1..5) caminhando no pasto. |

---
