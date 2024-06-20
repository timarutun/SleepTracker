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
    @State private var quality: Double = 3
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add New Sleep Record")) {
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        DatePicker("Sleep Time", selection: $sleepTime, displayedComponents: .hourAndMinute)
                        DatePicker("Wake Time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        HStack {
                            Text("Quality")
                            Slider(value: $quality, in: 1...5, step: 1)
                        }
                        TextField("Notes", text: $notes)
                        Button(action: addSleepRecord) {
                            Text("Save Record")
                        }
                    }
                    
                    Section(header: Text("Sleep Records")) {
                        List {
                            ForEach(sleepRecords) { record in
                                VStack(alignment: .leading) {
                                    Text("Date: \(record.date!, formatter: dateFormatter)")
                                    SleepBarView(sleepTime: record.sleepTime!, wakeTime: record.wakeTime!)
                                    Text("Quality: \(record.quality)")
                                    Text("Notes: \(record.notes ?? "")")
                                }
                            }
                            .onDelete(perform: deleteSleepRecords)
                        }
                    }
                }
            }
            .navigationBarTitle("Sleep Tracker")
        }
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

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct SleepTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        SleepTrackerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


#Preview {
    SleepTrackerView()
}
