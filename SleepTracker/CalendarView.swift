//
//  CalendarView.swift
//  SleepTracker
//
//  Created by Timur on 7/6/24.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: true)],
        animation: .default)
    private var sleepRecords: FetchedResults<SleepRecord>
    
    @State private var selectedDate: Date? = nil
    private let qualityEmojis = ["😡", "😠", "🙂", "😀", "😍"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    CustomCalendarView(sleepRecords: sleepRecords, selectedDate: $selectedDate)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()

                    if let selectedDate = selectedDate {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            if let recordsForSelectedDate = recordsForDate(selectedDate) {
                                ForEach(recordsForSelectedDate) { record in
                                    SleepRecordDetailView(record: record, qualityEmojis: qualityEmojis)
                                        .padding(.horizontal)
                                }
                            } else {
                                Text("No sleep records for this date.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                        .padding()
                    } else {
                        Text("Please select a date to view sleep records.")
                            .foregroundColor(.white)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Calendar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .padding(.top, 80)
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    private func recordsForDate(_ date: Date) -> [SleepRecord]? {
        return sleepRecords.filter { Calendar.current.isDate($0.date!, inSameDayAs: date) }
    }
}


struct CustomCalendarView: View {
    let sleepRecords: FetchedResults<SleepRecord>
    @Binding var selectedDate: Date?
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }
    
    @State private var currentMonth: Date = Date()
    
    private let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            let daysInMonth = generateDaysInMonth(for: currentMonth)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .background(Color.white.opacity(0.9))
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    let qualityColor = getColor(for: date)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .padding()
                        .background(qualityColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(date == selectedDate ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var current = firstWeek.start
        
        while current < monthInterval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        return days
    }
    
    private func getColor(for date: Date) -> Color {
        if let record = sleepRecords.first(where: { Calendar.current.isDate($0.date!, inSameDayAs: date) }) {
            switch record.quality {
            case 1:
                return Color.red.opacity(0.5)
            case 2:
                return Color.orange.opacity(0.5)
            case 3:
                return Color.yellow.opacity(0.5)
            case 4:
                return Color(red: 0.5, green: 0.75, blue: 0, opacity: 0.3)
            case 5:
                return Color.green.opacity(0.5)
            default:
                return Color.clear
            }
        }
        return Color.clear
    }
}

struct SleepRecordDetailView: View {
    let record: SleepRecord
    let qualityEmojis: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Sleep Duration: \(sleepDuration(record))")
                .font(.headline)
                .foregroundColor(.yellow)
            
            Text("Sleep Time: \(formattedTime(record.sleepTime!))")
                .foregroundColor(.white)
            
            Text("Wake Time: \(formattedTime(record.wakeTime!))")
                .foregroundColor(.white)
            
            Text("Quality: \(qualityEmojis[Int(record.quality) - 1])")
                .foregroundColor(.white)
            
            Text("Notes: \(record.notes ?? "")")
                .foregroundColor(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .cornerRadius(10)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func sleepDuration(_ record: SleepRecord) -> String {
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: record.sleepTime!)!
        _ = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: record.wakeTime!.addingTimeInterval(86400))!
        
        let adjustedSleepTime = record.sleepTime! < startTime ? record.sleepTime!.addingTimeInterval(86400) : record.sleepTime!
        let adjustedWakeTime = record.wakeTime! < startTime ? record.wakeTime!.addingTimeInterval(86400) : record.wakeTime!
        
        let sleepDuration = adjustedWakeTime.timeIntervalSince(adjustedSleepTime)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        
        return formatter.string(from: sleepDuration) ?? "0h 0m"
    }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    CalendarView()
}
