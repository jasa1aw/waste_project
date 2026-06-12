# Graph Report - .  (2026-06-12)

## Corpus Check
- Large corpus: 158 files · ~761,441 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 731 nodes · 847 edges · 80 communities (57 shown, 23 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 21 edges (avg confidence: 0.85)
- Token cost: 500 input · 120 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Auth Service Layer|Auth Service Layer]]
- [[_COMMUNITY_Firebase & Async Core|Firebase & Async Core]]
- [[_COMMUNITY_Windows Plugin Registry|Windows Plugin Registry]]
- [[_COMMUNITY_Premium UI Components|Premium UI Components]]
- [[_COMMUNITY_Docs & AI Integration|Docs & AI Integration]]
- [[_COMMUNITY_Camera & Home Screen|Camera & Home Screen]]
- [[_COMMUNITY_LinuxmacOS Plugin Registry|Linux/macOS Plugin Registry]]
- [[_COMMUNITY_Scan History & Results|Scan History & Results]]
- [[_COMMUNITY_Theme & Design System|Theme & Design System]]
- [[_COMMUNITY_Scan Detail & Animation|Scan Detail & Animation]]
- [[_COMMUNITY_Firebase Configuration|Firebase Configuration]]
- [[_COMMUNITY_User Data Models|User Data Models]]
- [[_COMMUNITY_Home Screen Features|Home Screen Features]]
- [[_COMMUNITY_Auth Screen UI|Auth Screen UI]]
- [[_COMMUNITY_iOS App Delegate|iOS App Delegate]]
- [[_COMMUNITY_macOS App Icons|macOS App Icons]]
- [[_COMMUNITY_HTTP & Storage Services|HTTP & Storage Services]]
- [[_COMMUNITY_Waste Item Models|Waste Item Models]]
- [[_COMMUNITY_Scan Detail Screen|Scan Detail Screen]]
- [[_COMMUNITY_Scan Record Models|Scan Record Models]]
- [[_COMMUNITY_Points & Gamification|Points & Gamification]]
- [[_COMMUNITY_Leaderboard Screen|Leaderboard Screen]]
- [[_COMMUNITY_Profile Screen|Profile Screen]]
- [[_COMMUNITY_Settings Screen|Settings Screen]]
- [[_COMMUNITY_Onboarding Flow|Onboarding Flow]]
- [[_COMMUNITY_Challenge System|Challenge System]]
- [[_COMMUNITY_Notification Service|Notification Service]]
- [[_COMMUNITY_Android Resources|Android Resources]]
- [[_COMMUNITY_Web PWA Icons|Web PWA Icons]]
- [[_COMMUNITY_iOS Launch Images|iOS Launch Images]]
- [[_COMMUNITY_Android Splash Assets|Android Splash Assets]]
- [[_COMMUNITY_iOS App Icon Set|iOS App Icon Set]]
- [[_COMMUNITY_Android Mipmap Icons|Android Mipmap Icons]]
- [[_COMMUNITY_Asset Icons|Asset Icons]]
- [[_COMMUNITY_App Branding|App Branding]]
- [[_COMMUNITY_Windows Build System|Windows Build System]]
- [[_COMMUNITY_Linux Build System|Linux Build System]]
- [[_COMMUNITY_Cloud Functions|Cloud Functions]]
- [[_COMMUNITY_Firestore Collections|Firestore Collections]]
- [[_COMMUNITY_AI Waste Recognition|AI Waste Recognition]]
- [[_COMMUNITY_Stats & Analytics|Stats & Analytics]]
- [[_COMMUNITY_Eco Tips Content|Eco Tips Content]]
- [[_COMMUNITY_Recycling Categories|Recycling Categories]]
- [[_COMMUNITY_Map Screen|Map Screen]]
- [[_COMMUNITY_Flutter Core|Flutter Core]]
- [[_COMMUNITY_Dart Packages|Dart Packages]]
- [[_COMMUNITY_Build Config|Build Config]]
- [[_COMMUNITY_Test Infrastructure|Test Infrastructure]]
- [[_COMMUNITY_Error Handling|Error Handling]]
- [[_COMMUNITY_Navigation & Routing|Navigation & Routing]]
- [[_COMMUNITY_Localization|Localization]]
- [[_COMMUNITY_Shared Preferences|Shared Preferences]]
- [[_COMMUNITY_Image Processing|Image Processing]]
- [[_COMMUNITY_Provider State Mgmt|Provider State Mgmt]]
- [[_COMMUNITY_Firebase Storage|Firebase Storage]]
- [[_COMMUNITY_Push Notifications|Push Notifications]]
- [[_COMMUNITY_Deep Links|Deep Links]]
- [[_COMMUNITY_App Lifecycle|App Lifecycle]]
- [[_COMMUNITY_Accessibility|Accessibility]]
- [[_COMMUNITY_Dark Mode|Dark Mode]]
- [[_COMMUNITY_Premium Features|Premium Features]]
- [[_COMMUNITY_Subscription Logic|Subscription Logic]]
- [[_COMMUNITY_Payment Integration|Payment Integration]]
- [[_COMMUNITY_Analytics Events|Analytics Events]]
- [[_COMMUNITY_Crash Reporting|Crash Reporting]]
- [[_COMMUNITY_App Update Logic|App Update Logic]]
- [[_COMMUNITY_Date Time Utils|Date Time Utils]]
- [[_COMMUNITY_Network Utils|Network Utils]]
- [[_COMMUNITY_UI Helpers|UI Helpers]]

