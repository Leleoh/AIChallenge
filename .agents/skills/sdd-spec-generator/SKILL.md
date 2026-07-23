---
name: sdd-spec-generator
description: Skill to generate a Spec-Driven Development (SDD) markdown specification based on user requests, utilizing the project's SPEC_TEMPLATE.md.
---

# SDD Spec Generator Skill

## Context
You are tasked with generating a feature specification document as part of "Fase 2: Design" from the SDD workflow defined in this project.

## Trigger
Use this skill when the user asks to "create a spec", "design a feature", "generate a specification", or transition from Phase 1 to Phase 2 of the SDD process.

## Instructions
1. **Read the Template**: Before generating any specification, you MUST read the template file located at `docs/sdd/SPEC_TEMPLATE.md` to ensure you follow the exact structure required.
2. **Review Phase 1 Inputs**: Ensure you have gathered all necessary requirements from the user (Fase 1: Specify). Se os requisitos ainda estiverem muito vagos, faça perguntas antes de gerar o documento.
3. **Draft the Specification**: Create a new markdown file in the `docs/sdd/` directory. The filename should be descriptive, e.g., `NomeDaFeature_Spec.md`.
4. **Follow the Template Strictly**: Use exactly the sections defined in `SPEC_TEMPLATE.md`. Do not invent new sections unless explicitly requested by the user.
5. **Architectural Consistency**: Ensure the proposed design adheres to the project's standard architecture (SwiftUI, MVVM, `@Observable`, and patterns like CoreML when applicable).
6. **Testing and Changelog**: Preencha com cuidado as seções recém-adicionadas "Estratégia de Testes" (QA Strategy) e inicie a tabela do "Histórico de Revisões" (Changelog).
7. **Request Approval**: Always present the generated specification to the user and explicitly ask for their approval before moving to Phase 3 (Tasks), as mandated by the `AGENTS.md` rules.

## Output Format
- Generate the file directly in the `docs/sdd/` folder.
- Alert the user that the file has been created and is ready for their review.
