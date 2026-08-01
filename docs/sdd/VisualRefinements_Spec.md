# 📱 Especificação da Funcionalidade: Refinamentos Visuais e UX do Pasto e Telas

> **Status:** Aprovado (Fase 2 - Design v1.0)
> **Data:** 30/07/2026
> **Módulo:** SpriteKit / SwiftUI / CowsGameScene / CowsGameView

---

## 1. Visão Geral (Overview)
Implementação de refinamentos visuais de profundidade no pasto (sombras projetadas abaixo das vacas e porcos), padronização dimensional de botões no menu principal, reordenação de ações no modal de Game Over e ampliação tipográfica no modal de instrução dos gestos.

---

## 2. Componentes e Regras de UI

### 2.1. Sombras dos Animais (`CowsGameScene.swift`)
- Cada nó de animal (`cowNode`) recebe uma sombra oval inferior (`SKShapeNode(ellipseOf: ...)`) com tom escuro e opacidade reduzida (`alpha: 0.35`).
- A sombra é anexada ou vinculada ao movimento do animal (`zPosition: 3`, abaixo do nó do animal que tem `zPosition: 4`).
- Durante o resgate/abdução, a sombra esmaece ou permanece no chão enquanto o animal é elevado pelo feixe do OVNI.

### 2.2. Padronização dos Botões do Menu (`CowsGameView.swift` -> `menuOverlayView`)
- Ambos os botões ("INICIAR RESGATE" e "COMO JOGAR (GESTOS)") terão altura idêntica padronizada `height: 54`.

### 2.3. Reordenação do Game Over (`CowsGameView.swift` -> `gameOverOverlayView`)
- Troca de posição dos botões de ação:
  1. Superior: *"Voltar ao Menu"* (Fundo cinza).
  2. Inferior: *"Jogar Novamente"* (Fundo verde).

### 2.4. Aumento Tipográfico do Guia de Gestos (`GesturesGuideModalView.swift`)
- O texto de instrução chave ("Junte o Polegar e o Indicador 👌...") ganha destaque tipográfico elevado (`font(.headline)` / `font(.title3)`).

---

## 3. Histórico de Revisões (Changelog)

| Data | Versão | Autor | Descrição das Alterações |
|---|---|---|---|
| 30/07/2026 | 1.0 | Leonel / AI | Especificação inicial dos refinamentos de sombra, botões e tipografia. |
