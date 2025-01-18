import Charts
import SwiftUI

/// A reusable smooth area chart view with a title and customizable data.
struct ChartView: View {
    let title: String                 // Title of the chart
    let data: [(index: Int, value: Double)] // Data points for the chart
    
    var body: some View {
        // Compute Y-axis range dynamically based on the data
        let maxValue = (data.map { $0.value }.max() ?? 0) + 5 // Add padding to max value
        let minValue = max((data.map { $0.value }.min() ?? 0) - 5, 0) // Prevent negative values

        VStack(alignment: .leading) {
            // Chart title
            Text(title)
                .font(.custom("Jersey15-Regular", size: 15))
                .foregroundColor(Color.textLight())
                .padding(.bottom, 2)
            // Smooth area chart
            Chart {
                ForEach(data, id: \.index) { item in
                    AreaMark(
                        x: .value("Index", item.index),  // X-axis value
                        y: .value("Value", item.value)   // Y-axis value
                    )
                    .interpolationMethod(.catmullRom) // Use Catmull-Rom for smooth curves
                    .foregroundStyle(Color.primaryLight().opacity(0.5)) // Set area color with opacity
                }
                ForEach(data, id: \.index) { item in
                    LineMark(
                        x: .value("Index", item.index),
                        y: .value("Value", item.value)
                    )
                    .interpolationMethod(.catmullRom) // Use Catmull-Rom for smooth curves
                    .foregroundStyle(Color.primaryLight()) // Line color
                }
            }
            // Configure Y-axis
            .chartYScale(domain: minValue...maxValue)   // Set dynamic Y-axis range
            // Configure X-axis to start from the first data point
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {                   // Format Y-axis labels
                        if let value = value.as(Double.self) {
                            Text("\(Int(value))")
                                .font(.custom("Jersey15-Regular", size: 15))
                                .foregroundColor(Color.textLight())
                        }
                    }
                }
            }
            // Hide X-axis labels
            .chartXAxis(.hidden)
            // Style the chart container
            .frame(height: 168)
            .padding(.horizontal)
        }
    }
}

// Preview for the ChartView with sample data
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(
            title: "Weekly Progress",
            data: [
                (index: 1, value: 12.0),
                (index: 2, value: 18.0),
                (index: 3, value: 14.5),
                (index: 4, value: 22.0)


            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
