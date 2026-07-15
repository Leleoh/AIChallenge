# Spec-Driven Development (SDD) - Fluxo de Trabalho

O Spec-Driven Development (Desenvolvimento Guiado por Especificação) é uma metodologia muito eficaz ao trabalhar com assistentes de IA. Em vez de pedir para a IA "fazer um app X" e deixá-la "adivinhar" a arquitetura (o que gera código inconsistente), nós primeiro definimos um **contrato** (.md) claro.

## O Ciclo de Criação (Fluxo SDD)

1. **Fase de Concepção (Humano + IA na ideação):**
   - Você descreve o que quer fazer em linguagem natural.
   - Nós discutimos as regras de negócio, telas e fluxo de usuário.

2. **Fase de Especificação (Gerando os .md):**
   - Nós não escrevemos código ainda!
   - Baseado na nossa discussão, eu (a IA) gero ou atualizo um documento de especificação na pasta `docs/sdd/` usando o `SPEC_TEMPLATE.md`.
   - O documento conterá Arquitetura (ex: MVVM), Modelos de Dados, Telas (SwiftUI), e Regras de Negócio.
   - Você revisa esse arquivo `.md` e pede ajustes se necessário.

3. **Fase de Implementação (A IA codificando guiada pelo Spec):**
   - Com o documento aprovado, nós começamos o código.
   - Em vez de um prompt genérico, você me diz: *"Implemente a funcionalidade X exatamente como descrito em docs/sdd/Feature_X.md"*.
   - Eu leio o documento, sigo as restrições arquiteturais definidas e gero o código Swift/SwiftUI.

4. **Fase de Manutenção (Spec como Fonte da Verdade):**
   - Se os requisitos mudarem, nós **NÃO** mudamos o código primeiro.
   - Nós mudamos o arquivo `.md` primeiro.
   - Depois de alterar o `.md`, eu refatoro o código para refletir a nova especificação.

## Vantagens no Ecossistema Apple (iOS/SwiftUI)
- Evita que a IA misture UIKit com SwiftUI sem necessidade.
- Garante que a arquitetura (ex: MVVM com `@Observable` ou `ObservableObject`) seja consistente em todas as views.
- Mantém o projeto previsível e fácil de dar manutenção, além de gerar uma documentação viva para o seu projeto no Apple Developer Academy!
