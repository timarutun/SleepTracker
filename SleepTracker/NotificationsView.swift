//
//  SettingsView.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("customNotificationTime") private var customNotificationTimeString: String = ""
    
    @State private var selectedNotificationTime: Date = Date()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                Form {
                    Section(header: Text("Notifications")
                        .font(.headline)
                        .foregroundColor(.secondary)) {
                            
                            Toggle(isOn: $notificationsEnabled) {
                                Text("Enable Notifications")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)

                            if notificationsEnabled {
                                VStack(alignment: .leading, spacing: 20) {

                                    DatePicker("Notification Time", selection: $selectedNotificationTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .frame(height: 150)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)

                                    Text("Calculated Bedtime Notification Time: \(formattedNotificationTime)")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                        .padding(.top, 10)
                                }
                                .padding(.vertical)
                            }
                    }
                }
                .padding(.top)
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selectedNotificationTime = loadNotificationTime()
            }
        }
    }

    private func updateNotificationTime(_ newTime: Date) {
        // Convert Date to String and store it in @AppStorage
        customNotificationTimeString = formatDate(newTime)
        scheduleCustomNotification(at: newTime)
    }

    private func loadNotificationTime() -> Date {
        if customNotificationTimeString.isEmpty {
            return Date() // Default to current time if no saved value
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: customNotificationTimeString) ?? Date() // Return default if invalid
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }

    private var formattedNotificationTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: loadNotificationTime())
    }

    private func scheduleCustomNotification(at bedtime: Date) {
        if notificationsEnabled {
            SleepMateNotifications.scheduleSleepNotification(at: bedtime)
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
