//
//  SleepTrackerView.swift
//  SleepTracker
//
//  Created by Timur on 6/19/24.
//

import SwiftUI
import CoreData

struct SleepTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)],
        animation: .default)
    private var sleepRecords: FetchedResults<SleepRecord>
    
    @State private var selectedDate = Date()
    @State private var sleepTime = Date()
    @State private var wakeTime = Date()
    @State private var quality: Int = 3
    @State private var notes: String = ""
    @State private var showingDetailsFor: SleepRecord? = nil
    @State private var isShowingAddNewRecord = false
    
    private let qualityEmojis = ["😡", "😠", "🙂", "😀", "😍"]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sleepRecords) { record in
                        VStack(alignment: .leading) {
                            Button(action: {
                                if showingDetailsFor == record {
                                    showingDetailsFor = nil
                                } else {
                                    showingDetailsFor = record
                                }
                            }) {
                                HStack {
                                    Text(formattedDate(record.date!))
                                    Spacer()
                                    Text(sleepDuration(record))
                                }
                                .padding(.horizontal)
                                SleepBarView(sleepTime: record.sleepTime!, wakeTime: record.wakeTime!)
                            }
                            if showingDetailsFor == record {
                                Text("Quality: \(qualityEmojis[Int(record.quality) - 1])")
                                Text("Notes: \(record.notes ?? "")")
                            }
                        }
                        .foregroundStyle(Color(.label))
                    }
                    .onDelete(perform: deleteSleepRecords)
                }
            }
            .navigationBarTitle("Sleep Tracker")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddNewRecord.toggle()
            }) {
                Image(systemName: "plus")
            })
            .overlay(
                Group {
                    if isShowingAddNewRecord {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            Form {
                                Section(header: Text("Add New Sleep Record")) {
                                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                    DatePicker("Sleep Time", selection: $sleepTime, displayedComponents: .hourAndMinute)
                                    DatePicker("Wake Time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                                    
                                    HStack {
                                        ForEach(0..<5, id: \.self) { i in
                                            Button(action: {
                                                self.quality = i + 1
                                                print("q = \(quality), i = \(i)")
                                            }) {
                                                Text(qualityEmojis[i])
                                                    .font(.largeTitle)
                                                    .cornerRadius(10)
                                                    .foregroundColor(.white)
                                                    .background(quality == i + 1 ? Color.blue : Color.clear)
                                                    .clipShape(Circle())
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    TextField("Notes", text: $notes)
                                    Button(action: {
                                        addSleepRecord()
                                        isShowingAddNewRecord = false
                                    }) {
                                        Text("Save Record")
                                    }
                                }
                            }
                            .frame(width: 300, height: 400)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 20)
                            Button("Close") {
                                isShowingAddNewRecord = false
                            }
                            .padding()
                        }
                    }
                }
            )
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
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
    
    private func addSleepRecord() {
        withAnimation {
            let newRecord = SleepRecord(context: viewContext)
            newRecord.date = selectedDate
            newRecord.sleepTime = sleepTime
            newRecord.wakeTime = wakeTime
            newRecord.quality = Int16(quality)
            newRecord.notes = notes
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteSleepRecords(offsets: IndexSet) {
        withAnimation {
            offsets.map { sleepRecords[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct SleepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    SleepTrackerView()
}
