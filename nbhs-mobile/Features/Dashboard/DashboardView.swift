//
//  DashboardView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardService = DashboardService.shared
    @StateObject private var authService = AuthService.shared
    @State private var selectedPeriod: StatisticsPeriod = .today
    @State private var showingTaskDetails = false
    @State private var selectedTask: TaskItem?
    @State private var showingAlertDetails = false
    @State private var selectedAlert: AlertItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Welcome Header
                    welcomeSection
                    
                    // Quick Stats
                    if let stats = dashboardService.dashboardData?.statistics {
                        quickStatsSection(stats)
                    }
                    
                    // Alerts Section
                    if let alerts = dashboardService.dashboardData?.alerts, !alerts.isEmpty {
                        alertsSection(alerts)
                    }
                    
                    // Today's Schedule
                    if let appointments = dashboardService.dashboardData?.upcomingAppointments, !appointments.isEmpty {
                        todaysScheduleSection(appointments)
                    }
                    
                    // Pending Tasks
                    if let tasks = dashboardService.dashboardData?.pendingTasks, !tasks.isEmpty {
                        pendingTasksSection(tasks)
                    }
                    
                    // Recent Activity
                    if let activities = dashboardService.dashboardData?.recentActivity, !activities.isEmpty {
                        recentActivitySection(activities)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await dashboardService.refreshData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.teal500)
                    }
                    .disabled(dashboardService.isLoading)
                }
            }
            .refreshable {
                await dashboardService.refreshData()
            }
            .task {
                await dashboardService.loadDashboardData()
            }
            .overlay {
                if dashboardService.isLoading && dashboardService.dashboardData == nil {
                    ProgressView("Loading Dashboard...")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task) { updatedTask in
                // Handle task updates
            }
        }
        .sheet(item: $selectedAlert) { alert in
            AlertDetailView(alert: alert) { updatedAlert in
                // Handle alert updates
            }
        }
    }
    
    // MARK: - Welcome Section
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .bodyStyle(.medium, color: .textSecondary)
                    
                    if let user = authService.user {
                        Text(user.firstName)
                            .headingStyle(.h2)
                    }
                }
                
                Spacer()
                
                // Profile Circle
                if let user = authService.user {
                    Circle()
                        .fill(Color.teal500)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(user.initials)
                                .font(Typography.labelSmall)
                                .foregroundColor(.white)
                                .bold()
                        )
                }
            }
            
            // Date and Time
            VStack(alignment: .leading, spacing: 2) {
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day().year())
                    .captionStyle(.regular, color: .textTertiary)
                
                Text("Have a productive day!")
                    .captionStyle(.regular, color: .textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Quick Stats Section
    
    private func quickStatsSection(_ stats: DashboardStatistics) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Overview")
                .headingStyle(.h4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Appointments",
                    value: "\(stats.todayAppointments)",
                    subtitle: "scheduled today",
                    icon: "calendar",
                    color: .teal500
                )
                
                StatCard(
                    title: "Patients",
                    value: "\(stats.activePatients)",
                    subtitle: "active patients",
                    icon: "person.2",
                    color: .success
                )
                
                StatCard(
                    title: "Inquiries",
                    value: "\(stats.pendingInquiries)",
                    subtitle: "pending review",
                    icon: "envelope",
                    color: .warning
                )
                
                StatCard(
                    title: "Evaluations",
                    value: "\(stats.completedEvaluations)",
                    subtitle: "completed",
                    icon: "doc.text",
                    color: .info
                )
            }
        }
    }
    
    // MARK: - Alerts Section
    
    private func alertsSection(_ alerts: [AlertItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Alerts")
                    .headingStyle(.h4)
                
                Spacer()
                
                if alerts.filter({ !$0.isRead }).count > 0 {
                    Text("\(alerts.filter({ !$0.isRead }).count) unread")
                        .captionStyle(.regular, color: .error)
                }
            }
            
            ForEach(alerts.prefix(3)) { alert in
                AlertCard(alert: alert) {
                    selectedAlert = alert
                } onMarkRead: {
                    Task {
                        await dashboardService.markAlertRead(alert.id)
                    }
                }
            }
            
            if alerts.count > 3 {
                Button("View All Alerts") {
                    // Navigate to alerts view
                }
                .buttonStyle(.plain)
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
        }
    }
    
    // MARK: - Today's Schedule Section
    
    private func todaysScheduleSection(_ appointments: [Appointment]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Schedule")
                    .headingStyle(.h4)
                
                Spacer()
                
                Text("\(appointments.count) appointments")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            VStack(spacing: 8) {
                ForEach(appointments.prefix(4)) { appointment in
                    AppointmentCard(appointment: appointment)
                }
            }
            
            if appointments.count > 4 {
                NavigationLink("View All Appointments") {
                    // Navigate to calendar view
                }
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
        }
    }
    
    // MARK: - Pending Tasks Section
    
    private func pendingTasksSection(_ tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pending Tasks")
                    .headingStyle(.h4)
                
                Spacer()
                
                Text("\(tasks.filter { !$0.isCompleted }.count) remaining")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            VStack(spacing: 8) {
                ForEach(tasks.filter { !$0.isCompleted }.prefix(3)) { task in
                    TaskCard(task: task) {
                        selectedTask = task
                    } onComplete: {
                        Task {
                            await dashboardService.markTaskComplete(task.id)
                        }
                    }
                }
            }
            
            if tasks.filter({ !$0.isCompleted }).count > 3 {
                Button("View All Tasks") {
                    // Navigate to tasks view
                }
                .buttonStyle(.plain)
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
        }
    }
    
    // MARK: - Recent Activity Section
    
    private func recentActivitySection(_ activities: [ActivityItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .headingStyle(.h4)
            
            VStack(spacing: 8) {
                ForEach(activities.prefix(5)) { activity in
                    ActivityCard(activity: activity)
                }
            }
            
            if activities.count > 5 {
                Button("View All Activity") {
                    // Navigate to activity view
                }
                .buttonStyle(.plain)
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
        }
    }
}

