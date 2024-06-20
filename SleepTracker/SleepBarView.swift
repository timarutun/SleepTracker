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
            let totalTime = wakeTime.timeIntervalSince(sleepTime)
            let totalMinutes = 24 * 60 // 24 hours in minutes
            let startMinutes = Calendar.current.component(.hour, from: sleepTime) * 60 + Calendar.current.component(.minute, from: sleepTime)
            let endMinutes = Calendar.current.component(.hour, from: wakeTime) * 60 + Calendar.current.component(.minute, from: wakeTime)
            
            let startRatio = Double(startMinutes) / Double(totalMinutes)
            let durationRatio = totalTime / Double(totalMinutes * 60)
            
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(durationRatio), height: geometry.size.height * 0.8)
                        .offset(x: geometry.size.width * CGFloat(startRatio))
                }
                .cornerRadius(4)
                
                HStack {
                    ForEach(0..<25) { hour in
                        Text("\(hour)")
                            .font(.caption)
                            .frame(width: geometry.size.width / 24, alignment: .center)
                    }
                }
            }
        }
        .frame(height: 40)
    }
}


