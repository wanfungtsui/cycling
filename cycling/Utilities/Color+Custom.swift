import SwiftUI

extension Color {
    // Convert hex to Color
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Define your custom colors here
    static func textDark() -> Color {
        return Color(hex: "#100E13")  // Example hex color
    }

    static func textLight() -> Color {
        return Color(hex: "#786F66")  // Example hex color
    }

    static func backgroundLight() -> Color {
        return Color(hex: "#F6E6CC")  // Example hex color
    }
    static func primaryDark() -> Color {
        return Color(hex: "#742230")  // Example hex color
    }

    static func primaryLight() -> Color {
        return Color(hex: "#D5A553")  // Example hex color
    }

    static func secondaryDark() -> Color {
        return Color(hex: "#788A8E")  // Example hex color
    }

    static func secondaryLight() -> Color {
        return Color(hex: "#C4C4C4")  // Example hex color
    }
}
