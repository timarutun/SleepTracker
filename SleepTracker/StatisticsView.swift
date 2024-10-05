//
//  StatisticsView.swift
//  SleepTracker
//
//  Created by Timur on 6/29/24.
//

import SwiftUI
import CoreData
import Charts

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"
}

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedPeriod: TimePeriod = .allTime
    @FetchRequest private var sleepRecords: FetchedResults<SleepRecord>
    
    init() {
        let request: NSFetchRequest<SleepRecord> = SleepRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)]
        _sleepRecords = FetchRequest(fetchRequest: request)
    }
    
    var filteredRecords: [SleepRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            return sleepRecords.filter { $0.date! >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return sleepRecords.filter { $0.date! >= monthAgo }
        case .allTime:
            return Array(sleepRecords)
        }
    }
    
    var body: some View {
        let averageQuality = filteredRecords.isEmpty ? 0 : Double(filteredRecords.map { $0.quality }.reduce(0, +)) / Double(filteredRecords.count)
        let sleepSatisfaction = (averageQuality / 5.0) * 100
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Overall Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 30)
                    .foregroundColor(.white)
                
                Picker("Time Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                SleepSatisfactionChart(satisfaction: sleepSatisfaction)
                    .frame(height: 200)
                    .padding(.bottom, 50)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Average Sleep Quality:")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Average Sleep Duration:")
                                .font(.headline)
                                .foregroundColor(.white)
                            if !filteredRecords.isEmpty {
                                Text("Your Optimal Sleep Duration:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("\(String(format: "%.1f", averageQuality))")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.yellow)
                            
                            if !filteredRecords.isEmpty {
                                let totalDuration = filteredRecords.map { $0.wakeTime!.timeIntervalSince($0.sleepTime!) }.reduce(0, +)
                                let averageDuration = totalDuration / Double(filteredRecords.count)
                                let averageDurationHours = Int(averageDuration) / 3600
                                let averageDurationMinutes = (Int(averageDuration) % 3600) / 60
                                
                                Text("\(averageDurationHours)h \(averageDurationMinutes)m")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.yellow)
                                
                                let optimalDuration = optimalSleepDuration(for: filteredRecords)
                                if let optimalDuration = optimalDuration {
                                    let hours = Int(optimalDuration) / 3600
                                    let minutes = (Int(optimalDuration) % 3600) / 60
                                    Text("\(hours)h \(minutes)m")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.yellow)
                                } else {
                                    Text("N/A")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Text("N/A")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                Spacer()
            }
        }
    }
    
    private func optimalSleepDuration(for records: [SleepRecord]) -> TimeInterval? {
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
                .stroke(.yellow, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeOut, value: satisfaction)
            VStack {
                Text("Satisfaction:")
                    .font(.title2)
                    .foregroundColor(.white)
                Text(String(format: "%.1f%%", satisfaction))
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
                .bold()
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
