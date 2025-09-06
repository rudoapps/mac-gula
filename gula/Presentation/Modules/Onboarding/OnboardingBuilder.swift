import SwiftUI

struct OnboardingBuilder {
    static func build(onSetupComplete: @escaping () -> Void) -> some View {
        let view = OnboardingView()
        view.viewModel.onSetupComplete = onSetupComplete
        return view
    }
}