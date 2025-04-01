//
//  SleepModeView.swift
//  SleepTracker
//
//  Created by Timur on 3/31/25.
//

import SwiftUI
import UIKit

struct SleepModeView: View {
    @State private var isSleepModeEnabled = false
    @State private var brightnessLevel: CGFloat = 0.3
    @State private var autoDisableAfter: Int = 30
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Main toggle switch
                    Toggle("Enable Sleep Mode", isOn: $isSleepModeEnabled)
                        .tint(.purple)
                        .onChange(of: isSleepModeEnabled) { enabled in
                            if enabled {
                                activateSleepMode()
                            } else {
                                deactivateSleepMode()
                            }
                        }
                }
                
                Section(header: Text("Settings")) {
                    // Screen brightness slider
                    Slider(
                        value: $brightnessLevel,
                        in: 0.1...0.7,
                        step: 0.1,
                        label: { Text("Screen Dimming") },
                        minimumValueLabel: { Image(systemName: "sun.min") },
                        maximumValueLabel: { Image(systemName: "sun.max") }
                    )
                    
                    // Auto-disable timer picker
                    Picker("Auto-disable after", selection: $autoDisableAfter) {
                        Text("30 min").tag(30)
                        Text("1 hour").tag(60)
                        Text("Until morning").tag(0)
                    }
                }
            }
            .navigationTitle("Sleep Mode")
        }
    }
    
    private func activateSleepMode() {

        UIScreen.main.brightness = brightnessLevel
        

        enableDoNotDisturb()
        
        enableNightShift()
        
        if autoDisableAfter > 0 {
            scheduleAutoDisable(after: autoDisableAfter)
        }
        
        showActivationAlert()
    }
    
    private func deactivateSleepMode() {
        UIScreen.main.brightness = 0.7
    }
    
    private func enableDoNotDisturb() {
        print("Do Not Disturb would be enabled here")
    }
    
    private func enableNightShift() {
        if let settingsURL = URL(string: "app-settings:display&brightness") {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    private func scheduleAutoDisable(after minutes: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(minutes) * 60) {
            if isSleepModeEnabled {
                isSleepModeEnabled = false
            }
        }
    }
    
    private func showActivationAlert() {
        let alert = UIAlertController(
            title: "Sleep Mode Activated",
            message: "Screen dimmed and notifications silenced 🌙",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

#Preview {
    SleepModeView()
}
