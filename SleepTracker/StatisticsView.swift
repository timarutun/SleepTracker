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
        VStack(alignment: .leading) {
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
            }
        }
        .padding()
    }
    
    private func averageTime(for dates: [Date]) -> Date {
        let totalTimeInterval = dates.map { $0.timeIntervalSinceReferenceDate }.reduce(0, +)
        let averageTimeInterval = totalTimeInterval / Double(dates.count)
        return Date(timeIntervalSinceReferenceDate: averageTimeInterval)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
