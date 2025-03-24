//
//  NotificationsViewModel.swift
//  SleepTracker
//
//  Created by Timur on 3/23/25.
//

import SwiftUI
import UserNotifications
import CoreData

class NotificationsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @Published var selectedNotificationTime: Date = Date()
    @Published var showTimePicker: Bool = false
    
    @AppStorage("customNotificationTime") private var customNotificationTimeString: String = ""
    
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private var sleepRecords: [SleepRecord] {
        let request: NSFetchRequest<SleepRecord> = SleepRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }
    
    init() {
        selectedNotificationTime = loadNotificationTime()
    }
    
    // Request permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    // Handle toggling notifications
    func toggleNotifications(enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        
        if enabled {
            scheduleCustomNotification(at: selectedNotificationTime)
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("All notifications canceled")
        }
    }
    
    // Calculate recommended bedtime
    var recommendedBedtime: Date {
        let bestRecords = sleepRecords.filter { $0.quality >= 4 }
        guard !bestRecords.isEmpty else { return Date() }
        
        let totalSeconds = bestRecords.reduce(0) { result, record in
            let sleepTime = record.sleepTime!
            let components = Calendar.current.dateComponents([.hour, .minute], from: sleepTime)
            let seconds = (components.hour! * 3600) + (components.minute! * 60)
            return result + seconds
        }
        
        let averageSeconds = totalSeconds / bestRecords.count
        let hours = averageSeconds / 3600
        let minutes = (averageSeconds % 3600) / 60
        
        return Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
    }
    
    // Save and load notification time
    func saveCustomNotificationTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        customNotificationTimeString = formatter.string(from: adjustToFutureTime(selectedNotificationTime))
        scheduleCustomNotification(at: selectedNotificationTime)
        showTimePicker = false
    }
    
    func loadNotificationTime() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let savedTime = formatter.date(from: customNotificationTimeString) {
            return adjustToFutureTime(savedTime)
        } else {
            return adjustToFutureTime(recommendedBedtime)
        }
    }
    
    // Ensure time is in the future
    private func adjustToFutureTime(_ time: Date) -> Date {
        let calendar = Calendar.current
        var adjustedTime = calendar.date(bySettingHour: calendar.component(.hour, from: time),
                                         minute: calendar.component(.minute, from: time),
                                         second: 0,
                                         of: Date())!
        
        if adjustedTime <= Date() {
            adjustedTime = calendar.date(byAdding: .day, value: 1, to: adjustedTime)!
        }
        
        return adjustedTime
    }
    
    // Format time for UI
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Schedule notification
    private func scheduleCustomNotification(at time: Date) {
        if notificationsEnabled {
            SleepMateNotifications.scheduleSleepNotification(at: time)
        }
    }
    
    func onAppear() {
        requestNotificationPermission()
        selectedNotificationTime = loadNotificationTime()
    }
}