## God Nodes (most connected - your core abstractions)
1. `Razdelchik pubspec.yaml` - 12 edges
2. `System Architecture Document` - 12 edges
3. `Create()` - 10 edges
4. `MessageHandler()` - 10 edges
5. `WndProc()` - 9 edges
6. `Runner Executable (BINARY_NAME)` - 8 edges
7. `macOS App Icon 1024px - Flutter Default Icon` - 8 edges
8. `HWND` - 7 edges
9. `WindowClassRegistrar` - 7 edges
10. `Destroy()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Technology Report (Kazakh)` --semantically_similar_to--> `System Architecture Document`  [INFERRED] [semantically similar]
  graphify-out/converted/Технологиялар_Есебі_dace2ac2.md → docs/system_architecture.md
- `Project Graphify Instructions` --semantically_similar_to--> `Claude Graphify Skill Trigger`  [INFERRED] [semantically similar]
  CLAUDE.md → .claude/CLAUDE.md
- `Firebase Backend Layer` --conceptually_related_to--> `cloud_firestore Package`  [INFERRED]
  docs/system_architecture.md → pubspec.yaml
- `Firebase Backend Layer` --conceptually_related_to--> `cloud_functions Package`  [INFERRED]
  docs/system_architecture.md → pubspec.yaml
- `Firebase Backend Layer` --conceptually_related_to--> `firebase_auth Package`  [INFERRED]
  docs/system_architecture.md → pubspec.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Firebase Backend Services (auth, firestore, functions, messaging)** — pubspec_firebase_auth, pubspec_cloud_firestore, pubspec_cloud_functions, pubspec_firebase_messaging, docs_firebase_backend [INFERRED 0.95]
- **Waste Recognition Pipeline (camera, AI, scan history)** — pubspec_camera, pubspec_image_picker, docs_ai_integration, docs_firestore_scan_history, docs_cloud_function_onscan [INFERRED 0.85]
- **Gamification and Points Pipeline** — docs_gamification, docs_cloud_function_onscan, docs_firestore_users, docs_firestore_scan_history [EXTRACTED 1.00]

## Communities (80 total, 23 thin omitted)

### Community 0 - "Auth Service Layer"
Cohesion: 0.04
Nodes (45): _auth, AuthService, authStateChanges, currentUser, _extractNameFromEmail, _firestore, _leaderboardService, registerWithEmail (+37 more)

