import SwiftUI

// Row component for displaying a metric with an icon
struct MetricRow: View {
    let icon: String  // Icon name
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textDark()) // Set icon to medium size and heavy weight
                .symbolRenderingMode(.palette)

            Text(title)
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textDark())

            Spacer()
            Text(value)
                .bold()
                .font(.custom("Jersey15-Regular", size: 25))
                .foregroundColor(Color.backgroundLight())
        }
    }
} 