# iOS App Development Plan for NBHS Provider Portal

## Executive Summary
Create a native iOS app that provides core provider portal functionality, **connecting to the existing Express.js backend API and PostgreSQL database** from the nbhs-website project. The app will match the visual design of the web application while providing a native iOS experience.

## Architecture Overview

### System Architecture
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   iOS App       │────▶│  Express API    │────▶│  PostgreSQL DB  │
│   (SwiftUI)     │     │  (Port 8080)    │     │  (Existing)     │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       ▲                       ▲
        │                       │                       │
        └───── JWT Auth ────────┘                       │
                                                        │
                               Prisma ORM ──────────────┘
```

### Key Integration Points
- **Database**: Uses the SAME PostgreSQL database as the web app (no separate database)
- **API Server**: Connects to the SAME Express.js backend at `http://localhost:8080/api` (or production URL)
- **Authentication**: Uses the SAME JWT token system
- **Data Models**: Mirrors the SAME Prisma schema
- **Business Logic**: Leverages ALL existing backend routes and services

## Technology Stack

### iOS App (Frontend)
- **UI Framework**: SwiftUI (native iOS)
- **Networking**: URLSession with Combine
- **Authentication**: JWT tokens stored in iOS Keychain
- **State Management**: SwiftUI @StateObject and @EnvironmentObject
- **Design System**: Custom SwiftUI components matching Tailwind CSS

### Backend (Existing - No Changes Needed)
- **API Server**: Express.js on port 8080
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with bcrypt
- **File Storage**: Local filesystem with encryption
- **Security**: Helmet, CORS, rate-limiting

## Development Phases

### Phase 1: Foundation & Authentication (Week 1-2)

#### 1.1 Project Setup
- [ ] Configure Xcode project with bundle ID: `com.nbhealthservices.provider`
- [ ] Set up development, staging, and production configurations
- [ ] Configure API base URLs for each environment
- [ ] Add app icons and launch screen with NBHS branding

#### 1.2 API Client Foundation
```swift
// APIConfig.swift
struct APIConfig {
    static let baseURL = "http://localhost:8080/api" // Development
    // static let baseURL = "https://api.nbhealthservices.com/api" // Production
}
```

#### 1.3 Authentication System
- [ ] Login screen matching web design
- [ ] JWT token management with Keychain storage
- [ ] API client with authentication headers
- [ ] Token refresh mechanism
- [ ] Biometric authentication (Face ID/Touch ID)
- [ ] Auto-logout on app backgrounding

#### 1.4 Design System Translation
Translate Tailwind CSS to SwiftUI:
```swift
// Colors.swift
extension Color {
    static let teal500 = Color(hex: "#14B8A6")
    static let teal600 = Color(hex: "#0D9488")
    // ... other colors from Tailwind config
}

// Typography.swift
struct Typography {
    static let headingLarge = Font.custom("Lexend", size: 32)
    static let bodyText = Font.custom("Inter", size: 16)
    // ... other text styles
}
```

### Phase 2: Core Provider Features (Week 3-4)

#### 2.1 Provider Dashboard
- [ ] Dashboard with key metrics from `/api/dashboard` endpoint
- [ ] Recent activities from `/api/activities`
- [ ] Quick actions menu
- [ ] Real-time data refresh

#### 2.2 Patient Management
- [ ] Patient list from `/api/patients`
- [ ] Search and filter functionality
- [ ] Patient detail view with tabs:
  - Overview (patient demographics)
  - Appointments (`/api/appointments?patientId=xxx`)
  - Documents (`/api/files?patientId=xxx`)
  - Billing (`/api/billing/patient/xxx`)
  - Notes (`/api/provider-notes?patientId=xxx`)
- [ ] Add new patient (POST `/api/patients`)
- [ ] Edit patient information (PUT `/api/patients/:id`)

#### 2.3 Calendar & Scheduling
- [ ] Calendar views (day/week/month) using `/api/appointments`
- [ ] Create appointment (POST `/api/appointments`)
- [ ] Edit/cancel appointments
- [ ] Provider availability from `/api/availability`
- [ ] Conflict detection

### Phase 3: Clinical Features (Week 5-6)

