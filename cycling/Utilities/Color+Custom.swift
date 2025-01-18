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
        return Color(hex: "#F1FAEE")  // Example hex color
    }

    static func backgroundLight() -> Color {
        return Color(hex: "#23232C")  // Example hex color
    }
    static func primaryDark() -> Color {
        return Color(hex: "#F95A2C")  // Example hex color
    }

    static func primaryLight() -> Color {
        return Color(hex: "#FFBD12")  // Example hex color
    }

    static func secondaryDark() -> Color {
        return Color(hex: "#00C6AE")  // Example hex color
    }

    static func secondaryLight() -> Color {
        return Color(hex: "#E6E6E6")  // Example hex color
    }

    static func Palette1() -> Color {
        return Color(hex: "#E9E7FC")  // Example hex color
    }

    static func Palette2() -> Color {
        return Color(hex: "#FFF3F8")  // Example hex color
    }

    static func Palette3() -> Color {
        return Color(hex: "#FFF4CC")  // Example hex color
    }

    static func Palette4() -> Color {
        return Color(hex: "#D6FCF7")  // Example hex color
    }

    static func Palette5() -> Color {
        return Color(hex: "#FFE8E8")  // Example hex color
    }



static func randomPaletteColor(for index: Int) -> Color {
    let palettes: [Color] = [Palette1(), Palette2(), Palette3(), Palette4(), Palette5()]
    let remainder = index % palettes.count // Get the remainder when index is divided by the number of palettes
    return palettes[remainder]
}
}