### Community 1 - "Firebase & Async Core"
Cohesion: 0.05
Nodes (42): @pragma, dart:async, FirebaseMessaging, Future, android, DefaultFirebaseOptions, ios, windows (+34 more)

### Community 2 - "Windows Plugin Registry"
Cohesion: 0.09
Nodes (34): RegisterPlugins(), PluginRegistry, Point, RECT, OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable() (+26 more)

### Community 3 - "Premium UI Components"
Cohesion: 0.06
Nodes (37): backgroundColor, build, createState, foregroundColor, icon, label, onPressed, _onTapCancel (+29 more)

### Community 4 - "Docs & AI Integration"
Cohesion: 0.10
Nodes (29): Technology Report (Kazakh), AI Image Recognition Integration, Cloud Function adminAuditLog, Cloud Function onScanCreated, Cloud Function weeklyEcoSummary, Firebase Backend Layer, Firestore recycling_points Collection Schema, Firestore scan_history Collection Schema (+21 more)

### Community 5 - "Camera & Home Screen"
Cohesion: 0.09
Nodes (24): CameraController?, build, MaterialPageRoute, package:camera/camera.dart, package:image_picker/image_picker.dart, package:razdelchik/screens/result_screen.dart, package:razdelchik/services/trash_analysis_service.dart, _analysisService (+16 more)

### Community 6 - "Linux/macOS Plugin Registry"
Cohesion: 0.11
Nodes (20): FlPluginRegistry, fl_register_plugins(), GApplication, gboolean, gchar, GObject, GtkApplication, MyApplicationClass (+12 more)

### Community 7 - "Scan History & Results"
Cohesion: 0.10
Nodes (20): ScanHistoryService, analysisResult, binColor, build, _buildInsights, category, createState, imagePath (+12 more)

### Community 8 - "Theme & Design System"
Cohesion: 0.10
Nodes (20): static const Color, AppTheme, backgroundDark, backgroundLight, darkTheme, elevatedDark, glass, lightTheme (+12 more)

### Community 9 - "Scan Detail & Animation"
Cohesion: 0.10
Nodes (19): AnimationController, package:razdelchik/screens/scan_detail_screen.dart, _buildAppBar, _buildEmptyState, _buildFilterChips, _buildRecordsList, _colorForType, createState (+11 more)

### Community 10 - "Firebase Configuration"
Cohesion: 0.12
Nodes (19): default, android, ios, windows, lib/firebase_options.dart, appId, fileOutput, projectId (+11 more)

### Community 11 - "User Data Models"
Cohesion: 0.11
Nodes (17): DateTime, AppUser, createdAt, ecoPoints, email, fromMap, id, name (+9 more)

### Community 12 - "Home Screen Features"
Cohesion: 0.13
Nodes (18): _challengeOfDay, _EngagementHub, HomeScreen, label, _MetricPill, _QuickTypesRow, _StatsPreview, _TopBar (+10 more)

### Community 13 - "Auth Screen UI"
Cohesion: 0.12
Nodes (16): AuthScreen, _AuthScreenState, _authService, build, createState, dispose, _emailController, _formKey (+8 more)

### Community 14 - "iOS App Delegate"
Cohesion: 0.14
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, Bool, AppDelegate, Bool, AppDelegate (+2 more)

### Community 15 - "macOS App Icons"
Cohesion: 0.15
Nodes (15): macOS App Icon 1024px - Flutter Default Icon, macOS App Icon 128px - Flutter Default Icon, macOS App Icon 16px - Flutter Default Icon, macOS App Icon 256px - Flutter Default Icon, macOS App Icon 32px - Flutter Default Icon, macOS App Icon 512px - Flutter Default Icon, macOS App Icon 64px - Flutter Default Icon, Web PWA Icon 192px - Flutter Default Icon (+7 more)

### Community 16 - "HTTP & Storage Services"
Cohesion: 0.13
Nodes (14): dart:convert, dart:io, package:http/http.dart, package:path_provider/path_provider.dart, analyzeImage, _formatResponse, _getApiKey, _isMissingModelEndpoint (+6 more)