// MARK: - Card Components

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .headingStyle(.h2)
                
                Text(title)
                    .bodyStyle(.medium)
                
                Text(subtitle)
                    .captionStyle(.regular, color: .textTertiary)
            }
        }
        .padding(16)
        .background(Color.surface)
        .cornerRadius(12)
        .shadow(color: .shadowLight, radius: 4, x: 0, y: 2)
    }
}

struct AlertCard: View {
    let alert: AlertItem
    let onTap: () -> Void
    let onMarkRead: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Icon
            Image(systemName: alert.type.icon)
                .font(.system(size: 16))
                .foregroundColor(getAlertColor(alert.severity))
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .bodyStyle(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if !alert.isRead {
                        Circle()
                            .fill(Color.error)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(alert.message)
                    .captionStyle(.regular, color: .textSecondary)
                    .lineLimit(2)
                
                Text(alert.timestamp, format: .relative(presentation: .numeric))
                    .captionStyle(.small, color: .textTertiary)
            }
            
            // Mark Read Button
            if !alert.isRead {
                Button(action: onMarkRead) {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func getAlertColor(_ severity: AlertSeverity) -> Color {
        switch severity {
        case .info: return .info
        case .warning: return .warning
        case .critical: return .error
        }
    }
}

struct TaskCard: View {
    let task: TaskItem
    let onTap: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Complete Button
            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.isCompleted ? .success : .textTertiary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .bodyStyle(.medium)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .textTertiary : .textPrimary)
                    
                    Spacer()
                    
                    // Priority Badge
                    Text(task.priority.displayName)
                        .captionStyle(.small, color: getPriorityColor(task.priority))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(getPriorityColor(task.priority).opacity(0.1))
                        .cornerRadius(4)
                }
                
                if let dueDate = task.dueDate {
                    Text("Due \(dueDate, format: .dateTime.month().day())")
                        .captionStyle(.small, color: .textTertiary)
                }
                
                if let patientName = task.patientName {
                    Text("Patient: \(patientName)")
                        .captionStyle(.small, color: .textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func getPriorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .textTertiary
        case .medium: return .warning
        case .high: return .error
        case .urgent: return .error
        }
    }
}

struct ActivityCard: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            Image(systemName: activity.type.icon)
                .font(.system(size: 16))
                .foregroundColor(.teal500)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .bodyStyle(.medium)
                
                Text(activity.description)
                    .captionStyle(.regular, color: .textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text(activity.timestamp, format: .relative(presentation: .numeric))
                        .captionStyle(.small, color: .textTertiary)
                    
                    if let patientName = activity.patientName {
                        Text("•")
                            .captionStyle(.small, color: .textTertiary)
                        Text(patientName)
                            .captionStyle(.small, color: .textTertiary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
    }
}

// MARK: - Detail Views (Placeholders)

struct TaskDetailView: View {
    let task: TaskItem
    let onUpdate: (TaskItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Task Details: \(task.title)")
                    .headingStyle(.h3)
                Spacer()
            }
            .padding()
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AlertDetailView: View {
    let alert: AlertItem
    let onUpdate: (AlertItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Alert Details: \(alert.title)")
                    .headingStyle(.h3)
                Text(alert.message)
                    .bodyStyle(.regular)
                Spacer()
            }
            .padding()
            .navigationTitle("Alert Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthService.shared)
    }
}
#endif