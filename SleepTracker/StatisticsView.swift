//
//  StatisticsView.swift
//  SleepTracker
//
//  Created by Timur on 6/29/24.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)],
        animation: .default)
    private var sleepRecords: FetchedResults<SleepRecord>
    
    var body: some View {
        VStack {
            Text("Overall Statistics")
                .font(.largeTitle)
                .padding()
            
            Text("Total Sleep Records: \(sleepRecords.count)")
            
            let averageQuality = sleepRecords.isEmpty ? 0 : Double(sleepRecords.map { $0.quality }.reduce(0, +)) / Double(sleepRecords.count)
            Text("Average Sleep Quality: \(String(format: "%.1f", averageQuality))")
            
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
        .padding()
    }
    
    private func optimalSleepDuration(for records: FetchedResults<SleepRecord>) -> TimeInterval? {
        guard !records.isEmpty else { return nil }
        
        // Filtred only records with 4 and 5 quality
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
        
        // Calculate avarage sleep duration
        return totalWeight == 0 ? nil : totalDuration / totalWeight
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
