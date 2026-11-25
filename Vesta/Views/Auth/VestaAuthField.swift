import SwiftUI

/// Campo oscuro sobre el panel verde de acceso, con etiqueta y error asociado.
struct VestaAuthField: View {
    let label: String
    @Binding var text: String
    var error: String?
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var capitalization: TextInputAutocapitalization = .never
    var isSecure = false

    @State private var visible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundStyle(VestaTheme.ink)

            HStack(spacing: 8) {
                Group {
                    if isSecure && !visible {
                        SecureField("", text: $text, prompt: prompt)
                    } else {
                        TextField("", text: $text, prompt: prompt)
                    }
                }
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .keyboardType(keyboard)
                .textContentType(textContentType)
                .foregroundStyle(VestaTheme.cream)
                .tint(VestaTheme.mint)
                .font(.body)
                .accessibilityLabel(label)

                if isSecure {
                    Button(visible ? "Ocultar" : "Mostrar") {
                        visible.toggle()
                    }
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.cream)
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(VestaTheme.forest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(error == nil ? Color.clear : VestaTheme.error, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.error)
            }
        }
    }

    private var prompt: Text {
        Text(label).foregroundColor(VestaTheme.cream.opacity(0.7))
    }
}
