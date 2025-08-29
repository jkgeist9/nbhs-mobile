//
//  CalendarView.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var calendarService = CalendarService.shared
    @State private var showingModeSelector = false
    @State private var selectedAppointment: Appointment?
    @State private var showingAppointmentDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
                // Calendar Mode Selector
                calendarModeSelector
                
                // Calendar Content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Calendar Grid
                        calendarGrid
                        
                        // Selected Date Appointments
                        if !calendarService.selectedDateAppointments.isEmpty {
                            selectedDateSection
                        }
                        
                        // Upcoming Appointments (if showing today)
                        if Calendar.current.isDate(calendarService.selectedDate, inSameDayAs: Date()) {
                            upcomingAppointmentsSection
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(item: $selectedAppointment) { appointment in
                AppointmentDetailView(appointment: appointment)
            }
            .sheet(isPresented: $calendarService.showingCreateAppointment) {
                CreateAppointmentView()
            }
            .task {
                await calendarService.loadMonthAppointments()
            }
            .refreshable {
                await calendarService.refreshData()
            }
    }
    
    // MARK: - Calendar Mode Selector
    
    private var calendarModeSelector: some View {
        HStack {
            // Month/Year Display
            Button(action: {
                showingModeSelector = true
            }) {
                HStack(spacing: 8) {
                    Text(calendarService.selectedDate, format: .dateTime.month(.wide).year())
                        .headingStyle(.h3)
                        .foregroundColor(.textPrimary)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            // Navigation Arrows
            HStack(spacing: 16) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.teal500)
                }
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.teal500)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surface)
        .overlay(
            Rectangle()
                .fill(Color.border)
                .frame(height: 1),
            alignment: .bottom
        )
        .confirmationDialog("Select View", isPresented: $showingModeSelector) {
            Button("Month View") {
                calendarService.calendarMode = .month
                Task {
                    await calendarService.loadMonthAppointments()
                }
            }
            
            Button("Week View") {
                calendarService.calendarMode = .week
                Task {
                    await calendarService.loadWeekAppointments()
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 0) {
            // Weekday Headers
            weekdayHeaders
            
            // Calendar Days
            if calendarService.calendarMode == .month {
                monthCalendarGrid
            } else {
                weekCalendarGrid
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var weekdayHeaders: some View {
        HStack {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .captionStyle(.regular, color: .textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var monthCalendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(generateCalendarDates(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: calendarService.selectedDate),
                    isToday: Calendar.current.isDate(date, inSameDayAs: Date()),
                    isInCurrentMonth: Calendar.current.isDate(date, equalTo: calendarService.selectedDate, toGranularity: .month),
                    appointmentCount: calendarService.appointmentsCount(for: date),
                    hasAppointments: calendarService.hasAppointments(for: date)
                ) {
                    calendarService.selectDate(date)
                }
            }
        }
    }
    
    private var weekCalendarGrid: some View {
        HStack(spacing: 8) {
            ForEach(generateWeekDates(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: calendarService.selectedDate),
                    isToday: Calendar.current.isDate(date, inSameDayAs: Date()),
                    isInCurrentMonth: true,
                    appointmentCount: calendarService.appointmentsCount(for: date),
                    hasAppointments: calendarService.hasAppointments(for: date),
                    isWeekView: true
                ) {
                    calendarService.selectDate(date)
                }
            }
        }
    }
    
    // MARK: - Selected Date Section
    
    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(calendarService.selectedDate, format: .dateTime.weekday(.wide).month(.wide).day())
                    .headingStyle(.h4)
                
                Spacer()
                
                Text("\(calendarService.selectedDateAppointments.count) appointments")
                    .captionStyle(.regular, color: .textSecondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(calendarService.selectedDateAppointments) { appointment in
                    AppointmentCard(appointment: appointment)
                        .onTapGesture {
                            selectedAppointment = appointment
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
    
    // MARK: - Upcoming Appointments Section
    
    private var upcomingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming This Week")
                    .headingStyle(.h4)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full calendar view
                }
                .font(Typography.bodyMedium)
                .foregroundColor(.textLink)
            }
            
            let upcomingAppointments = calendarService.appointments
                .filter { $0.isUpcoming && $0.scheduledStart.timeIntervalSinceNow <= 7 * 24 * 60 * 60 }
                .prefix(5)
            
            if upcomingAppointments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 32))
                        .foregroundColor(.textTertiary)
                    
                    Text("No upcoming appointments this week")
                        .bodyStyle(.medium, color: .textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(upcomingAppointments)) { appointment in
                        UpcomingAppointmentCard(appointment: appointment)
                            .onTapGesture {
                                selectedAppointment = appointment
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.backgroundSecondary)
    }
    
    // MARK: - Helper Methods
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarService.selectedDate) {
            calendarService.selectDate(newDate)
            Task {
                await calendarService.loadMonthAppointments()
            }
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarService.selectedDate) {
            calendarService.selectDate(newDate)
            Task {
                await calendarService.loadMonthAppointments()
            }
        }
    }
    
    private func generateCalendarDates() -> [Date] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: calendarService.selectedDate)
        let year = calendar.component(.year, from: calendarService.selectedDate)
        
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        let startWeekday = calendar.component(.weekday, from: monthStart)
        let startOffset = startWeekday - calendar.firstWeekday
        let adjustedStartOffset = startOffset >= 0 ? startOffset : startOffset + 7
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -adjustedStartOffset, to: monthStart) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = calendarStart
        
        // Generate 6 weeks (42 days) to fill the calendar grid
        for _ in 0..<42 {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func generateWeekDates() -> [Date] {
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: calendarService.selectedDate)!
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
}

