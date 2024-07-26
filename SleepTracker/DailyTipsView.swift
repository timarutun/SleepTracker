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
            VStack {
                DailyTipCardView()
                    .padding()
                Spacer()
            }
            .navigationTitle("Daily Tip")
        }
    }
}


#Preview {
    DailyTipsView()
}
