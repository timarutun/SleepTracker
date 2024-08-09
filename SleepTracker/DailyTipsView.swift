//
//  DailyTipsView.swift
//  SleepTracker
//
//  Created by Timur on 7/26/24.
//

import SwiftUI

struct DailyTipsView: View {
    var body: some View {
        NavigationView {
            ZStack {

                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Tap to see your Daily Tip")
                        .foregroundStyle(Color.white)
                        .font(.title2)
                        .bold()
                    DailyTipCardView()
                        .padding()
                    Spacer()
                }
                .padding(.top,100)
            }
            .navigationTitle("Daily Tip")
        }
    }
}

struct DailyTipsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTipsView()
    }
}

#Preview {
    DailyTipsView()
}
