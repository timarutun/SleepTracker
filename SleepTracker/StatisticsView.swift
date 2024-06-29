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
            
        }
        .padding()
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

