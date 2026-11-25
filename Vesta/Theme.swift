import SwiftUI

/// Paleta de Vesta, tomada de la aplicación Android original.
enum VestaTheme {
    static let forest = Color(red: 47 / 255, green: 64 / 255, blue: 51 / 255)
    static let mint = Color(red: 165 / 255, green: 242 / 255, blue: 156 / 255)
    static let cream = Color(red: 241 / 255, green: 255 / 255, blue: 240 / 255)
    static let ink = Color(red: 32 / 255, green: 39 / 255, blue: 32 / 255)
    static let error = Color(red: 142 / 255, green: 23 / 255, blue: 37 / 255)
}

/// Botón principal con la forma y el contraste de la aplicación original.
struct VestaPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(VestaTheme.cream)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? VestaTheme.forest : VestaTheme.forest.opacity(0.45))
            )
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