### Community 17 - "Waste Item Models"
Cohesion: 0.13
Nodes (14): double?, aiConfidence, aiSuggestion, binColor, category, explanation, fromMap, id (+6 more)

### Community 18 - "Scan Detail Screen"
Cohesion: 0.13
Nodes (14): build, color, _colorForType, _ecoTip, _formatDate, _formatTime, icon, iconColor (+6 more)

### Community 19 - "Scan Record Models"
Cohesion: 0.14
Nodes (13): category, fromMap, id, imagePath, isFavorite, pointsAwarded, scannedAt, ScanRecord (+5 more)

### Community 20 - "Points & Gamification"
Cohesion: 0.21
Nodes (12): flutter_assemble Custom Target, flutter Interface Library, Flutter Library (flutter_windows.dll), flutter_wrapper_app Static Library, flutter_wrapper_plugin Static Library, generated_config.cmake, flutter_window.cpp, generated_plugin_registrant.cc (+4 more)

### Community 21 - "Leaderboard Screen"
Cohesion: 0.23
Nodes (9): _In_, _In_opt_, wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), vector, string (+1 more)

### Community 22 - "Profile Screen"
Cohesion: 0.17
Nodes (11): package:fl_chart/fl_chart.dart, package:razdelchik/services/stats/scan_history_service.dart, StatsSummary, _BasicReports, build, _buildTypeSections, _colorForType, stats (+3 more)

### Community 23 - "Settings Screen"
Cohesion: 0.18
Nodes (10): Color?, package:razdelchik/screens/auth/auth_screen.dart, package:razdelchik/screens/camera_screen.dart, package:razdelchik/screens/leaderboard_screen.dart, package:razdelchik/screens/stats/stats_screen.dart, package:razdelchik/widgets/common/premium_action_button.dart, _BadgeChip, color (+2 more)

### Community 24 - "Onboarding Flow"
Cohesion: 0.18
Nodes (10): List, acceptedTypes, address, fromMap, id, latitude, longitude, name (+2 more)

### Community 25 - "Challenge System"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 26 - "Notification Service"
Cohesion: 0.22
Nodes (8): DartProject, MessageHandler(), HWND, LPARAM, LRESULT, FlutterWindow(), UINT, WPARAM

### Community 27 - "Android Resources"
Cohesion: 0.20
Nodes (9): package:flutter_map/flutter_map.dart, package:latlong2/latlong.dart, package:razdelchik/services/recycling_points_service.dart, build, _defaultCenter, MapScreen, _openPointSheet, _translateType (+1 more)

### Community 28 - "Web PWA Icons"
Cohesion: 0.22
Nodes (8): category, WasteCategory, wasteCategoryFromString, wasteCategoryToString, WasteType, wasteTypeFromString, wasteTypeToString, return

### Community 29 - "iOS Launch Images"
Cohesion: 0.25
Nodes (8): iOS App Icon 1024x1024@1x - White stylized leaf/tree on dark green circular badge, green background; primary store icon for waste sorting app, iOS App Icon 20x20@1x - Tiny green icon with white leaf/tree symbol, notification/settings use, iOS App Icon 20x20@2x - Small green rounded icon with white leaf/tree, notification/settings use @2x, iOS App Icon 20x20@3x - Small green rounded icon with white leaf/tree, notification/settings use @3x, iOS App Icon 29x29@1x - Green icon with white leaf/tree symbol, settings/spotlight use @1x, iOS App Icon 29x29@2x - Green rounded icon with white leaf/tree on circle, settings/spotlight @2x, iOS App Icon 29x29@3x - Green icon with white stylized leaf/tree on circular badge, settings/spotlight @3x, Generated Splash Logo - Green rounded-square app icon with white recycling arrow circle and leaf symbol, eco waste sorting app brand mark