#### 3.1 Inquiries Management
- [ ] Inquiry list from `/api/inquiries`
- [ ] Inquiry detail view
- [ ] Update inquiry status (PUT `/api/inquiries/:id/status`)
- [ ] Convert to patient (POST `/api/inquiries/:id/convert`)
- [ ] Contact attempt logging (POST `/api/inquiries/:id/contact-attempts`)

#### 3.2 Evaluations
- [ ] Evaluation list from `/api/evaluations`
- [ ] Create evaluation (POST `/api/evaluations`)
- [ ] Edit evaluation details
- [ ] File attachments
- [ ] Status management

#### 3.3 Messaging
- [ ] Conversation list from `/api/messages/conversations`
- [ ] Message thread view
- [ ] Send message (POST `/api/messages`)
- [ ] Mark as read (PUT `/api/messages/:id/read`)
- [ ] Push notifications setup

### Phase 4: Advanced Features (Week 7-8)

#### 4.1 Documents
- [ ] Document list from `/api/files`
- [ ] PDF viewer for documents
- [ ] Upload documents (POST `/api/files/upload`)
- [ ] Camera integration for document scanning
- [ ] Document categorization

#### 4.2 Billing
- [ ] Invoice list from `/api/billing/invoices`
- [ ] Payment tracking
- [ ] Stripe integration for payments
- [ ] Financial reports from `/api/billing/reports`

#### 4.3 IVR Call Center
- [ ] Call history from `/api/ivr/calls`
- [ ] Analytics dashboard from `/api/ivr/analytics`
- [ ] Call details view
- [ ] Export call reports

### Phase 5: Polish & Optimization (Week 9-10)

#### 5.1 Performance Optimization
- [ ] Image caching for provider photos
- [ ] API response caching with expiration
- [ ] Background data refresh
- [ ] Offline mode for viewing cached data

#### 5.2 iOS-Specific Features
- [ ] Today Widget showing appointments
- [ ] Siri Shortcuts for common actions
- [ ] Apple Watch companion app (basic)
- [ ] iPad optimization with split view

#### 5.3 Testing & Deployment
- [ ] Unit tests for API services
- [ ] UI tests for critical workflows
- [ ] TestFlight beta testing
- [ ] App Store submission preparation

## API Integration Details

### Authentication Flow
```swift
// AuthService.swift
class AuthService {
    func login(email: String, password: String) async throws -> User {
        // POST to /api/auth/login
        // Store JWT token in Keychain
        // Return user object
    }
    
    func refreshToken() async throws {
        // POST to /api/auth/refresh
        // Update stored token
    }
}
```

### Data Models (Matching Prisma Schema)
```swift
// Models/User.swift
struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    let phone: String?
    // ... matches Prisma User model
}

// Models/Appointment.swift
struct Appointment: Codable {
    let id: String
    let title: String?
    let type: AppointmentType
    let scheduledAt: Date
    let duration: Int
    let status: AppointmentStatus
    // ... matches Prisma Appointment model
}
```

### API Service Layer Structure
```
Services/
├── APIClient.swift           // Base networking layer
├── AuthService.swift         // Authentication endpoints
├── PatientService.swift      // Patient CRUD operations
├── AppointmentService.swift  // Appointment management
├── MessageService.swift      // Messaging functionality
├── BillingService.swift      // Billing and invoices
├── IVRService.swift         // IVR call center
└── FileService.swift        // Document management
```

## Security Considerations

### HIPAA Compliance
- [ ] Data encryption at rest using iOS Data Protection
- [ ] Secure communication with TLS/SSL
- [ ] Certificate pinning for production
- [ ] Audit logging of all PHI access
- [ ] Automatic session timeout (configurable)
- [ ] Secure credential storage in Keychain

### App Security
- [ ] Biometric authentication required
- [ ] App screenshot prevention in app switcher
- [ ] Copy/paste restrictions for PHI
- [ ] Jailbreak detection
- [ ] Remote wipe capability via MDM

## Development Environment Setup

### Prerequisites
1. Xcode 15.0 or later
2. iOS 16.0+ deployment target
3. Swift 5.9
4. Access to nbhs-website backend server
5. PostgreSQL database running locally or remotely

