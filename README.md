# ALU CampusCare (Campus Incident Reporting App)

CampusCare is a mobile application developed for the African Leadership University (ALU) campus community. It provides a simple, direct bridge between students and campus operations staff to report, track, and resolve facility and security issues across campus.

---

## 1. Problem Overview

Campus life moves quickly, and maintenance challenges—such as water shortages in residential halls, broken laboratory projectors, electrical faults, and sanitation concerns—often go unaddressed or get lost in informal WhatsApp groups. 

CampusCare provides a centralized, role-based platform where:
- **Students** can submit detailed incident reports with categories, precise campus locations, descriptions, and photographic evidence, while tracking progress through a live status timeline.
- **Campus Facilities and Administration Staff** receive incoming issues in an organized triage queue, assign work orders, update statuses, and log resolution notes in real time.

---

## 2. Key Features

### For Students
- **ALU Institutional Verification**: Sign up and login restricted to authorized ALU institutional emails (`@alustudent.com` and `@alueducation.com`).
- **One-Tap Reporting**: Submit issues categorized under Facilities, Water, Electricity, Safety, Sanitation, or Furniture.
- **Location Pinpointing**: Pre-configured campus locations (e.g. Block B Room 204, Cafeteria, Student Residences).
- **Photo Verification**: Attach photos using camera capture or gallery selection via Firebase Storage.
- **Status Stepper**: Visual milestone tracking from `Submitted` to `In Progress` to `Resolved`.
- **Search and Campus Feed**: Browse public reports to confirm if an issue has already been reported.

### For Campus Staff
- **Triage Dashboard**: High-level counters for Submitted, In Progress, and Resolved tickets.
- **Status Management**: Move incidents between states and append operational notes (e.g., "Plumbing technician team dispatched").
- **Real-Time Synchronization**: Instant status reflection on student devices without manual pull-to-refresh.

---

## 3. System Architecture & Tech Stack

The application follows clean architectural separation between User Interface, State Management, and Backend Services:

```
lib/
├── core/
│   ├── constants/       # App colors, category definitions, and location lists
│   ├── theme/           # Light and Dark theme configurations
│   └── utils/           # Validation logic and date formatters
├── models/              # UserModel, IncidentModel, and TimelineEventModel
├── providers/           # AuthProvider, IncidentProvider, and ThemeProvider
├── services/            # AuthService, FirestoreService, and StorageService
├── screens/
│   ├── auth/            # Login and Registration screens
│   ├── student/         # Student Home, Create Incident, My Reports, Details
│   ├── staff/           # Staff Triage Dashboard
│   └── shared/          # Profile and Settings
└── widgets/             # Reusable UI cards, status badges, and timeline steppers
```

- **Framework**: Flutter (Dart)
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage (Incident attachments)
- **State Management**: Provider (`ChangeNotifier`)
- **Local Persistence**: `shared_preferences` (Dark Mode preference)

---

## 4. Setup & Running the App

### Prerequisites
- Flutter SDK (version 3.14.0 or later)
- Android Studio or Xcode (with Android Emulator or iOS Simulator)
- Firebase CLI installed (`npm install -g firebase-tools`)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Code-with-Gideon/Formative_assignment2.git
   cd Formative_assignment2
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Configure your Firebase Project:**
   Run the FlutterFire CLI command from the root of the project to link your Firebase project:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```

4. **Run Unit Tests:**
   ```bash
   flutter test
   ```

5. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 5. Security & Access Control

- **Domain Enforcement**: Registration validates email strings against authorized institutional suffixes.
- **Role Verification**: User documents stored in Firestore designate student or staff privileges, guarding administrative triage controls from student access.
- **Storage Isolation**: Photos uploaded by students are structured under `incidents/{incidentId}/{timestamp}.jpg` to ensure trace integrity.

---

## 6. License & Academic Integrity

Developed for ALU Individual Assignment 2 (Campus Incident Reporting App). All submitted code represents original implementation following course specifications and design rubrics.
