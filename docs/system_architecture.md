# Waste Sorting Assistant - Production Architecture

## 1. System Architecture

### Frontend (Flutter)
- Presentation: screens, widgets, state controllers.
- Domain: models and use-case oriented services.
- Data: Firebase repositories and local cache adapters.

### Backend (Firebase)
- Firebase Auth: email/password authentication.
- Firestore: user profiles, waste catalog, scan history, recycling points.
- Cloud Functions: scheduled weekly eco summary, admin moderation hooks.
- Firebase Messaging: reminders and weekly notifications.

### AI Integration
- Existing image recognition service remains the recognition engine.
- Output normalization maps AI text to canonical waste types and categories.
- If confidence is low, show fallback suggestions and manual category picker.

## 2. Recommended Flutter Folder Structure

lib/
  core/
    constants/
    theme/
    utils/
  models/
    app_user.dart
    waste_item.dart
    scan_record.dart
    recycling_point.dart
    waste_type.dart
  services/
    auth/
      auth_service.dart
    stats/
      scan_history_service.dart
    trash_analysis_service.dart
    notifications_service.dart
    cache_service.dart
  repositories/
    user_repository.dart
    waste_repository.dart
    map_repository.dart
  screens/
    auth/
      auth_screen.dart
    home/
      home_screen.dart
    scan/
      camera_screen.dart
      result_screen.dart
    stats/
      stats_screen.dart
    map/
      recycling_map_screen.dart
    admin/
      admin_panel_screen.dart
  widgets/
    common/

## 3. Firestore Collections and Schema

### users/{uid}
- name: string
- email: string
- ecoPoints: number
- level: string
- achievements: array<string>
- favorites: array<string>
- createdAt: timestamp/string
- lastScanAt: timestamp/string
- role: string (user/admin)

### waste_items/{itemId}
- name: string
- type: string (plastic/paper/glass/metal/organic)
- category: string (recyclable/non_recyclable)
- binColor: string
- explanation: string
- aliases: array<string>
- updatedAt: timestamp

### scan_history/{scanId}
- userId: string
- wasteName: string
- wasteType: string
- category: string
- pointsAwarded: number
- scannedAt: timestamp/string
- imagePath: string
- aiConfidence: number
- aiSuggestion: string
- isFavorite: bool

### recycling_points/{pointId}
- name: string
- location: geopoint or {lat, lng}
- address: string
- acceptedTypes: array<string>
- workingHours: string
- phone: string
- isActive: bool

## 4. Feature Mapping

- Authentication: Auth service + users collection profile initialization.
- Waste recognition: Existing camera + AI service, then normalized to domain model.
- Sorting instruction: bin color + explanation rendered in result screen.
- Map: Google Maps markers from recycling_points collection.
- Statistics: aggregate from scan_history by type and weekday.
- Notifications: FCM token per user, cloud scheduled summary.
- Gamification: ecoPoints, level thresholds, achievements.
- Favorites: isFavorite in scans and favorite IDs in user profile.
- Offline mode: cache latest scans and static fallback instructions locally.
- Admin panel: role-based UI and write access to waste_items/recycling_points.

## 5. Cloud Functions (Suggested)

1. onScanCreated
- Trigger: scan_history document creation.
- Action: increment user ecoPoints, evaluate achievements.

2. weeklyEcoSummary
- Trigger: pubsub scheduler once per week.
- Action: build per-user summary and send FCM message.

3. adminAuditLog
- Trigger: writes to waste_items and recycling_points.
- Action: store moderator logs for accountability.

## 6. Step-by-Step Delivery Plan

1. Foundation
- Add Firebase packages and initialize app.
- Setup env config and CI checks.

2. Identity and Profile
- Build auth flow and user profile creation.
- Add account settings and sign out.

3. Recognition and Result Domain
- Normalize AI output into structured waste records.
- Save scan history and points.

4. Stats and Gamification
- Implement dashboard charts and level progression.
- Add achievements rules and badges.

5. Maps and Recycling Network
- Add map page and marker filtering by accepted waste types.

6. Notifications and Offline
- Register FCM token and schedule reminders.
- Cache last scans and static sorting guide.

7. Admin Panel and Security Hardening
- Add role-gated admin views.
- Finalize strict Firestore rules and validation.

8. QA and Release
- Unit tests for services.
- Widget tests for key screens.
- Firebase Emulator regression tests.
- Store release checklist.

## 7. Senior Engineering Decisions

- Keep AI output separate from canonical domain model so provider changes do not break business logic.
- Store role and points on user profile for fast home dashboard rendering.
- Put authoritative point calculations in Cloud Functions to prevent client-side abuse.
- Use progressive enhancement: app works offline with cached instructions and syncs later.
- Favor repository/service boundaries to keep diploma project maintainable and easy to defend.
