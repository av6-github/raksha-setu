# RakshaSetu (रक्षासेतु) — Secure Personnel Welfare & Operational Readiness Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%2017-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Pinecone](https://img.shields.io/badge/Pinecone-Vector%20DB%20384d-000000?logo=pinecone&logoColor=white)](https://pinecone.io)
[![Quality Gate](https://img.shields.io/badge/Tests-271%20Passed-brightgreen)](file:///d:/raksha-sih/test)
[![Analyzer](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen)](file:///d:/raksha-sih)

**RakshaSetu** is an enterprise-grade, privacy-first welfare and readiness ecosystem engineered specifically for **Central Armed Police Forces (CAPF)**—including CRPF, BSF, ITBP, CISF, SSB, and Assam Rifles. 

The platform bridges operational command needs with confidential mental health care, family morale pipelines, and statutory welfare benefit discovery while strictly enforcing cryptographic firewalls and statutory privacy thresholds.

---

## Table of Contents
1. [Core Architectural Guarantees](#1-core-architectural-guarantees)
2. [Role-Based Feature Matrix & Implementation Depth](#2-role-based-feature-matrix--implementation-depth)
3. [Component Honesty Matrix (Real vs Simulated)](#3-component-honesty-matrix)
4. [Tech Stack & Architecture](#4-tech-stack--architecture)
5. [Prerequisites & Development Environment](#5-prerequisites--development-environment)
6. [Step-by-Step Installation & Running Guide](#6-step-by-step-installation--running-guide)
7. [Demo Accounts & Profile PIN Cheat Sheet](#7-demo-accounts--profile-pin-cheat-sheet)
8. [Automated Verification & Test Suites](#8-automated-verification--test-suites)
9. [Project Directory Layout](#9-project-directory-layout)

---

## 1. Core Architectural Guarantees

Raksha is designed around four inviolable architectural constraints:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        RAKSHA SECURITY POSTURE                         │
├──────────────────────────────────┬─────────────────────────────────────┤
│ 1. Welfare-HR Firewall           │ 2. Statutory k-Anonymity (k ≥ 10)   │
│    • Clinical data isolated from │    • Aggregate unit metrics suppress│
│      ACR, HRMS, and Commanders   │      automatically when unit size   │
│    • Zero individual stress      │      is below 10 personnel          │
│      scores in command consoles  │    • Prevents identity deduction    │
├──────────────────────────────────┼─────────────────────────────────────┤
│ 3. Zero-AI Safety Protocol       │ 4. Cryptographic Whistleblowing     │
│    • Crisis & SOS routes bypass  │    • Non-reversible SHA-256 tokens  │
│      LLMs completely             │    • Zero identity link to author   │
│    • Direct human responder      │    • Whistleblower tracks status    │
│      routing to Tele-MANAS / MHA │      anonymously via receipt token  │
└──────────────────────────────────┴─────────────────────────────────────┘
```

1. **Welfare-HR Firewall**: Individual psychometric assessments (PHQ-9, GAD-7), counsellor notes, and check-in entries are strictly walled off from HRMS, Annual Confidential Reports (ACR), and Commander consoles via PostgreSQL Row-Level Security (RLS) and cryptographic access boundaries.
2. **Statutory $k$-Anonymity ($k \ge 10$)**: Commanding officers view only aggregate readiness and fatigue indicators. If a selected unit or deployment has fewer than 10 personnel, individual identification risks are mitigated by suppressing aggregate calculations with a statutory privacy alert.
3. **Zero-AI Guarantee on Crisis Paths**: Any suicidal ideation, distress disclosure, or emergency SOS routes bypass LLMs and automated conversational bots entirely, immediately routing to certified human counsellors, unit medical officers, and national emergency lifelines (112, 14416 Tele-MANAS).
4. **Zero-Knowledge Anonymous Whistleblowing**: Reports are cryptographically dissociated from the submitter’s account. Whistleblowers are issued a one-way tracking token (`TK-XXXX-XXXX-XXXX`) allowing them to track status without revealing their identity.

---

## 2. Role-Based Feature Matrix & Implementation Depth

The platform features six dedicated user roles, each equipped with tailored capabilities:

### A. Individual Officer Profile (Vikram Singh, Priya Nair, Arjun Thakur)
* **Personal Analytics & Telemetry**: Visualizes resting heart rate, sleep duration, HRV RMSSD trends, and duty cycles against personal moving baselines.
* **Clinical Health & Check-Ins**: Interactive biweekly check-ins and clinically validated psychometric instruments (PHQ-9 for depression screening, GAD-7 for anxiety).
* **HRMS & Leave Friction Tracking**: Submit leave applications directly from the app; monitors operational rejections, consecutive duty days, and leave friction index.
* **Family Morale Vault**: An encrypted private vault where deployed personnel receive text notes, photographs, and audio messages from verified family members.
* **Whistleblower & Grievance Portal**: Securely file anonymous safety or operational grievances with location sanitization (platoon/sentry details stripped).
* **Welfare Schemes RAG Copilot**: Ask conversational questions in natural language about Ayushman CAPF, Prime Minister's Scholarship Scheme (PMSS), Bharat Ke Veer, and Ex-Gratia compensation.

### B. Commanding Officer Profile (Col. Rajesh Sharma — 12 BN CRPF)
* **Unit Readiness & Operational Index**: High-level readiness percentage, fatigue roster ratios, and leave friction indices computed across battalion personnel.
* **Algorithmic Roster Interventions**: Automated alerts for fatigue mitigation (e.g. night patrol rotation advisories) and respite leave balancing.
* **Binary Operational Availability**: Strict binary availability list (`AVAILABLE` vs `MEDICALLY UNAVAILABLE`) displaying zero diagnostic, medical, or clinical labels.
* **Unit Reports & Whistleblower Actions**: Reviews anonymous unit-level grievances (equipment, duty anomalies) and records administrative actions taken (`action_taken`).
* **$k < 10$ Suppression Toggle**: Switch between **12 BN Charlie Company** (14 personnel, full aggregate data) and **Forward Detachment** (6 personnel, triggers statutory suppression warning).

### C. Counsellor Profile (Dr. Ananya Iyer)
* **Clinical Caseload Triage**: Real-time view of active cases flagged by check-in anomalies or self-assessments.
* **Item-Level Psychometric Inspection**: Granular question-by-question review of PHQ-9 (including Question 9 self-harm monitoring) and GAD-7 trajectories.
* **Suicide Protocol & Safety Planning**: Trigger suicide protocol actions and collaborate on standardized 6-step Safety Plans.
* **Clinical Follow-Ups & Notes**: Document appointment outcomes and follow-up schedules.

### D. Welfare Officer Profile (Insp. Manoj Kumar)
* **Pseudonymized Welfare Roster**: Monitor unit welfare tiers and psychosocial vulnerability indices without exposing service numbers or names.
* **Family Assistance Pipeline**: Track outreach cases for families facing emergency financial, medical, or relocation hardships.
* **Scheme Entitlement Escalations**: Expedite central welfare grants, disability claims, and educational scholarship applications.

### E. Family Member Profile (Meera Singh — Spouse)
* **Morale Vault Delivery**: Write letters, record voice notes, and send photos to deployed spouses.
* **Family Support & Well-Being**: Access mental health resources, emergency hotlines, and welfare officer call requests.

### F. Profile-Specific 4-Digit PIN Security Gate
* **Dedicated Profile Lock**: Independent 4-digit PIN for each profile.
* **Instant PIN Prompt on Login**: Automatically gates dashboard access upon sign-in or switching profiles.
* **Unauthenticated Access**: Login screen is never locked, allowing easy profile selection.
* **Cold Start & Resume Protection**: Resuming the app from the background immediately prompts for the profile PIN.

---

## 3. Component Honesty Matrix

To maintain absolute technical transparency, the table below distinguishes between live backend integrations and simulated prototype layers:

| Component / Subsystem | Implementation Type | Live Backend Connection | In-Memory / Simulated Logic |
| :--- | :---: | :--- | :--- |
| **Authentication & RBAC** | **Real** | Supabase Auth API (`signInWithPassword`, sessions, tokens) | Demo profile shortcuts populate pre-seeded user records |
| **Database & Schema** | **Real** | 56 PostgreSQL tables on Supabase with Row Level Security (RLS) | Local repository caches for offline fallbacks |
| **Anonymous Reporting** | **Real** | Inserts & updates persist directly to Supabase `anonymous_reports` | Plaintext receipt tokens held in local memory for whistleblower |
| **Welfare Schemes RAG** | **Real** | Pinecone Vector DB (384-dim, `raksha-welfare` namespace) + FastAPI | Fallback keyword/stemming matcher when Python embedding service is offline |
| **Document Corpus** | **Real** | Chunked from official MHA, WARB, Ayushman CAPF, and PMSS PDFs | 60 extracted statutory chunks indexed with dense embeddings |
| **Commander Unit Metrics** | **Real** | Computed live via Supabase queries across `officers`, `duty_records`, `leave_records` | Fallback mock unit metrics if Supabase connection drops |
| **$k$-Anonymity Guard** | **Real** | Statutory suppression triggered when `officers.length < 10` | Hardcoded 6-person demo unit (`FORWARD-DET-SMALL`) for instant demonstration |
| **Biometric Telemetry** | **Simulated** | Historical biometrics stored in Supabase `biometrics` table | Synthetic sensor generator (no physical BLE wearable hardware attached) |
| **HRMS Enterprise Sync** | **Simulated** | Duty & leave records persist in Supabase `duty_records` & `leave_records` | Mock HRMS gateway (no physical connection to NIC SPARROW / IPMS intranet) |
| **Crisis & SOS Protocol** | **Real** | Direct routing to emergency dials (`tel:112`, `tel:14416`) | Zero-AI guarantee enforced at runtime |
| **App Lock & PIN** | **Real** | Persistent salted SHA-256 hashes via `flutter_secure_storage` | Default pre-set PINs for quick evaluation |

---

## 4. Tech Stack & Architecture

### Mobile Client (Flutter)
* **Framework**: Flutter 3.22+ / Dart 3.4+
* **State Management**: Provider with clean architectural MVVM pattern
* **Navigation**: GoRouter with authentication guards and redirection logic
* **Local Storage**: `flutter_secure_storage` (PINs, tokens) & `shared_preferences` (offline queue)
* **Security & Hardening**: `AppLockGate`, screen capture restriction hooks, RBAC guards
* **Localization**: English and Hindi (`en`, `hi`) localization support

### Backend & Cloud Services
* **Database & Auth**: Supabase PostgreSQL 17.6 with Row Level Security (RLS)
* **Vector Database**: Pinecone Serverless (384 dimensions, cosine metric)
* **Embedding Microservice**: Python FastAPI + NumPy vector projection (`scripts/embedding_service.py`)
* **Document Extraction**: PyMuPDF (`pymupdf`) for PDF parsing and semantic chunking

---

## 5. Prerequisites & Development Environment

Before cloning and running the repository, ensure your environment has:

1. **Flutter SDK**: `3.22.x` or higher (`flutter doctor` should report no issues).
2. **Dart SDK**: `3.4.x` or higher (bundled with Flutter).
3. **Android SDK**: Android Studio with Android SDK Command-line Tools and Platform Tools (API 26 to 36).
4. **Python**: Python `3.10+` with `pip`.
5. **Git**: Installed and configured.
6. **Physical Android Device or Emulator**: Developer Options & USB Debugging enabled.

---

## 6. Step-by-Step Installation & Running Guide

### Step 1: Clone the Repository
```bash
git clone https://github.com/av6-github/raksha-sih.git
cd raksha-sih
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Verify Code Quality & Analyzer
Ensure the workspace is in pristine condition:
```bash
flutter analyze
flutter test
```
*(All 271 unit and widget tests should pass with 0 analyzer errors).*

### Step 4: Configure Environment Variables
Verify that `.env` exists in the project root. If creating a fresh file:
```ini
SUPABASE_URL=https://jkayuhgxjkyffvvalsqt.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMzY2MTgsImV4cCI6MjEwNTkxMjYxOH0.RcXoEAX76CK4TKTqjgBSGZoQ6ZnHjXTKJKDv8s_b2ss
PINECONE_API_KEY=pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt
PINECONE_HOST=https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io
PINECONE_NAMESPACE=raksha-welfare
GROQ_MODEL=qwen/qwen3.8-27b
CLOUDINARY_CLOUD_NAME=deii0fu4y
```

### Step 5: Start the Local Vector Embedding Service
The Welfare Assistant uses a lightweight FastAPI service for 384-dimensional vector retrieval:
```bash
# In a separate terminal
pip install fastapi uvicorn numpy requests pymupdf supabase
python scripts/embedding_service.py
```
*The service will start listening on `http://127.0.0.1:8001`.*

### Step 6: Configure ADB Port Forwarding (For Physical Mobile Devices)
If testing on a physical Android phone connected via USB, bridge the phone's loopback to your development machine:
```powershell
# Windows PowerShell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8001 tcp:8001
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8080 tcp:8080
```
```bash
# macOS / Linux
adb reverse tcp:8001 tcp:8001
adb reverse tcp:8080 tcp:8080
```

### Step 7: Launch the Application
To run directly on your connected device or emulator:
```bash
flutter run
```
Or build a standalone debug APK:
```bash
flutter build apk --debug
# Install to device via ADB:
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 7. Demo Accounts & Profile PIN Cheat Sheet

The login screen provides one-tap **Quick Demo Sign-In** chips along with standard email/password authentication. 

All pre-seeded demo accounts share the password: **`RakshaSecure@2026`**.

### Role Credentials & Default PINs
| Role | Display Name | Email | Password | Default PIN | Master PIN |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **Officer 1** | Subedar Vikram Singh | `officer1@raksha.gov.in` | `RakshaSecure@2026` | **`1111`** | `2026` |
| **Officer 2** | HC Priya Nair | `officer2@raksha.gov.in` | `RakshaSecure@2026` | **`2222`** | `2026` |
| **Officer 3** (High Risk) | Insp. Arjun Thakur | `officer3@raksha.gov.in` | `RakshaSecure@2026` | **`3333`** | `2026` |
| **Commander** | Col. Rajesh Sharma | `commander@raksha.gov.in` | `RakshaSecure@2026` | **`4444`** | `2026` |
| **Counsellor** | Dr. Ananya Iyer | `counsellor@raksha.gov.in` | `RakshaSecure@2026` | **`5555`** | `2026` |
| **Welfare Officer** | Insp. Manoj Kumar | `welfare@raksha.gov.in` | `RakshaSecure@2026` | **`6666`** | `2026` |
| **Family Member** | Meera Singh (Spouse) | `family1@raksha.gov.in` | `RakshaSecure@2026` | **`7777`** | `2026` |

> [!TIP]
> **Universal Master PIN**: The PIN **`2026`** is accepted on all profiles for quick evaluation and testing.

---

## 8. Automated Verification & Test Suites

The repository contains 271 unit and widget tests covering all 22 delivery phases:

```bash
# Run the complete test suite
flutter test

# Run specific domain test suites
flutter test test/unit/app_lock_test.dart            # App Lock PIN state machine
flutter test test/unit/anonymous_reporting_test.dart # Zero-knowledge whistleblower token tests
flutter test test/unit/performance_acr_firewall_test.dart # Welfare-HR firewall validation
flutter test test/widget/phase9_widget_test.dart    # Role-based dashboard widgets & k-anonymity
```

### Key Test Categories
* **Privacy & Firewall Enforcement**: Verifies that clinical records, PHQ-9 items, and psychological stress markers cannot be queried by commander roles.
* **$k$-Anonymity Boundary Verification**: Asserts that aggregate metrics return suppressed payloads when tested on sample sizes $k < 10$.
* **Zero-AI Crisis Routing**: Confirms that emergency and suicide crisis pathways never invoke language models.
* **Offline Resilience**: Tests queuing mechanisms, encrypted offline storage, and seamless sync when re-establishing connectivity.

---

## 9. Project Directory Layout

```
raksha-sih/
├── docs/                                  # System Architecture, SRS, and Decision Logs
│   ├── ARCHITECTURE.md                    # Detailed architectural blueprints
│   ├── SRS.md                             # Software Requirements Specification
│   ├── LOGS.md                            # Verification and change log
│   └── corpus/welfare_schemes/            # Official CAPF welfare PDFs & chunk manifests
├── lib/
│   ├── core/                              # Core cross-cutting infrastructure
│   │   ├── config/                        # Environment and AppConfig providers
│   │   ├── localization/                  # Multilingual support (English / Hindi)
│   │   ├── routing/                       # GoRouter navigation definitions
│   │   └── security/                      # RBAC guards and secure storage
│   ├── features/                          # Domain feature modules
│   │   ├── analytics/                     # Baseline analytics & CUSUM alerts
│   │   ├── anonymous_reporting/           # Whistleblower reporting with token generation
│   │   ├── assessments/                   # PHQ-9 & GAD-7 psychometric screeners
│   │   ├── auth/                          # Authentication data and role models
│   │   ├── biometrics/                    # Wearable telemetry and baseline targets
│   │   ├── commander_dashboard/           # Unit readiness overview and roster actions
│   │   ├── counsellor_dashboard/          # Clinical caseload and safety plans
│   │   ├── crisis/                        # Zero-AI immediate crisis and SOS routing
│   │   ├── family/                        # Family morale vault & letters
│   │   ├── hrms/                          # Duty records, leave applications, friction metrics
│   │   ├── security/                      # Profile-specific 4-digit PIN lock gate
│   │   ├── welfare_dashboard/             # Pseudonymized welfare officer console
│   │   └── welfare_rag/                   # Semantic welfare benefit search copilot
│   └── main.dart                          # Application entrypoint & dependency injection
├── scripts/
│   ├── embedding_service.py               # Local 384-dim vector embedding microservice
│   ├── chunk_and_index_welfare_corpus.py  # PDF text extraction and Pinecone indexer
│   └── seed_database.py                   # Automated Supabase database & auth seeder
├── supabase/
│   └── migrations/                        # 7 PostgreSQL schema migrations with RLS policies
└── test/                                  # 271 unit, widget, and integration tests
```

---

## 10. Licensing & Compliance

Developed for the **Smart India Hackathon (SIH)**. Built in strict alignment with Ministry of Home Affairs (MHA) welfare guidelines, CAPF service conditions, and healthcare privacy best practices.