### Configuration Steps
1. Clone this repository
2. Open `nbhs-mobile.xcodeproj` in Xcode
3. Update `APIConfig.swift` with your backend URL
4. Configure code signing with your Apple Developer account
5. Run the nbhs-website backend:
   ```bash
   cd ../nbhs-website
   npm run dev:server
   ```
6. Build and run the iOS app

## File Structure
```
nbhs-mobile/
├── App/
│   ├── nbhs_mobileApp.swift
│   └── ContentView.swift
├── Core/
│   ├── API/
│   │   ├── APIClient.swift
│   │   ├── APIConfig.swift
│   │   └── APIError.swift
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Patient.swift
│   │   ├── Appointment.swift
│   │   └── ...
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── PatientService.swift
│   │   └── ...
│   └── Utils/
│       ├── KeychainManager.swift
│       ├── DateFormatter+Extensions.swift
│       └── ...
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   └── BiometricAuthView.swift
│   │   └── ViewModels/
│   │       └── AuthViewModel.swift
│   ├── Dashboard/
│   ├── Patients/
│   ├── Calendar/
│   ├── Messages/
│   ├── Billing/
│   ├── IVR/
│   └── Settings/
├── Design/
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Components/
│       ├── Buttons/
│       ├── Forms/
│       └── Cards/
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## Testing Strategy

### Unit Tests
- API service layer tests
- Model encoding/decoding tests
- Business logic tests
- Keychain storage tests

### Integration Tests
- API endpoint integration
- Authentication flow
- Data synchronization

### UI Tests
- Login flow
- Patient creation
- Appointment scheduling
- Critical user journeys

## Deployment Strategy

### Beta Testing
1. Internal testing with TestFlight
2. Beta testing with select providers
3. Feedback collection and iteration

### App Store Release
1. App Store screenshots preparation
2. App description and metadata
3. Privacy policy and terms of service
4. App Store review submission
5. Phased rollout to users

## Timeline

| Phase | Duration | Deliverables |
|-------|----------|-------------|
| Phase 1: Foundation | 2 weeks | Authentication, API client, design system |
| Phase 2: Core Features | 2 weeks | Dashboard, patients, calendar |
| Phase 3: Clinical | 2 weeks | Inquiries, evaluations, messaging |
| Phase 4: Advanced | 2 weeks | Documents, billing, IVR |
| Phase 5: Polish | 2 weeks | Optimization, testing, deployment |
| **Total** | **10 weeks** | **MVP Release** |

## Success Metrics

### Technical Metrics
- API response time < 2 seconds
- App crash rate < 0.5%
- 99.9% uptime
- Offline capability for core features

### User Metrics
- Provider adoption rate > 80%
- Daily active users > 60%
- Task completion rate > 95%
- User satisfaction score > 4.5/5

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| API rate limiting | High | Implement caching and request batching |
| Network connectivity | High | Offline mode with data sync |
| HIPAA compliance | Critical | Security audit and encryption |
| App Store rejection | Medium | Follow guidelines strictly |
| Backend compatibility | Medium | Version API endpoints |

## Next Steps

1. **Immediate Actions**
   - Set up development environment
   - Create API client foundation
   - Implement authentication flow

2. **Week 1 Goals**
   - Complete login/logout functionality
   - Establish design system
   - Create first API integration (dashboard)

3. **First Milestone**
   - Working authentication
   - Provider dashboard displaying real data
   - Basic patient list functionality

## Questions and Clarifications Needed

1. What is the production API URL?
2. Are there any specific HIPAA compliance requirements?
3. Which features are highest priority for MVP?
4. Should the app support multiple practices?
5. What is the target iOS version (recommend iOS 16+)?

## Conclusion

This plan provides a comprehensive roadmap for developing an iOS app that fully integrates with the existing NBHS backend infrastructure. The app will provide a native iOS experience while leveraging all existing backend services, ensuring consistency and avoiding data duplication.

The key advantage of this approach is that **no backend changes are required** - the iOS app acts as another client to the existing API, similar to how the web frontend works. This ensures data consistency, reduces development time, and maintains a single source of truth in the PostgreSQL database.