### Community 30 - "Android Splash Assets"
Cohesion: 0.25
Nodes (7): build, child, padding, SoftCard, EdgeInsetsGeometry, package:flutter/material.dart, Widget

### Community 31 - "iOS App Icon Set"
Cohesion: 0.29
Nodes (6): client, configuration_version, project_info, project_id, project_number, storage_bucket

### Community 32 - "Android Mipmap Icons"
Cohesion: 0.29
Nodes (7): App Icon Asset - Green background with white leaf/tree silhouette in a circle; primary brand icon for the waste/ecology app, Splash Screen Icon (xxxhdpi) - Green rounded-square app icon with white recycling arrow and leaf symbol; eco/recycling/waste management brand identity, App Launcher Icon (hdpi) - Green circular icon with white stylized leaf/tree silhouette; eco/nature theme consistent with brand, App Launcher Icon (mdpi) - Green circular icon with white leaf/tree; same brand as hdpi variant, App Launcher Icon (xhdpi) - Green circular icon with white leaf/tree; same brand as other density variants, App Launcher Icon (xxhdpi) - Green circular icon with white leaf/tree; same brand as other density variants, App Launcher Icon (xxxhdpi) - Green circular icon with white leaf/tree; same brand as other density variants

### Community 33 - "Asset Icons"
Cohesion: 0.29
Nodes (4): RegisterGeneratedPlugins(), FlutterPluginRegistry, NSWindow, MainFlutterWindow

### Community 34 - "App Branding"
Cohesion: 0.29
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 35 - "Windows Build System"
Cohesion: 0.53
Nodes (6): App Splash Screen Brand Identity, Android HDPI Splash Screen, Android MDPI Splash Screen, Android API 21+ Background Drawable, Android XHDPI Splash Screen, Android XXHDPI Splash Screen

### Community 36 - "Linux Build System"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 37 - "Cloud Functions"
Cohesion: 0.33
Nodes (5): package:firebase_auth/firebase_auth.dart, package:razdelchik/services/leaderboard_service.dart, package:razdelchik/widgets/common/soft_card.dart, build, LeaderboardScreen

### Community 38 - "Firestore Collections"
Cohesion: 0.40
Nodes (3): FlutterActivity, MainActivity, MainActivity

### Community 39 - "AI Waste Recognition"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 40 - "Stats & Analytics"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 41 - "Eco Tips Content"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 42 - "Recycling Categories"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 43 - "Map Screen"
Cohesion: 0.83
Nodes (4): App Launcher Icon Brand Identity, Android MDPI Launcher Foreground Icon, Android XHDPI Launcher Foreground Icon, Android XXHDPI Launcher Foreground Icon

### Community 45 - "Dart Packages"
Cohesion: 0.50
Nodes (3): package:flutter_test/flutter_test.dart, package:razdelchik/main.dart, main

### Community 46 - "Build Config"
Cohesion: 0.67
Nodes (3): App Icon 40x40 @1x, App Icon 40x40 @2x, App Icon 40x40 @3x

## Knowledge Gaps
- **385 isolated node(s):** `PreToolUse`, `cmake.sourceDirectory`, `project_number`, `project_id`, `storage_bucket` (+380 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `WasteCategory` connect `Web PWA Icons` to `Waste Item Models`, `Scan Record Models`, `Scan History & Results`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `ScanRecord` connect `Scan Record Models` to `Scan Detail & Animation`, `Scan Detail Screen`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `StatsSummary` connect `Profile Screen` to `Auth Service Layer`, `Home Screen Features`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `PreToolUse`, `cmake.sourceDirectory`, `project_number` to the rest of the system?**
  _386 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Auth Service Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.04336734693877551 - nodes in this community are weakly interconnected._
- **Should `Firebase & Async Core` be split into smaller, more focused modules?**
  _Cohesion score 0.046464646464646465 - nodes in this community are weakly interconnected._
- **Should `Windows Plugin Registry` be split into smaller, more focused modules?**
  _Cohesion score 0.08658536585365853 - nodes in this community are weakly interconnected._