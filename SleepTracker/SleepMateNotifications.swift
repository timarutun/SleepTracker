//
//  SleepMateNotifications.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import UserNotifications

import UserNotifications

struct SleepMateNotifications {
    static func scheduleSleepNotification(at bedtime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sleep Reminder"
        content.body = "It's time to go to bed!"
        content.sound = .default

        // Ensure the notification time is not in the past
        let currentDate = Date()
        if bedtime <= currentDate {
            print("Notification time is in the past. Notification will not be scheduled.")
            return
        }

        // Extract hour and minute from the selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: bedtime)
        
        // Create a trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "sleepReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification successfully scheduled for daily at \(components.hour!):\(components.minute!)")
            }
        }
    }
}

