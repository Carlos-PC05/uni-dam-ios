import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.access {
            case .checking:
                ZStack {
                    VestaTheme.cream.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(VestaTheme.forest)
                        Text("Comprobando tu sesión…")
                            .foregroundStyle(VestaTheme.ink)
                    }
                }
            case .signedOut:
                AuthFlowView()
            case .incomplete:
                CompleteProfileView()
            case .ready:
                if let profile = model.profile, let finance = model.finance {
                    MainTabView(profile: profile, finance: finance)
                } else {
                    AuthFlowView()
                }
            }
        }
        .tint(VestaTheme.forest)
    }
}
