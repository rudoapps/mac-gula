import SwiftUI

struct OnboardingBuilder {
    static func build(onSetupComplete: @escaping () -> Void) -> some View {
        let viewModel = OnboardingViewModel(onSetupComplete: onSetupComplete)
        return OnboardingView(viewModel: viewModel)
    }
}