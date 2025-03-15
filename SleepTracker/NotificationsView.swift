//
//  NotificationsView.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SleepRecord.date, ascending: false)],
        animation: .default)
    private var sleepRecords: FetchedResults<SleepRecord>
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("customNotificationTime") private var customNotificationTimeString: String = ""
    
    @State private var selectedNotificationTime: Date = Date()
    @State private var showTimePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Main content
                ScrollView {
                    VStack(spacing: 16) {
                        // Notifications toggle
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .onChange(of: notificationsEnabled) { enabled in
                                if enabled {
                                    scheduleCustomNotification(at: selectedNotificationTime)
                                } else {
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                    print("All notifications canceled")
                                }
                            }
                        
                        // Current and recommended time in a horizontal stack
                        if notificationsEnabled {
                            HStack(spacing: 16) {
                                // Current notification time
                                TimeCard(
                                    title: "Current Time",
                                    time: formattedTime(selectedNotificationTime),
                                    icon: "bell.fill",
                                    description: "Your reminder time",
                                    color: .yellow
                                )
                                
                                // Recommended bedtime
                                TimeCard(
                                    title: "Recommended",
                                    time: formattedTime(recommendedBedtime),
                                    icon: "bed.double.fill",
                                    description: "Based on your best sleep",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Button to set custom bedtime
                        if notificationsEnabled {
                            Button(action: {
                                showTimePicker.toggle()
                            }) {
                                Text("Set Custom Bedtime")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.6))
                                    .cornerRadius(10)
                                    .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 3)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Show time picker if enabled
                        if showTimePicker {
                            VStack(spacing: 8) {
                                DatePicker("Select Bedtime", selection: $selectedNotificationTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    saveCustomNotificationTime()
                                    showTimePicker = false
                                }) {
                                    Text("Save Custom Time")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green.opacity(0.6))
                                        .cornerRadius(10)
                                        .shadow(color: .green.opacity(0.4), radius: 5, x: 0, y: 3)
                                }
                                .padding(.horizontal)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Request notification permission on first launch
                requestNotificationPermission()
                selectedNotificationTime = loadNotificationTime()
            }
        }
    }
    
    // Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    // Calculate recommended bedtime
    private var recommendedBedtime: Date {
        let bestRecords = sleepRecords.filter { $0.quality >= 4 } // Filter records with quality 4 or higher
        guard !bestRecords.isEmpty else { return Date() } // Default to current time
        
        let totalSeconds = bestRecords.reduce(0) { result, record in
            let sleepTime = record.sleepTime!
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: sleepTime)
            let seconds = (components.hour! * 3600) + (components.minute! * 60)
            return result + seconds
        }
        
        let averageSeconds = totalSeconds / bestRecords.count
        let hours = averageSeconds / 3600
        let minutes = (averageSeconds % 3600) / 60
        
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
    }
    
    // Save custom notification time
    private func saveCustomNotificationTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        customNotificationTimeString = formatter.string(from: selectedNotificationTime)
        scheduleCustomNotification(at: selectedNotificationTime)
    }
    
    // Load saved notification time
    private func loadNotificationTime() -> Date {
        if customNotificationTimeString.isEmpty {
            return recommendedBedtime
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: customNotificationTimeString) ?? recommendedBedtime
    }
    
    // Format time for display
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Schedule notification
    private func scheduleCustomNotification(at time: Date) {
        if notificationsEnabled {
            SleepMateNotifications.scheduleSleepNotification(at: time)
        }
    }
}

// Time Card View
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
                    .font(.system(size: 16))
                Text(title)
                    .font(.headline)
                    .fontWidth(.condensed)
                    .foregroundColor(.white)
            }
            
            Text(time)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
    }
}

// Preview
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
