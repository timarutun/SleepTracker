//
//  DailyTipCardView.swift
//  SleepTracker
//
//  Created by Timur on 7/26/24.
//

import SwiftUI

struct Tip {
    let text: String
    let image: String
}

let tips: [Tip] = [
    Tip(text: "Maintain a consistent sleep schedule to improve your circadian rhythm.", image: "sleep_schedule"),
    Tip(text: "Create a restful environment by keeping your room dark and quiet.", image: "restful_environment"),
    Tip(text: "Limit screen time before bed to reduce blue light exposure.", image: "limit_screen_time"),
    Tip(text: "Be mindful of what you eat and drink, especially avoiding caffeine before bed.", image: "mindful_eating"),
    Tip(text: "Get regular physical activity to promote better sleep quality.", image: "physical_activity")
]

struct DailyTipCardView: View {
    @State private var isFlipped = false
    
    var body: some View {
        VStack {
            if isFlipped {
                VStack {
                    Image(currentTip.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Text(currentTip.text)
                        .font(.headline)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .frame(width: 250, height: 150)
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
                VStack {
                    Image("card_back") // Replace with a suitable image for the back of the card
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Text("Tap to see today's tip")
                        .font(.headline)
                        .padding()
                }
                .frame(width: 250, height: 150)
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
    }
    
    private var currentTip: Tip {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        return tips[day % tips.count]
    }
}

#Preview {
    DailyTipCardView()
}
