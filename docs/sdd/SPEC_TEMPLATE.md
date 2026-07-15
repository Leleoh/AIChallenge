# 📱 Especificação da Funcionalidade: [Nome da Funcionalidade / App]

> **Status:** [Rascunho | Em Revisão | Aprovado | Implementado]
> **Data:** [Data de criação]

## 1. Visão Geral (Overview)
Descreva brevemente o que essa funcionalidade ou app faz, qual é o problema que ela resolve e qual o valor entregue ao usuário final.

## 2. Requisitos (Requirements)
- **O que deve ter:** 
  - [Ex: O usuário deve poder fazer login com a Apple (Sign in with Apple)]
  - [Ex: A lista de itens deve ser cacheada usando SwiftData]
- **O que NÃO deve ter (Não-Escopo):**
  - [Ex: Suporte para iPad nesta versão]

## 3. Arquitetura e Padrões (Architecture & Patterns)
- **Padrão de Projeto:** MVVM (Model-View-ViewModel)
- **UI Framework:** SwiftUI
- **Gerenciamento de Estado:** `@Observable` (Swift 5.9+) ou `ObservableObject`
- **Armazenamento:** [SwiftData / CoreData / UserDefaults]
- **Networking:** [URLSession / Alamofire]

## 4. Modelos de Dados (Data Models)
Defina como as estruturas/classes serão. Exemplo:

```swift
// Exemplo conceitual
struct Item: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
```

## 5. Estrutura de Telas / UI (Views)
Quais views precisamos criar? Como elas se conectam?

- **`HomeView`**: Tela principal, exibe uma `List` dos itens.
- **`DetailView`**: Tela de detalhes de um item, com campos de edição.
- **Componentes Reutilizáveis**: `PrimaryButton`, `ItemRow`.

## 6. Lógica de Negócio e Estados (ViewModels)
- **`HomeViewModel`**:
  - `items`: Array de Items.
  - `isLoading`: Booleano para estado de carregamento.
  - `func fetchItems()`: Chama o serviço para obter itens.
  - `func addItem(title: String)`: Valida e adiciona um novo item.

## 7. Casos Extremos e Tratamento de Erros (Edge Cases)
- O que acontece se o usuário estiver sem internet na HomeView?
  - *Comportamento:* Exibir um banner (Alert ou Toast) de "Sem Conexão" e carregar do cache.
- O que acontece se a lista estiver vazia?
  - *Comportamento:* Exibir uma view `EmptyStateView` com uma mensagem amigável e um botão de adicionar.

---
*Nota para a IA:* Ao implementar esta especificação, siga estritamente as decisões arquiteturais acima e informe se encontrar qualquer inconsistência antes de escrever o código.
