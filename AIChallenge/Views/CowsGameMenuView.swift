// Ref: docs/sdd/CowreML_MainMenu_Spec.md
import SwiftUI

struct CowsGameMenuView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        CowsGameView(isPresented: $isPresented)
    }
}
