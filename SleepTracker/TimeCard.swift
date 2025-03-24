//
//  TimeCard.swift
//  SleepTracker
//
//  Created by Timur on 3/23/25.
//

import SwiftUI

struct TimeCard: View {
    let title: String
    let time: String
    let icon: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(time)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

