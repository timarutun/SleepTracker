//
//  SleepMateNotifications.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import UserNotifications

struct SleepMateNotifications {
    static func scheduleSleepNotification(at bedtime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sleep Reminder"
        content.body = "It's time to go to bed!"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: bedtime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "sleepReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}



