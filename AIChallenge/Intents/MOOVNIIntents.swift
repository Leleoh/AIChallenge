// Ref: docs/sdd/AppIntents_MOOVNI_Spec.md
import AppIntents
import SwiftUI

// MARK: - Notification Name Helper
extension Notification.Name {
    static let startMoovniGame = Notification.Name("startMoovniGame")
    static let startPromptWaiterGame = Notification.Name("startPromptWaiterGame")
}

// MARK: - Intent 1: Iniciar Resgate Padrão
struct StartResgateIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar Resgate de Vacas"
    static var description = IntentDescription("Abre o M.O.O.V.N.I. e inicia uma nova partida de resgate de vacas por gestos.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .startMoovniGame, object: nil)
        return .result()
    }
}

// MARK: - Intent 2: Consultar Recorde Atual
struct GetHighScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Ver Recorde Atual"
    static var description = IntentDescription("Consulta o maior recorde registrado no M.O.O.V.N.I.")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let currentHigh = UserDefaults.standard.integer(forKey: "cowsHighScore")
        let message: String
        if currentHigh > 0 {
            message = "Seu recorde atual no M.O.O.V.N.I. é de \(currentHigh) pontos! 🐮🛸"
        } else {
            message = "Você ainda não possui recorde registrado no M.O.O.V.N.I. Que tal iniciar uma partida agora?"
        }
        return .result(value: message)
    }
}

// MARK: - Intent 3: Prompt Waiter / Pausa da IA
struct QuickBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Pausa do Prompt"
    static var description = IntentDescription("Abre o M.O.O.V.N.I. para uma rodada rápida de descompressão enquanto você aguarda a resposta da IA.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .startPromptWaiterGame, object: nil)
        return .result()
    }
}

// MARK: - Provider de Atalhos para Siri & Spotlight
struct MOOVNIShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartResgateIntent(),
            phrases: [
                "Iniciar resgate no \(.applicationName)",
                "Resgatar vacas no \(.applicationName)",
                "Jogar \(.applicationName)"
            ],
            shortTitle: "Iniciar Resgate",
            systemImageName: "play.fill"
        )
        
        AppShortcut(
            intent: QuickBreakIntent(),
            phrases: [
                "Jogar enquanto a IA pensa no \(.applicationName)",
                "Pausa de prompt no \(.applicationName)",
                "Resgate rápido no \(.applicationName)"
            ],
            shortTitle: "Pausa do Prompt",
            systemImageName: "sparkles"
        )
        
        AppShortcut(
            intent: GetHighScoreIntent(),
            phrases: [
                "Qual meu recorde no \(.applicationName)",
                "Pontuação máxima no \(.applicationName)"
            ],
            shortTitle: "Ver Recorde",
            systemImageName: "trophy.fill"
        )
    }
}
