//
//  StatisticsView.swift
//  SleepTracker
//
//  Created by Timur on 6/29/24.
//

import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)],
        animation: .default)
    private var sleepRecords: FetchedResults<SleepRecord>
    
    var body: some View {
        
        let averageQuality = sleepRecords.isEmpty ? 0 : Double(sleepRecords.map { $0.quality }.reduce(0, +)) / Double(sleepRecords.count)
        
        let sleepSatisfaction = (averageQuality / 5.0) * 100
        
        VStack {
            Text("Overall Statistics")
                .font(.largeTitle)
                .padding(30)
            SleepSatisfactionChart(satisfaction: sleepSatisfaction)
                .frame(height: 200)
                .padding(.bottom, 50)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Total Sleep Records: \(sleepRecords.count)")
                
                
                Text("Average Sleep Quality: \(String(format: "%.1f", averageQuality))")
                Text("Sleep Satisfaction: \(String(format: "%.1f", sleepSatisfaction))%")
                
                
                if !sleepRecords.isEmpty {
                    let totalDuration = sleepRecords.map { $0.wakeTime!.timeIntervalSince($0.sleepTime!) }.reduce(0, +)
                    let averageDuration = totalDuration / Double(sleepRecords.count)
                    let averageDurationHours = Int(averageDuration) / 3600
                    let averageDurationMinutes = (Int(averageDuration) % 3600) / 60
                    
                    Text("Average Sleep Duration: \(averageDurationHours)h \(averageDurationMinutes)m")
                    
                    let optimalDuration = optimalSleepDuration(for: sleepRecords)
                    if let optimalDuration = optimalDuration {
                        let hours = Int(optimalDuration) / 3600
                        let minutes = (Int(optimalDuration) % 3600) / 60
                        Text("Optimal Sleep Duration: \(hours)h \(minutes)m")
                    } else {
                        Text("Not enough data to determine optimal sleep duration")
                    }
                }
            }
            .fontWeight(.medium)
            Spacer()
        }
    }
    
    private func optimalSleepDuration(for records: FetchedResults<SleepRecord>) -> TimeInterval? {
        guard !records.isEmpty else { return nil }
        
        // Filter only records with 4 and 5 quality
        let filteredRecords = records.filter { $0.quality == 4 || $0.quality == 5 }
        
        guard !filteredRecords.isEmpty else { return nil }
        
        // Total duration and total weight calculation
        var totalDuration: TimeInterval = 0
        var totalWeight: Double = 0
        
        for record in filteredRecords {
            let duration = record.wakeTime!.timeIntervalSince(record.sleepTime!)
            let weight = record.quality == 5 ? 2.0 : 1.0
            totalDuration += duration * weight
            totalWeight += weight
        }
        
        // Calculate average sleep duration
        return totalWeight == 0 ? nil : totalDuration / totalWeight
    }
}

struct SleepSatisfactionChart: View {
    let satisfaction: Double
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(min(satisfaction / 100.0, 1.0)))
                .stroke(satisfactionColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeOut, value: satisfaction)
            
            Text(String(format: "%.1f%%", satisfaction))
                .font(.largeTitle)
                .bold()
                .foregroundColor(satisfactionColor)
        }
    }
    
    private var satisfactionColor: Color {
        switch satisfaction {
        case 80...100:
            return .green
        case 60..<80:
            return .yellow
        default:
            return .red
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
