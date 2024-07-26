//
//  DailyTipCardView.swift
//  SleepTracker
//
//  Created by Timur on 7/26/24.
//

import SwiftUI

struct DailyTipCardView: View {
    @State private var isFlipped = false
    private let tips = [
        "Maintain a consistent sleep schedule to improve your circadian rhythm.",
        "Create a restful environment by keeping your room dark and quiet.",
        "Limit screen time before bed to reduce blue light exposure.",
        "Be mindful of what you eat and drink, especially avoiding caffeine before bed.",
        "Get regular physical activity to promote better sleep quality."
    ]
    
    var body: some View {
        VStack {
            if isFlipped {
                Text(dailyTip)
                    .font(.headline)
                    .padding()
                    .frame(width: 330, height: 200)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onTapGesture {
                        withAnimation {
                            isFlipped.toggle()
                        }
                    }
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                Image("flipImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 330, height: 200)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onTapGesture {
                        withAnimation {
                            isFlipped.toggle()
                        }
                    }
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    private var dailyTip: String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        return tips[day % tips.count]
    }
}

#Preview {
    DailyTipCardView()
}

#Preview {
    DailyTipCardView()
}
