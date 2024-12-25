import SwiftUI
import Charts

struct ChartView: View {
    let title: String // Title of the chart
    let data: [(index: Int, value: Double)] // Data points for the chart
    let color: Color // Color for the chart line and points
    
    var body: some View {
        // Calculate max and min values for Y-axis scaling
        let maxValue = (data.map { $0.value }.max() ?? 0) + 5
        let minValue = max((data.map { $0.value }.min() ?? 0) - 5, 0)
        
        // Create an array of values for the Y-axis marks
        let yAxisValues = Array(stride(from: minValue, through: maxValue, by: (maxValue - minValue) / 4))
        
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            
            Chart {
                ForEach(data, id: \.index) { item in
                    // Line for the chart
                    LineMark(
                        x: .value("Session", item.index),
                        y: .value("Value", item.value)
                    )
                    .interpolationMethod(.catmullRom) // Smooth curve
                    .foregroundStyle(color)
                    
                    // Points on the chart
                    PointMark(
                        x: .value("Session", item.index),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(50)
                    
                    // Data label for each point
                    PointMark(
                        x: .value("Session", item.index),
                        y: .value("Value", item.value)
                    )
                    .annotation(position: .top) {
                        Text("\(Int(item.value))")
                            .font(.caption)
                            .foregroundColor(color)
                    }
                }
            }
            .chartXAxis(.hidden) // Hide X-axis labels
            .chartYAxis {
                AxisMarks(position: .leading, values: yAxisValues) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let value = value.as(Double.self) {
                            Text("\(Int(value))")
                        }
                    }
                }
            }
            .chartYScale(domain: minValue...maxValue) // Set Y-axis scale
            .padding() // Add padding inside the chart
            .frame(height: 150) // Fixed height for the chart
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
} 