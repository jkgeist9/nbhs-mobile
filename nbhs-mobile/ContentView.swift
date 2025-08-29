//
//  ContentView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // Main Provider Portal
                MainTabView(selectedTab: $selectedTab)
            } else {
                // Authentication Flow
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "squares.below.rectangle")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Patients
            PatientsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Patients")
                }
                .tag(1)
            
            // Calendar
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(2)
            
            // Messages
            MessagesView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .tag(3)
            
            // More
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("More")
                }
                .tag(4)
        }
        .tint(.teal500)
    }
}

// MARK: - Placeholder Views

// Dashboard is now implemented in Features/Dashboard/DashboardView.swift

// Patients view is now implemented in Features/Patients/PatientsListView.swift
struct PatientsView: View {
    var body: some View {
        PatientsListView()
    }
}

// Calendar view is now implemented in Features/Calendar/CalendarView.swift

struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Messages will be displayed here")
                    .bodyStyle(.large, color: .textSecondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MoreView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: InquiriesView()) {
                        Label("Inquiries", systemImage: "tray")
                    }
                    
                    NavigationLink(destination: EvaluationsView()) {
                        Label("Evaluations", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: BillingView()) {
                        Label("Billing", systemImage: "creditcard")
                    }
                    
                    NavigationLink(destination: IVRView()) {
                        Label("Call Center", systemImage: "phone")
                    }
                } header: {
                    Text("Clinical Features")
                }
                
                Section {
                    NavigationLink(destination: DocumentsView()) {
                        Label("Documents", systemImage: "folder")
                    }
                    
                    NavigationLink(destination: ReportsView()) {
                        Label("Reports", systemImage: "chart.bar")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                } header: {
                    Text("Tools")
                }
                
                Section {
                    if let user = authService.user {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullName)
                                .bodyStyle(.medium)
                            
                            Text(user.email)
                                .captionStyle(.regular, color: .textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        Task {
                            await authService.logout()
                        }
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .foregroundColor(.error)
                    }
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - More View Destinations (Placeholders)

struct InquiriesView: View {
    var body: some View {
        InquiriesListView()
    }
}

struct EvaluationsView: View {
    var body: some View {
        Text("Evaluations View")
            .navigationTitle("Evaluations")
    }
}

struct BillingView: View {
    var body: some View {
        Text("Billing View")
            .navigationTitle("Billing")
    }
}

struct IVRView: View {
    var body: some View {
        Text("IVR Call Center View")
            .navigationTitle("Call Center")
    }
}

struct DocumentsView: View {
    var body: some View {
        Text("Documents View")
            .navigationTitle("Documents")
    }
}

struct ReportsView: View {
    var body: some View {
        Text("Reports View")
            .navigationTitle("Reports")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .navigationTitle("Settings")
    }
}

// MARK: - Previews

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthService.shared)
    }
}
#endif
