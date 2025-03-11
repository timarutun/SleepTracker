//
//  SleepMateNotifications.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import UserNotifications
import CoreData

struct SleepMateNotifications {
    static func scheduleSleepNotification(at bedtime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sleep Reminder"
        content.body = "It's time to go to bed!"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: bedtime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true) // Повторение каждый день
        
        let request = UNNotificationRequest(identifier: "sleepReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    static func calculateBestBedtime(using context: NSManagedObjectContext) -> Date? {
        let request: NSFetchRequest<SleepRecord> = SleepRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)]
        
        do {
            let sleepRecords = try context.fetch(request)
            return recommendedSleepTime(for: sleepRecords)
        } catch {
            print("Error fetching sleep records: \(error)")
            return nil
        }
    }
    
    private static func recommendedSleepTime(for records: [SleepRecord]) -> Date? {
        guard let optimalDuration = optimalSleepDuration(for: records) else { return nil }
        
        let wakeTimes = records.compactMap { $0.wakeTime }
        guard !wakeTimes.isEmpty else { return nil }
        
        let averageWakeTimeInterval = wakeTimes.map { $0.timeIntervalSinceReferenceDate }.reduce(0, +) / Double(wakeTimes.count)
        let averageWakeTime = Date(timeIntervalSinceReferenceDate: averageWakeTimeInterval)
        
        return averageWakeTime.addingTimeInterval(-optimalDuration)
    }
    
    private static func optimalSleepDuration(for records: [SleepRecord]) -> TimeInterval? {
        let filteredRecords = records.filter { $0.quality == 4 || $0.quality == 5 }
        guard !filteredRecords.isEmpty else { return nil }
        
        var totalDuration: TimeInterval = 0
        var totalWeight: Double = 0
        
        for record in filteredRecords {
            guard let sleepTime = record.sleepTime, let wakeTime = record.wakeTime else { continue }
            let duration = wakeTime.timeIntervalSince(sleepTime)
            let weight = record.quality == 5 ? 2.0 : 1.0
            totalDuration += duration * weight
            totalWeight += weight
        }
        
        return totalWeight == 0 ? nil : totalDuration / totalWeight
    }
}
