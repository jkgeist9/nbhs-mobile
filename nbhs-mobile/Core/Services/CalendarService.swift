//
//  CalendarService.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation
import Combine

class CalendarService: ObservableObject {
    static let shared = CalendarService()
    
    @Published var appointments: [Appointment] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var error: String?
    @Published var calendarMode: CalendarMode = .month
    @Published var showingCreateAppointment = false
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Calendar data organized by date
    @Published var appointmentsByDate: [Date: [Appointment]] = [:]
    @Published var currentMonthAppointments: [Appointment] = []
    @Published var selectedDateAppointments: [Appointment] = []
    
    private init() {
        setupDateBinding()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadAppointments(for date: Date = Date(), range: DateRange = .month) async {
        isLoading = true
        error = nil
        
        let (startDate, endDate) = getDateRange(for: date, range: range)
        
        do {
            let queryParams = [
                "start_date": ISO8601DateFormatter().string(from: startDate),
                "end_date": ISO8601DateFormatter().string(from: endDate)
            ]
            
            let endpoint = APIConfig.Endpoints.appointments + "?" + queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            
            let response: APIResponse<AppointmentListResponse> = try await apiClient.get(
                endpoint: endpoint
            )
            
            if let data = response.data {
                self.appointments = data.appointments
                updateAppointmentsByDate()
            } else {
                throw APIError.noData
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadTodaysAppointments() async {
        await loadAppointments(for: Date(), range: .day)
    }
    
    @MainActor
    func loadWeekAppointments() async {
        await loadAppointments(for: selectedDate, range: .week)
    }
    
    @MainActor
    func loadMonthAppointments() async {
        await loadAppointments(for: selectedDate, range: .month)
    }
    
    @MainActor
    func selectDate(_ date: Date) {
        selectedDate = date
        updateSelectedDateAppointments()
    }
    
    @MainActor
    func createAppointment(_ request: CreateAppointmentRequest) async -> Appointment? {
        do {
            let response: APIResponse<Appointment> = try await apiClient.post(
                endpoint: APIConfig.Endpoints.createAppointment,
                body: request
            )
            
            if let appointment = response.data {
                // Add to local data
                appointments.append(appointment)
                updateAppointmentsByDate()
                return appointment
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return nil
    }
    
    @MainActor
    func updateAppointment(_ appointmentId: String, request: UpdateAppointmentRequest) async -> Bool {
        do {
            let response: APIResponse<Appointment> = try await apiClient.put(
                endpoint: "/appointments/\(appointmentId)",
                body: request
            )
            
            if let updatedAppointment = response.data {
                // Update local data
                if let index = appointments.firstIndex(where: { $0.id == appointmentId }) {
                    appointments[index] = updatedAppointment
                    updateAppointmentsByDate()
                }
                return true
            }
            
        } catch {
            if let apiError = error as? APIError {
                self.error = apiError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
        
        return false
    }
    
    @MainActor
    func cancelAppointment(_ appointmentId: String, reason: String) async -> Bool {
        do {
            let request = ["reason": reason, "status": AppointmentStatus.cancelled.rawValue]
            let response: APIResponse<Appointment> = try await apiClient.post(
                endpoint: "/appointments/\(appointmentId)/cancel",
                body: request
            )
            
            if response.success {
                // Update local data
                if let index = appointments.firstIndex(where: { $0.id == appointmentId }) {
                    appointments[index] = Appointment(
                        id: appointments[index].id,
                        providerId: appointments[index].providerId,
                        patientId: appointments[index].patientId,
                        patientName: appointments[index].patientName,
                        patientEmail: appointments[index].patientEmail,
                        patientPhone: appointments[index].patientPhone,
                        appointmentType: appointments[index].appointmentType,
                        status: .cancelled,
                        scheduledStart: appointments[index].scheduledStart,
                        scheduledEnd: appointments[index].scheduledEnd,
                        actualStart: appointments[index].actualStart,
                        actualEnd: appointments[index].actualEnd,
                        notes: appointments[index].notes,
                        location: appointments[index].location,
                        isVirtual: appointments[index].isVirtual,
                        meetingLink: appointments[index].meetingLink,
                        cancelReason: reason,
                        createdAt: appointments[index].createdAt,
                        updatedAt: Date()
                    )
                    updateAppointmentsByDate()
                }
                return true
            }
            
        } catch {
            self.error = error.localizedDescription
        }
        
        return false
    }
    
    @MainActor
    func markAppointmentComplete(_ appointmentId: String, notes: String? = nil) async -> Bool {
        let request = UpdateAppointmentRequest(
            appointmentType: nil,
            scheduledStart: nil,
            scheduledEnd: nil,
            notes: notes,
            location: nil,
            isVirtual: nil,
            status: .completed
        )
        
        return await updateAppointment(appointmentId, request: request)
    }
    
    // MARK: - Statistics and Analytics
    
    @MainActor
    func getAppointmentStatistics(for period: StatisticsPeriod) async -> AppointmentStatsResponse? {
        do {
            let response: APIResponse<AppointmentStatsResponse> = try await apiClient.get(
                endpoint: "/appointments/statistics?period=\(period.rawValue)"
            )
            return response.data
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDateBinding() {
        $selectedDate
            .sink { [weak self] _ in
                self?.updateSelectedDateAppointments()
            }
            .store(in: &cancellables)
    }
    
    private func updateAppointmentsByDate() {
        var appointmentsByDate: [Date: [Appointment]] = [:]
        
        for appointment in appointments {
            let dateKey = Calendar.current.startOfDay(for: appointment.scheduledStart)
            
            if appointmentsByDate[dateKey] == nil {
                appointmentsByDate[dateKey] = []
            }
            appointmentsByDate[dateKey]?.append(appointment)
        }
        
        // Sort appointments by time for each date
        for (date, appointments) in appointmentsByDate {
            appointmentsByDate[date] = appointments.sorted { $0.scheduledStart < $1.scheduledStart }
        }
        
        self.appointmentsByDate = appointmentsByDate
        updateSelectedDateAppointments()
        updateCurrentMonthAppointments()
    }
    
    private func updateSelectedDateAppointments() {
        let selectedDateStart = Calendar.current.startOfDay(for: selectedDate)
        selectedDateAppointments = appointmentsByDate[selectedDateStart] ?? []
    }
    
    private func updateCurrentMonthAppointments() {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        currentMonthAppointments = appointments.filter { appointment in
            let appointmentMonth = calendar.component(.month, from: appointment.scheduledStart)
            let appointmentYear = calendar.component(.year, from: appointment.scheduledStart)
            return appointmentMonth == month && appointmentYear == year
        }
    }
    
    private func getDateRange(for date: Date, range: DateRange) -> (Date, Date) {
        let calendar = Calendar.current
        
        switch range {
        case .day:
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)
            
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)!
            return (weekInterval.start, weekInterval.end)
            
        case .month:
            let monthInterval = calendar.dateInterval(of: .month, for: date)!
            return (monthInterval.start, monthInterval.end)
        }
    }
    
    // MARK: - Helper Methods
    
    func appointmentsCount(for date: Date) -> Int {
        let dateKey = Calendar.current.startOfDay(for: date)
        return appointmentsByDate[dateKey]?.count ?? 0
    }
    
    func hasAppointments(for date: Date) -> Bool {
        return appointmentsCount(for: date) > 0
    }
    
    func getAppointments(for date: Date) -> [Appointment] {
        let dateKey = Calendar.current.startOfDay(for: date)
        return appointmentsByDate[dateKey] ?? []
    }
    
    func refreshData() async {
        await loadAppointments(for: selectedDate, range: calendarMode == .month ? .month : .week)
    }
}

// MARK: - Supporting Types

enum CalendarMode: String, CaseIterable {
    case day = "day"
    case week = "week"
    case month = "month"
    
    var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
}

enum DateRange {
    case day
    case week
    case month
}