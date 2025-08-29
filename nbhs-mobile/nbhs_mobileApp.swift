//
//  nbhs_mobileApp.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import SwiftUI

@main
struct NBHSMobileApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .preferredColorScheme(.light) // Force light mode initially
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Configure app appearance
        configureNavigationAppearance()
        configureTabBarAppearance()
        
        // Setup notification observers
        setupNotificationObservers()
    }
    
    private func configureNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.navigationBackground)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.teal500)
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.navigationBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.navigationInactive)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.navigationInactive)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.teal500)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.teal500)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func setupNotificationObservers() {
        // App lifecycle notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // App became active
            authService.extendSession()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // App will become inactive
            // Could implement auto-logout timer here
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // App entered background
            // Could start background session timeout
        }
    }
}
