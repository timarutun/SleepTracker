//
//  NotificationsView.swift
//  SleepTracker
//
//  Created by Timur on 2/14/25.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Notifications toggle
                        Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .onChange(of: viewModel.notificationsEnabled) { enabled in
                                viewModel.toggleNotifications(enabled: enabled)
                            }
                        
                        // Time cards
                        if viewModel.notificationsEnabled {
                            HStack(spacing: 16) {
                                TimeCard(title: "Current Time",
                                         time: viewModel.formattedTime(viewModel.selectedNotificationTime),
                                         icon: "bell.fill",
                                         description: "Your reminder time",
                                         color: .yellow)
                                
                                TimeCard(title: "Recommended",
                                         time: viewModel.formattedTime(viewModel.recommendedBedtime),
                                         icon: "bed.double.fill",
                                         description: "Based on your best sleep",
                                         color: .green)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Set custom bedtime button
                        if viewModel.notificationsEnabled {
                            Button(action: {
                                viewModel.showTimePicker.toggle()
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
                        
                        // Time Picker
                        if viewModel.showTimePicker {
                            VStack(spacing: 8) {
                                DatePicker("Select Bedtime", selection: $viewModel.selectedNotificationTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    viewModel.saveCustomNotificationTime()
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
                viewModel.onAppear()
            }
        }
    }
}


// Preview
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
