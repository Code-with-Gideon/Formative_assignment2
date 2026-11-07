# ALU CampusCare — Campus Incident Reporting App

CampusCare is a mobile application built with Flutter and Google Firebase for the African Leadership University (ALU) campus community in Kigali. It gives students and campus operations staff a direct, transparent way to report, track, and resolve facility and maintenance issues across campus without reports getting lost in informal WhatsApp groups.

### 🔗 Official Project Links
- **YouTube Demonstration Video (9m 57s Full Walkthrough):** [https://youtu.be/WqbBmW0JinQ](https://youtu.be/WqbBmW0JinQ)
- **Live Figma UI/UX Design System & Screens:** [ALU CampusCare — Figma Design File](https://www.figma.com/design/r8063fxio0oJlnPn2PMv74/ALU-CampusCare--UI-UX-Design-System---Screens?node-id=1-705&t=8FvxZpN2DVIUthzl-1)
- **Local Figma Vector Artboards:** [`docs/figma/`](docs/figma/)
- **Full Technical Architecture Report:** [`docs/Technical_Report.md`](docs/Technical_Report.md)

---

## 1. Why CampusCare?

Campus life moves fast, and everyday infrastructure issues—such as low water pressure in the residential pods, a dead HDMI port on a classroom projector, power faults, or broken furniture—often get reported through scattered group chats where nobody can tell if the issue is actually being fixed.

CampusCare brings both sides onto one platform:
- **Students (`@alustudent.com`)** can log an incident in under a minute—picking a category, choosing the exact campus building/room, typing a short description, and attaching a photo—while tracking progress through a 3-stage status stepper (`Submitted` -> `In Progress` -> `Resolved`).
- **Campus Operations & Facilities Staff (`@alueducation.com`)** get a dedicated Staff Triage Dashboard where they can filter incoming tickets, update statuses, and leave timestamped resolution notes (e.g., *"Plumbing technician dispatched to Pod B"*) that sync back to the student's phone in real time.

---

## 2. Key Features

### For Students
- **ALU Institutional Auth & Google Sign-In**: Email/password registration and one-tap **Continue with Google** (`google_sign_in`), strictly restricted to `@alustudent.com` and `@alueducation.com` accounts.
- **6-Category Visual Grid**: Report issues under `Facilities`, `Water`, `Electricity`, `Safety`, `Sanitation`, or `Furniture`.
- **Standardized Campus Locations**: Pre-loaded ALU campus locations (Leadership Center, Block A/B Classrooms, Student Residence Pods, Library, Cafeteria, Sports & Recreation Area, Administration Building).
- **Cloud Storage Photo Evidence**: Attach photos from camera or gallery, uploaded directly to Firebase Cloud Storage (`incidents/{incidentId}/{timestamp}.jpg`).
- **Live 3-Node Status Stepper**: Real-time milestone tracking (`Submitted` -> `In Progress` -> `Resolved`) with staff audit notes.
- **Campus Public Feed & Search**: Search and filter active campus incidents so students can see if a fault in their block has already been logged.
- **Light & Dark Mode (`#002E6D` & `#00132F`)**: Official pixel-sampled ALU Navy, Crimson Red (`#D00D2D`), and Slate Grey (`#77818D`) colour system with local theme persistence via `shared_preferences`.

### For Campus Staff
- **Staff Triage Queue**: Live counters for `All`, `Submitted`, `In Progress`, and `Resolved` tickets.
- **Status Update Modal**: Move any incident between lifecycle states and append operational notes that immediately record a new entry in the incident's `timeline` subcollection.

---

## 3. Folder Structure & Tech Stack

The codebase is organized into four clean layers under `lib/`:

```text
lib/
├── core/
│   ├── constants/       # Official ALU brand colours (#002E6D / #D00D2D), categories & campus locations
│   ├── theme/           # Material 3 Light (#F4F6FA) and Dark (#00132F) theme definitions
│   └── utils/           # Institutional email/form validators and date formatters
├── models/              # UserModel, IncidentModel, and TimelineEventModel (Firestore serialization)
├── providers/           # AuthProvider, IncidentProvider, and ThemeProvider (ChangeNotifier state)
├── services/            # AuthService (FirebaseAuth + Google OAuth), FirestoreService, StorageService
├── screens/
│   ├── auth/            # Login and Registration screens with ALU brand headers
│   ├── student/         # Student Home, Create Incident, My Reports, Campus Feed, Incident Details
│   ├── staff/           # Staff Triage Dashboard & Status Resolution Modal
│   └── shared/          # Profile & Theme Settings screen
└── widgets/             # AluBrandHeader, AluMark, GoogleSignInButton, IncidentCard, StatusTimeline
```

- **Framework**: Flutter (Dart 3 / Material 3)
- **Authentication**: Firebase Authentication (`firebase_auth` + `google_sign_in`)
- **Database**: Cloud Firestore (`cloud_firestore`)
- **Media Storage**: Firebase Cloud Storage (`firebase_storage` + `image_picker`)
- **State Management**: Provider (`ChangeNotifierProvider`)
- **Local Persistence**: `shared_preferences`

---

## 4. Getting Started (Local Setup)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Code-with-Gideon/Formative_assignment2.git
   cd Formative_assignment2
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run automated unit tests & static analysis:**
   ```bash
   flutter test
   dart analyze
   ```

4. **Launch on Android Emulator / Device:**
   ```bash
   flutter run
   ```

---

## 5. Video Demonstration Timestamps (`9m 57s`)

Watch the full walkthrough on YouTube: **[https://youtu.be/WqbBmW0JinQ](https://youtu.be/WqbBmW0JinQ)**

- `0:00 – 1:15` — Introduction, VS Code Folder Structure (`pubspec.yaml` & `lib/`) & Student Home Dashboard
- `1:15 – 2:45` — Reporting a Campus Incident (Category Grid, Campus Location, Description & Photo Upload)
- `2:45 – 3:35` — Student "My Reports", Campus Feed Filtering & Profile Tab
- `3:35 – 5:10` — Institutional Login, Registration & Domain Validation Error Handling (`@alustudent.com` / `@alueducation.com`)
- `5:10 – 6:50` — Staff Triage Dashboard: Filtering Queue, Updating Status (`In Progress` / `Resolved`) & Staff Notes
- `6:50 – 8:00` — "Continue with Google" OAuth Sign-In Flow & Real-Time Student Timeline Stepper Update
- `8:00 – 8:55` — Firebase Storage Console: Verifying Uploaded Incident Photos (`incidents/`)
- `8:55 – 9:25` — Cloud Firestore Console: Inspecting Live `incidents`, `users` & `timeline` Collections
- `9:25 – 9:57` — Firebase Authentication Console (Registered Users & Sign-In Providers) & Wrap-Up

---

## 6. Author

- **Olowoyo Erioluwa Gideon** (`Code-with-Gideon`) — African Leadership University (ALU), Kigali, Rwanda.
