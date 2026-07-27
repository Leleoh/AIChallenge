# 📱 Especificação da Funcionalidade: Game Loop de Abdução de Vacas com Gestos CoreML

> **Status:** Aprovado (Fase 2 - Design v1.2)
> **Data:** 27/07/2026
> **Módulo:** Game Loop / SpriteKit / CoreML / SwiftUI

---

## 1. Visão Geral (Overview)
Substituição da mecânica de estourar orbs por um **Game Loop de Abdução Alienígena de Vacas**, no qual discos voadores (UFOs) surgem na cena e perseguem vacas que estão no pasto. O jogo inclui contagem regressiva inicial (3...2...1), vacas dormindo que "acordam" e entram em pânico ao serem capturadas, feixe trator neon com gradiente suave sem bordas duras e ciclo dinâmico de Dia e Noite.

---

## 2. Requisitos (Requirements)

- **O que deve ter:** 
  - **Contagem Regressiva Inicial (3, 2, 1, JÁ!)**: Overlay em SwiftUI exibido antes das naves começarem a surgir, preparando o jogador.
  - **Troca de Estado "Dormir -> Acordar -> Dormir"**:
    - A vaca dormindo (`VacaMalhadaDormindo`) altera dinamicamente sua animação para em pé/caminhando (`VacaMalhadaCaminhando`) assim que o feixe trator trava nela.
    - Se a vaca for **resgatada com sucesso**, ao pousar no solo ela retorna ao estado dormindo (`VacaMalhadaDormindo`).
  - **Feixe Trator Suavizado (Soft Gradient Beam)**:
    - Linhas de contorno duras removidas (`strokeColor = .clear`).
    - Gradiente vertical de opacidade (fade de 0.60 no topo da nave até 0.05 rente ao pasto), dissolvendo o feixe suavemente na grama.
  - **Ciclo Dia e Noite Dinâmico**:
    - Camada de ajuste visual (`dayNightOverlayNode`) que escurece suavemente o céu e o pasto em tons azulados/roxos com o passar do tempo.
    - Destaque intenso dos raios neon e badges dos OVNIs durante o período noturno.
  - **OVNIs Perseguidores (`Target Tracking`)**: Naves acompanham suavemente o eixo X da vaca em movimento.
  - **Mecânica de Resgate & Falha**: 4.5 segundos por abdução; 3 Vidas iniciais.

- **O que NÃO deve ter (Não-Escopo):**
  - Compras in-app ou modo multiplayer online.

---

## 3. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 27/07/2026 | 1.0 | Leonel / AI | Especificação inicial da arquitetura do Game Loop. |
| 27/07/2026 | 1.1 | Leonel / AI | Adicionado tracking de vacas caminhando, animação orgânica de OVNI e raio neon de camada dupla. |
| 27/07/2026 | 1.2 | Leonel / AI | Adicionada contagem regressiva (3,2,1), troca de sprite "Dormir -> Acordar", feixe trator com gradiente suave e ciclo dia/noite. |
