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
    @State private var isEditingRecord = false
    
    private let qualityEmojis = ["😡", "😠", "🙂", "😀", "😍"]
    
    var body: some View {
        TabView {
            mainView
                .tabItem {
                    Image(systemName: "bed.double.fill")
                    Text("Sleep Tracker")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Statistics")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
    }
    
    var mainView: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
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
                                            .foregroundColor(.black)
                                            .font(.headline)
                                            .padding(.leading)
                                        Spacer()
                                        Text(sleepDuration(record))
                                            .foregroundColor(.black)
                                            .font(.subheadline)
                                            .padding(.trailing)
                                    }
                                    .padding(.horizontal)
                                    SleepBarView(sleepTime: record.sleepTime!, wakeTime: record.wakeTime!)
                                }
                                if showingDetailsFor == record {
                                    Text("Quality: \(qualityEmojis[Int(record.quality) - 1])")
                                        .foregroundColor(.black)
                                        .padding(.leading)
                                    Text("Notes: \(record.notes ?? "")")
                                        .foregroundColor(.black)
                                        .padding(.leading)
                                }
                            }
                            .background(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteSleepRecord(record: record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button(action: {
                                    startEditing(record: record)
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Sleep Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .padding(.top, 70)
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    isShowingAddNewRecord.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
                .modifier(NavigationBarModifier())
                .overlay(
                    Group {
                        if isShowingAddNewRecord || isEditingRecord {
                            Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack {
                                Form {
                                    Section(header: Text(isEditingRecord ? "Edit Sleep Record" : "Add New Sleep Record").foregroundColor(.gray)) {
                                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                            .foregroundColor(.black)
                                            .padding(.vertical, 4)
                                        DatePicker("Sleep Time", selection: $sleepTime, displayedComponents: .hourAndMinute)
                                            .foregroundColor(.black)
                                            .padding(.vertical, 4)
                                        DatePicker("Wake Time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                                            .foregroundColor(.black)
                                            .padding(.vertical, 4)
                                        
                                        HStack {
                                            ForEach(0..<5, id: \.self) { i in
                                                Button(action: {
                                                    self.quality = i + 1
                                                }) {
                                                    Text(qualityEmojis[i])
                                                        .font(.largeTitle)
                                                        .cornerRadius(10)
                                                        .foregroundColor(.black)
                                                        .background(quality == i + 1 ? Color.blue : Color.clear)
                                                        .clipShape(Circle())
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        
                                        TextField("Notes", text: $notes)
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(width: 300, height: 380)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 20)
                                
                                HStack(alignment: .center) {
                                    Button(action: {
                                        if isEditingRecord {
                                            updateSleepRecord(record: showingDetailsFor!)
                                            isEditingRecord = false
                                            showingDetailsFor = nil
                                        } else {
                                            addSleepRecord()
                                        }
                                        isShowingAddNewRecord = false
                                    }) {
                                        Text("Save Record")
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }
                                    
                                    Button(action: {
                                        isShowingAddNewRecord = false
                                        isEditingRecord = false
                                    }) {
                                        Text("Close")
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                )
            }
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
    
    private func updateSleepRecord(record: SleepRecord) {
        withAnimation {
            record.date = selectedDate
            record.sleepTime = sleepTime
            record.wakeTime = wakeTime
            record.quality = Int16(quality)
            record.notes = notes
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func startEditing(record: SleepRecord) {
        selectedDate = record.date!
        sleepTime = record.sleepTime!
        wakeTime = record.wakeTime!
        quality = Int(record.quality)
        notes = record.notes ?? ""
        showingDetailsFor = record
        isEditingRecord = true
        isShowingAddNewRecord = true
    }
    
    private func deleteSleepRecord(record: SleepRecord) {
        withAnimation {
            viewContext.delete(record)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct NavigationBarModifier: ViewModifier {
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
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
