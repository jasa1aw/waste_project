# Admin Panel — razdelchik

Flutter admin panel built directly inside the existing `razdelchik` project.
Entry point: **`lib/screens/admin/admin_shell.dart`** (`AdminShell` widget).

---

## Access

The "Әкімші панелі" button appears on the Home screen for any logged-in user.
To restrict access to real admins, set `role: 'admin'` on the user's Firestore doc
in the `users` collection. Add a guard in `AdminShell.build()` using
`AuthService().watchProfile(uid)` and redirect non-admins back if needed.

---

## Sections & Routes

All sections are rendered inside `AdminShell` via `IndexedStack` — no named routes needed.

| Index | Title (KZ) | Screen | Service |
|-------|-----------|--------|---------|
| 0 | Аналитика | `admin/analytics/admin_analytics_screen.dart` | `admin_analytics_service.dart` |
| 1 | Пайдаланушылар | `admin/users/admin_users_screen.dart` | `admin_user_service.dart` |
| 2 | Қабылдау пункттері | `admin/recycling_points/admin_recycling_screen.dart` | `admin_recycling_service.dart` |
| 3 | Сканерлер | `admin/scans/admin_scans_screen.dart` | `admin_scan_service.dart` |
| 4 | Қалдықтар базасы | `admin/waste_items/admin_waste_screen.dart` | `admin_waste_service.dart` |
| 5 | Аудит журналы | `admin/audit/admin_audit_screen.dart` | `admin_audit_service.dart` |

---

## Firestore Collections Used

| Collection | Sections that read | Sections that write |
|------------|-------------------|---------------------|
| `users` | Users, Analytics | Users (isBlocked, ecoPoints) |
| `scan_history` | Scans, Analytics | Scans (delete) |
| `recycling_points` | Recycling Points | Recycling Points (add/update/delete) |
| `waste_items` | Waste Items | Waste Items (add/update/soft-delete) |
| `leaderboard` | Analytics | — |
| `adminAuditLog` | Audit Log | Users, Scans (writes on every mutating action) |

---

## Shared Widgets

| Widget | Path | Used by |
|--------|------|---------|
| `AdminDataTable<T>` | `lib/widgets/admin/admin_data_table.dart` | Users, Audit Log |

---

## File Structure

```
lib/
├── models/
│   └── audit_log_entry.dart          # New model for audit log entries
├── screens/
│   └── admin/
│       ├── admin_shell.dart           # Root shell with NavigationDrawer
│       ├── analytics/
│       │   └── admin_analytics_screen.dart
│       ├── audit/
│       │   └── admin_audit_screen.dart
│       ├── recycling_points/
│       │   ├── admin_recycling_screen.dart
│       │   └── admin_recycling_form_sheet.dart
│       ├── scans/
│       │   └── admin_scans_screen.dart
│       ├── users/
│       │   ├── admin_users_screen.dart
│       │   └── admin_user_detail_sheet.dart
│       └── waste_items/
│           ├── admin_waste_screen.dart
│           └── admin_waste_form_sheet.dart
├── services/
│   └── admin/
│       ├── admin_analytics_service.dart
│       ├── admin_audit_service.dart
│       ├── admin_recycling_service.dart
│       ├── admin_scan_service.dart
│       ├── admin_user_service.dart
│       └── admin_waste_service.dart
└── widgets/
    └── admin/
        └── admin_data_table.dart
```

---

## Audit Log

Every mutating admin action writes to `adminAuditLog` with this shape:

```json
{
  "adminEmail": "admin@example.com",
  "action": "adjust_eco_points | delete_scan | block_user | ...",
  "targetUserId": "...",
  "delta": 50,
  "reason": "manual correction",
  "timestamp": "2026-06-15T10:00:00.000Z"
}
```

---

## Dependencies (already in pubspec.yaml)

- `cloud_firestore` — all Firestore reads/writes
- `firebase_auth` — current admin identity
- `fl_chart` — bar/line/pie charts in Analytics and Scans
- `flutter_map` + `latlong2` — map view in Recycling Points
- `path_provider` — CSV export in Audit Log
