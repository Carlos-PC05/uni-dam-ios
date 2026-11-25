import SwiftUI

/// Campo claro para los formularios privados.
struct VestaFormField: View {
    let label: String
    @Binding var text: String
    var error: String?
    var keyboard: UIKeyboardType = .default
    var footnote: String?
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int> = 1...1

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundStyle(VestaTheme.ink)

            TextField(
                "",
                text: $text,
                prompt: Text(label).foregroundColor(VestaTheme.ink.opacity(0.45)),
                axis: axis
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboard)
            .lineLimit(lineLimit)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 50, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        error == nil ? VestaTheme.forest.opacity(0.25) : VestaTheme.error,
                        lineWidth: 1
                    )
            )

            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.error)
            } else if let footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(VestaTheme.ink.opacity(0.65))
            }
        }
    }
}
