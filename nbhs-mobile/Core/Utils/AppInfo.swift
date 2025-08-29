//
//  AppInfo.swift
//  NBHS Mobile
//
//  Created by Claude on 2025-08-29.
//  Copyright © 2025 NeuroBehavioral Health Services. All rights reserved.
//

import Foundation

struct AppInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "NBHS Mobile"
    }
}