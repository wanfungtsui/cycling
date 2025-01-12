import Charts
import SwiftUI

/// A reusable bar chart view with a title and customizable data.
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
                .font(.custom("Jersey15-Regular", size: 15))
            // Bar chart
            Chart {
                ForEach(data, id: \.index) { item in
                    BarMark(
                        x: .value("Index", item.index),  // X-axis value
                        y: .value("Value", item.value)   // Y-axis value
                    )
                    //.barwidth(0.85)
                    .foregroundStyle(Color.primaryLight()) // Alternate bar color
                    .annotation(position: .top) {      // Value annotation above each bar
                        Text("\(Int(item.value))")
                            .font(.custom("Jersey15-Regular", size: 15))
                            .foregroundColor(Color.primaryLight())
                    }
                }
            }
            // Configure Y-axis
            .chartYScale(domain: minValue...maxValue)   // Set dynamic Y-axis range
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    //AxisGridLine()                     // Add grid lines
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
            .background(Color.backgroundLight())
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
                (index: 4, value: 22.0),
                (index: 5, value: 16.0)
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
