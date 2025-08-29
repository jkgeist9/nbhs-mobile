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
        HStack(spacing: 0) {
            // Sidebar Navigation
            SidebarNavigation(selectedTab: $selectedTab)
            
            // Main Content Area
            Group {
                switch selectedTab {
                case 0:
                    MainContentView(
                        title: "Dashboard",
                        searchPlaceholder: nil
                    ) {
                        DashboardView()
                    }
                case 1:
                    MainContentView(
                        title: "Patient Inquiries",
                        searchPlaceholder: "Search inquiries...",
                        headerAction: {
                            AnyView(
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("New Inquiry")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.teal500)
                                    .cornerRadius(8)
                                }
                            )
                        }
                    ) {
                        InquiriesView()
                    }
                case 2:
                    MainContentView(
                        title: "Patients",
                        searchPlaceholder: "Search patients...",
                        headerAction: {
                            AnyView(
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("New Patient")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.teal500)
                                    .cornerRadius(8)
                                }
                            )
                        }
                    ) {
                        PatientsView()
                    }
                case 3:
                    MainContentView(
                        title: "Calendar",
                        searchPlaceholder: nil
                    ) {
                        CalendarView()
                    }
                default:
                    MainContentView(
                        title: "Dashboard",
                        searchPlaceholder: nil
                    ) {
                        DashboardView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
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


// MoreView removed - functionality moved to sidebar navigation

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
