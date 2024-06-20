//
//  SleepBarView.swift
//  SleepTracker
//
//  Created by Timur on 6/19/24.
//

import SwiftUI

struct SleepBarView: View {
    var sleepTime: Date
    var wakeTime: Date

    var body: some View {
        GeometryReader { geometry in
            // Define the start and end times for the day
            let calendar = Calendar.current
            let startTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: sleepTime)!
            let endTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: sleepTime.addingTimeInterval(86400))!
            let totalTime = endTime.timeIntervalSince(startTime)
            
            // Adjust sleep and wake times to be within this interval
            let adjustedSleepTime = sleepTime < startTime ? sleepTime.addingTimeInterval(86400) : sleepTime
            let adjustedWakeTime = wakeTime < startTime ? wakeTime.addingTimeInterval(86400) : wakeTime
            
            let sleepDuration = adjustedWakeTime.timeIntervalSince(adjustedSleepTime)
            let sleepStartRatio = adjustedSleepTime.timeIntervalSince(startTime) / totalTime
            let sleepDurationRatio = sleepDuration / totalTime
            
            VStack(spacing: 2) { // Adjusted spacing
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: geometry.size.height * 0.5) // Adjusted height
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(sleepDurationRatio), height: geometry.size.height * 0.5)
                        .offset(x: geometry.size.width * CGFloat(sleepStartRatio))
                }
                .cornerRadius(4)
                
                HStack(spacing: 0) {
                    ForEach(0..<18) { hour in
                        let displayHour = (21 + hour) % 24
                        Text("\(displayHour)")
                            .font(.caption2) // Adjusted font size
                            .frame(width: geometry.size.width / 17, alignment: .center) // 17 hours from 9 PM to 2 PM
                    }
                }
            }
        }
        .frame(height: 30) // Adjusted frame height
    }
}





