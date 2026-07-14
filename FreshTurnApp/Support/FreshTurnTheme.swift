import SwiftUI
import UIKit

enum FreshTurnTheme {
    static let oat = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let paper = Color(red: 1.00, green: 0.99, blue: 0.96)
    static let tomato = Color(red: 0.78, green: 0.20, blue: 0.13)
    static let leaf = Color(red: 0.18, green: 0.38, blue: 0.22)
    static let ink = Color(red: 0.16, green: 0.15, blue: 0.12)
    static let muted = Color(red: 0.39, green: 0.37, blue: 0.32)

    static let cardRadius: CGFloat = 18
    static let smallRadius: CGFloat = 10
}

struct ReceiptRule: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
            .foregroundColor(FreshTurnTheme.muted.opacity(0.45))
        }
        .frame(height: 1)
        .accessibilityHidden(true)
    }
}

struct PrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(FreshTurnTheme.tomato.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: FreshTurnTheme.smallRadius, style: .continuous))
    }
}

struct SecondaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundColor(FreshTurnTheme.leaf)
            .background(FreshTurnTheme.leaf.opacity(configuration.isPressed ? 0.14 : 0.08))
            .overlay(
                RoundedRectangle(cornerRadius: FreshTurnTheme.smallRadius, style: .continuous)
                    .stroke(FreshTurnTheme.leaf.opacity(0.45), lineWidth: 1)
            )
    }
}

extension View {
    func dismissFreshTurnKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
