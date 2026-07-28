# 📱 Especificação da Funcionalidade: Cena Única Contínua (Menu + Gameplay + Pausa)

> **Status:** Aprovado (Fase 2 - Design v1.2)
> **Data:** 27/07/2026
> **Módulo:** Menu Principal / Game Loop / SpriteKit / SwiftUI

---

## 1. Visão Geral (Overview)
Evolução da arquitetura do jogo **M.O.O.V.N.I.** para utilizar uma **Cena Única Contínua em SpriteKit (`CowsGameScene`)**. Ao iniciar a partida, não há troca brusca de tela nem recriação de nós: o título e os botões esmaecem suavemente (`fadeOut`), a contagem regressiva (3... 2... 1...) é exibida sobre o cenário existente e o jogo começa com os animais na mesma posição. Adicionada também a funcionalidade de **Menu de Pausa**.

---

## 2. Requisitos (Requirements)

- **O que deve ter:**
  - **Cena Única Contínua (`CowsGameScene`)**:
    - Gerencia os dois estados principais do jogo: `.menu` e `.playing` (além de `.paused` e `.gameOver`).
    - No estado `.menu`, os animais caminham no pasto, nuvens rolam em paralaxe e o título **M.O.O.V.N.I.** fica visível.
  - **Transição Suave (Sem Cortes ou Jumps)**:
    - Ao clicar em **"INICIAR RESGATE"**, o título e os botões esmaecem (`fadeOut(0.5s)`).
    - A contagem 3, 2, 1 aparece no centro da tela sobre o pasto contínuo.
    - O spawner de OVNIs é ativado e a câmera inicia a detecção sem recriar a cena.
  - **Botão de Pausa & Overlay de Pausa**:
    - Durante o gameplay, o botão superior exibe **"Pausar"** (ou ícone ⏸).
    - Ao pausar, a física e os timers do SpriteKit congelam (`scene.isPaused = true`).
    - Overlay de Pausa exibindo as opções: **"Continuar"** e **"Voltar ao Menu"**.
  - **Retorno Suave ao Menu**:
    - Ao selecionar **"Voltar ao Menu"** no modal de pausa, as naves ativas decolam e o título **M.O.O.V.N.I.** reaparece suavemente (`fadeIn`), sem crash.

---

## 3. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 27/07/2026 | 1.0 | Leonel / AI | Especificação inicial do Menu Principal CowreML. |
| 27/07/2026 | 1.1 | Leonel / AI | Atualizado título oficial do jogo para M.O.O.V.N.I. |
| 27/07/2026 | 1.2 | Leonel / AI | Especificação de Cena Única Contínua e Menu de Pausa. |