// MARK: - Supporting Views

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isInCurrentMonth: Bool
    let appointmentCount: Int
    let hasAppointments: Bool
    let isWeekView: Bool
    let onTap: () -> Void
    
    init(date: Date, isSelected: Bool, isToday: Bool, isInCurrentMonth: Bool, appointmentCount: Int, hasAppointments: Bool, isWeekView: Bool = false, onTap: @escaping () -> Void) {
        self.date = date
        self.isSelected = isSelected
        self.isToday = isToday
        self.isInCurrentMonth = isInCurrentMonth
        self.appointmentCount = appointmentCount
        self.hasAppointments = hasAppointments
        self.isWeekView = isWeekView
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if isWeekView {
                    Text(date, format: .dateTime.weekday(.abbreviated))
                        .captionStyle(.small, color: .textTertiary)
                }
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(Typography.bodyMedium)
                    .foregroundColor(textColor)
                    .fontWeight(isToday ? .bold : .regular)
                
                // Appointment indicator
                if hasAppointments {
                    if appointmentCount == 1 {
                        Circle()
                            .fill(Color.teal500)
                            .frame(width: 6, height: 6)
                    } else {
                        Text("\(appointmentCount)")
                            .captionStyle(.small, color: .white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.teal500)
                            .cornerRadius(8)
                    }
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(width: isWeekView ? 45 : 40, height: isWeekView ? 70 : 50)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if !isInCurrentMonth {
            return .textTertiary
        } else if isSelected {
            return .white
        } else if isToday {
            return .teal500
        } else {
            return .textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .teal500
        } else if isToday {
            return .teal500.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isToday && !isSelected {
            return .teal500
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        isToday && !isSelected ? 1 : 0
    }
}

struct UpcomingAppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 12) {
            // Date and Time
            VStack(alignment: .leading, spacing: 2) {
                Text(appointment.scheduledStart, format: .dateTime.month(.abbreviated).day())
                    .captionStyle(.regular, color: .textSecondary)
                
                Text(appointment.scheduledStart, format: .dateTime.hour().minute())
                    .bodyStyle(.medium)
            }
            .frame(width: 50, alignment: .leading)
            
            // Appointment Details
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.patientName)
                    .bodyStyle(.medium)
                
                HStack(spacing: 8) {
                    Image(systemName: appointment.appointmentType.icon)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(appointment.appointmentType.displayName)
                        .captionStyle(.regular, color: .textSecondary)
                    
                    if appointment.isVirtual {
                        Image(systemName: "video")
                            .font(.caption)
                            .foregroundColor(.info)
                    }
                }
                
                Text(appointment.timeUntilStart)
                    .captionStyle(.small, color: .textTertiary)
            }
            
            Spacer()
            
            // Status
            Text(appointment.status.displayName)
                .captionStyle(.small, color: getStatusColor(appointment.status))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(getStatusColor(appointment.status).opacity(0.1))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(8)
        .shadow(color: .shadowLight, radius: 2, x: 0, y: 1)
    }
    
    private func getStatusColor(_ status: AppointmentStatus) -> Color {
        switch status {
        case .scheduled: return .textSecondary
        case .confirmed: return .success
        case .checkedIn: return .info
        case .inProgress: return .warning
        case .completed: return .success
        case .noShow: return .error
        case .cancelled: return .error
        case .rescheduled: return .warning
        }
    }
}

// MARK: - Placeholder Views

struct AppointmentDetailView: View {
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Appointment details would go here
                    Text("Appointment with \(appointment.patientName)")
                        .headingStyle(.h3)
                    
                    Text("Time: \(appointment.scheduledStart, format: .dateTime.hour().minute()) - \(appointment.scheduledEnd, format: .dateTime.hour().minute())")
                        .bodyStyle(.regular)
                    
                    Text("Type: \(appointment.appointmentType.displayName)")
                        .bodyStyle(.regular)
                    
                    Text("Status: \(appointment.status.displayName)")
                        .bodyStyle(.regular)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Appointment Details")
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

struct CreateAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create New Appointment")
                    .headingStyle(.h3)
                
                Text("Appointment creation form would go here")
                    .bodyStyle(.regular, color: .textSecondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
#endif