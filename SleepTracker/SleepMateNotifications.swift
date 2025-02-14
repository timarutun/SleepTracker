//
//  SleepMateNotifications.swift
//  SleepTracker
//
//  Created by Timur on 2/13/25.
//

import UserNotifications
import Foundation

class SleepMateNotifications {
    
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    static func scheduleBedtimeReminder(for optimalBedtime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Sleep!"
        content.body = "It's time to go to bed to get a full night's rest."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: optimalBedtime), repeats: true)
        
        let request = UNNotificationRequest(identifier: "bedtimeReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Bedtime reminder scheduled successfully.")
            }
        }
    }
    
    static func calculateOptimalBedtime(from sleepRecords: [SleepRecord]) -> Date? {
        let filteredRecords = sleepRecords.filter { $0.quality == 4 || $0.quality == 5 }
        
        let optimalSleepDuration: TimeInterval
        if let fiveStarRecords = filteredRecords.filter({ $0.quality == 5 }) {
            optimalSleepDuration = fiveStarRecords.map { $0.sleepDuration }.reduce(0, +) / Double(fiveStarRecords.count)
        } else {
            optimalSleepDuration = filteredRecords.map { $0.sleepDuration }.reduce(0, +) / Double(filteredRecords.count)
        }
        
        let averageBedtime = filteredRecords.map { $0.sleepTime }.reduce(Date(), +) / Double(filteredRecords.count)
        return Calendar.current.date(byAdding: .minute, value: -Int(optimalSleepDuration / 60), to: averageBedtime)
    }
}

