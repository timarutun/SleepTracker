//
//  NotificationsView.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("customNotificationTime") private var customNotificationTimeString: String = ""
    
    @State private var selectedNotificationTime: Date = Date()
    @State private var isTimeManuallyUpdated: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Form {
                        Section {
                            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            if notificationsEnabled {
                                VStack(alignment: .center, spacing: 20) {
                                    Button(action: {
                                        selectedNotificationTime = loadNotificationTime()
                                    }) {
                                        Text("Calculated best Bedtime: \(formattedNotificationTime)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    
                                    DatePicker("Notification Time", selection: $selectedNotificationTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .frame(height: 150)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)
                                        .onChange(of: selectedNotificationTime) { _ in
                                            isTimeManuallyUpdated = true
                                        }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding(.top)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    if notificationsEnabled {
                        Button(action: {
                            saveNotificationTime()
                        }) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !isTimeManuallyUpdated {
                    selectedNotificationTime = loadNotificationTime()
                }
            }
        }
    }
    
    private func saveNotificationTime() {
        customNotificationTimeString = formatDate(selectedNotificationTime)
        scheduleCustomNotification(at: selectedNotificationTime)
    }
    
    private func loadNotificationTime() -> Date {
        if customNotificationTimeString.isEmpty {
            return Date()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: customNotificationTimeString) ?? Date()
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
