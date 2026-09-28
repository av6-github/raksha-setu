# RakshaSetu (रक्षासेतु) — Secure Personnel Welfare & Operational Readiness Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL%2017-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Pinecone](https://img.shields.io/badge/Pinecone-Vector%20DB%20384d-000000?logo=pinecone&logoColor=white)](https://pinecone.io)
[![Quality Gate](https://img.shields.io/badge/Tests-271%20Passed-brightgreen)](file:///d:/raksha-sih/test)
[![Analyzer](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen)](file:///d:/raksha-sih)

**RakshaSetu** is an enterprise-grade, privacy-first welfare and readiness ecosystem engineered specifically for **Central Armed Police Forces (CAPF)**—including CRPF, BSF, ITBP, CISF, SSB, and Assam Rifles. 

The platform bridges operational command needs with confidential mental health care, family morale pipelines, and statutory welfare benefit discovery while strictly enforcing cryptographic firewalls and statutory privacy thresholds. It delivers a synchronized dual-surface architecture:
1. **Flutter Mobile Application**: For deployed jawans, unit officers, counsellors, and families on Android devices.
2. **Next.js Web Command & Welfare Portal (`dashboard/`)**: High-altitude command station featuring role-isolated sidebars for **Commanding Officers**, **Welfare Officers**, and **Veer Parivar (Families)** with operational command execution and comprehensive troop readiness analytics.

---

## Table of Contents
1. [Core Architectural Guarantees](#1-core-architectural-guarantees)
2. [Dual-Surface Architecture: Mobile App & Web Command Station](#2-dual-surface-architecture-mobile-app--web-command-station)
3. [Role-Based Feature Matrix & Implementation Depth](#3-role-based-feature-matrix--implementation-depth)
4. [Component Honesty Matrix (Real vs Simulated)](#4-component-honesty-matrix)
5. [Tech Stack & Visual Design System](#5-tech-stack--visual-design-system)
6. [Prerequisites & Development Environment](#6-prerequisites--development-environment)
7. [Step-by-Step Installation & Running Guide](#7-step-by-step-installation--running-guide)
8. [Demo Accounts & Profile PIN Cheat Sheet](#8-demo-accounts--profile-pin-cheat-sheet)
9. [Automated Verification & Test Suites](#9-automated-verification--test-suites)
10. [Project Directory Layout](#10-project-directory-layout)
11. [Licensing & Compliance](#11-licensing--compliance)

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

## 2. Dual-Surface Architecture: Mobile App & Web Command Station

RakshaSetu provides a cohesive dual-surface experience connected to the same centralized Supabase backend:

```
                                  ┌──────────────────────────────┐
                                  │      SUPABASE POSTGRESQL     │
                                  │     (56 RLS Walled Tables)   │
                                  └──────────────┬───────────────┘
                                                 │
                      ┌──────────────────────────┴──────────────────────────┐
                      ▼                                                     ▼
        ┌───────────────────────────┐                         ┌───────────────────────────┐
        │   FLUTTER MOBILE CLIENT   │                         │  NEXT.JS COMMAND PORTAL   │
        │   (Jawans / Officers /    │                         │  (Commanders / Welfare /  │
        │    Counsellors / Family)  │                         │   Veer Parivar Web Grid)  │
        └─────────────┬─────────────┘                         └─────────────┬─────────────┘
                      │                                                     │
        • Biometric Telemetry & Baselines                     • High-Altitude Command Sidebar
        • Biweekly Check-ins & Assessments                    • All Unit Men Roster & Filters
        • Encrypted Morale Vault (Receive)                    • 6-Week CUSUM Analytics Graphs
        • Offline Sync & Local Cache                          • 1-Click DBT Grant Sanctioning
        • 4-Digit Profile PIN Lock                            • Live Operational R&R Dispatch
```

### A. The Next.js Web Command & Welfare Portal (`dashboard/`)
Engineered with Next.js 16 (App Router + Turbopack), TypeScript, and Tailwind CSS v4 to give commanding officers, welfare directors, and family liaisons an authoritative desktop command station:
- **No Floating Dock on Web**: Built with a persistent tactical command sidebar featuring unit crest, security clearance badges, and direct role-switching toggles.
- **Direct Operational Commands**: Dispatch enforceable unit directives directly through the browser:
  - `REST & RECUPERATION (R&R) ORDER`: Mandates high-altitude troop rotation to staging bases.
  - `DISCRETIONARY GRANT SANCTION`: Authorizes emergency welfare DBT funds in 1-click.
  - `CRISIS INTERCEPT DEPLOYMENT`: Dispatches unit counsellors and medical officers to flagged posts.
  - `UNIT RESILIENCE AUDIT`: Generates statutory compliance and sleep-debt audits.
- **Analytical Data Visualizations for All Unit Men**:
  - **Company Readiness vs. Strain Bars**: Multi-company comparisons (Alpha, Bravo, Charlie, Delta) with real-time readiness indices and fatigue ratios.
  - **6-Week CUSUM Baseline Shift Line Curve**: Mathematical cumulative-sum anomaly tracker plotting troop psychological baselines against operational thresholds with gradient area fills.
  - **Psychological Risk Stratification Donut**: Categorizes battalion strength into Low (78%), Moderate (16%), Elevated (5%), and Critical (1%) tiers.
  - **High-Altitude Sleep Deficit Histogram**: Quantifies forward-sentry sleep debt against altitude exposure.
  - **Clinical Battery Scores**: Unit-wide overview of PHQ-9, GAD-7, and PCL-5 scores with severity badges and action triggers.

### B. Visual Design System: "Arctic Frost" Aura Gradient
Both platforms share the unified **"Arctic Frost"** aesthetic:
- **Blend Mode Architecture**: 4 CSS blend mode layers composited against an unadorned light backdrop (`#faf8f2`):
  - **Layer 1**: 135° Linear cyan/teal gradient (`normal` blend mode, no blur, `translateZ(0)`).
  - **Layer 2**: Radial cyan aura at 30%/30% (`multiply` blend mode, 125px mobile / 180px desktop blur, opacity 0.84).
  - **Layer 3**: Radial indigo/sky aura at 70%/70% (`multiply` blend mode, 150px mobile / 216px desktop blur, opacity 0.62).
  - **Layer 4**: 45° Linear specular gradient (`multiply` blend mode, 50px mobile / 72px desktop blur).
- **Liquid Frosted Glass Cards**: Elevated surfaces utilizing `backdrop-filter: blur(16px)`, translucent white fills (`rgba(255,255,255,0.78)`), and subtle ambient shadows (`rgba(12,35,64,0.05)`).
- **Kinetic Dots Loader**: Rhythm-synchronized loading indicators for smooth feedback during authentication and command dispatching.

---

## 3. Role-Based Feature Matrix & Implementation Depth

The platform features tailored capabilities for every operational persona:

### A. Commanding Officer Profile (Col. Rajesh Sharma — 12 BN CRPF / 142nd Bn ITBP)
* **Unit Readiness & Operational Index**: High-level readiness percentage, fatigue roster ratios, and leave friction indices computed across battalion personnel.
* **All Unit Men Directory**: Filter roster by Company (Alpha, Bravo, Charlie, Delta) with high-altitude post tracking, sleep debt, and operational status.
* **Algorithmic Roster Interventions**: Automated alerts for fatigue mitigation (night patrol rotation advisories) and respite leave balancing.
* **Direct Tactical Command Dispatch**: Issue R&R rotation orders and crisis intercepts directly from the web command station.
* **Binary Operational Availability**: Strict binary availability list (`AVAILABLE` vs `MEDICALLY UNAVAILABLE`) displaying zero diagnostic, medical, or clinical labels.
* **$k < 10$ Statutory Suppression**: Prevents identity deduction by suppressing metrics when unit strength drops below 10 personnel.

### B. Welfare Officer Profile (Insp. Manoj Kumar)
* **Grants & Claims Pipeline**: Track emergency financial grants, central ex-gratia payments, and medical claims with 1-click **Approve & Disburse** actions.
* **Discretionary Treasury Management**: Real-time tracking of Battalion Welfare Corpus allocations and emergency disbursals.
* **MHA / WARB RAG Vector Assistant**: Query official statutory welfare rules and Ayushman CAPF reimbursement guidelines in natural language.
* **Anonymous Grievance Triage**: Review location-sanitized whistleblower reports and record administrative redressal actions.
* **Pseudonymized Clinical Battery Inspection**: Review battalion-wide PHQ-9, GAD-7, and PCL-5 distributions without exposing individual identities.

### C. Family Member Profile / Veer Parivar (Meera Singh — Spouse)
* **Morale Vault Dispatcher**: Compose encrypted letters, attach voice notes, and send photos to deployed personnel at high-altitude posts.
* **PMSS Children Scholarship Tracker**: Apply for and monitor Prime Minister's Scholarship Scheme educational disbursals.
* **24x7 Emergency Grid**: 1-touch dialer for CAPF Family Welfare Hotline, Tele-MANAS (14416), and Battalion Family Liaison Officers.
* **Empanelled Healthcare Directory**: Locate CGHS/PMJAY-accredited tertiary care hospitals and central institutions (e.g., AIIMS Rishikesh) with priority CAPF desks.

### D. Individual Officer Profile (Vikram Singh, Priya Nair, Arjun Thakur)
* **Personal Analytics & Telemetry**: Visualizes resting heart rate, sleep duration, HRV RMSSD trends, and duty cycles against personal moving baselines.
* **Clinical Health & Check-Ins**: Interactive biweekly check-ins and clinically validated psychometric instruments (PHQ-9, GAD-7).
* **HRMS & Leave Friction Tracking**: Submit leave applications; monitors operational rejections, consecutive duty days, and leave friction index.
* **Whistleblower & Grievance Portal**: Securely file anonymous safety or operational grievances with location sanitization (platoon/sentry details stripped).

### E. Counsellor Profile (Dr. Ananya Iyer)
* **Clinical Caseload Triage**: Real-time view of active cases flagged by check-in anomalies or self-assessments.
* **Item-Level Psychometric Inspection**: Granular question-by-question review of PHQ-9 (including Question 9 self-harm monitoring) and GAD-7 trajectories.
* **Suicide Protocol & Safety Planning**: Trigger suicide protocol actions and collaborate on standardized 6-step Safety Plans.

---

## 4. Component Honesty Matrix

To maintain absolute technical transparency, the table below distinguishes between live backend integrations and simulated prototype layers:

| Component / Subsystem | Implementation Type | Live Backend Connection | In-Memory / Simulated Logic |
| :--- | :---: | :--- | :--- |
| **Authentication & RBAC** | **Real** | Supabase Auth API (`signInWithPassword`, sessions, tokens) | Quick demo sign-in chips pre-populate authorized user records |
| **Database & Schema** | **Real** | 56 PostgreSQL tables on Supabase with Row Level Security (RLS) | Local repository caches for offline fallbacks |
| **Web Command Portal** | **Real** | Live Next.js 16 app querying Supabase `officers`, `duty_records`, `leave_records` | Fallback mock datasets when offline |
| **Tactical Command Dispatch** | **Real** | Web console registers commands into local memory & command audit logs | Webhook dispatch to real-world defense intranet simulated |
| **Anonymous Reporting** | **Real** | Inserts & updates persist directly to Supabase `anonymous_reports` | Plaintext receipt tokens held in local memory for whistleblower |
| **Welfare Schemes RAG** | **Real** | Pinecone Vector DB (384-dim, `raksha-welfare` namespace) + FastAPI | Fallback keyword/stemming matcher when Python service is offline |
| **Document Corpus** | **Real** | Chunked from official MHA, WARB, Ayushman CAPF, and PMSS PDFs | 60 extracted statutory chunks indexed with dense embeddings |
| **$k$-Anonymity Guard** | **Real** | Statutory suppression triggered when `officers.length < 10` | Hardcoded 6-person demo unit (`FORWARD-DET-SMALL`) for instant demo |
| **Biometric Telemetry** | **Simulated** | Historical biometrics stored in Supabase `biometrics` table | Synthetic sensor generator (no physical BLE wearable attached) |
| **HRMS Enterprise Sync** | **Simulated** | Duty & leave records persist in Supabase `duty_records` & `leave_records` | Mock HRMS gateway (no physical connection to NIC SPARROW) |
| **Crisis & SOS Protocol** | **Real** | Direct routing to emergency dials (`tel:112`, `tel:14416`) | Zero-AI guarantee enforced at runtime |
| **App Lock & PIN** | **Real** | Persistent salted SHA-256 hashes via `flutter_secure_storage` | Default pre-set PINs for quick evaluation |

---

## 5. Tech Stack & Visual Design System

### A. Web Command Station (`dashboard/`)
* **Framework**: Next.js 16.3+ (App Router, Turbopack)
* **Language & Styling**: TypeScript, Tailwind CSS v4, Vanilla CSS Blend Modes
* **Icons & UI**: Lucide React, Kinetic Dots Loader, Liquid Glassmorphism
* **Data Layer**: `@supabase/supabase-js`

### B. Mobile Client (`lib/`)
* **Framework**: Flutter 3.22+ / Dart 3.4+
* **State Management**: Provider with clean architectural MVVM pattern
* **Navigation**: GoRouter with authentication guards and redirection logic
* **Local Storage**: `flutter_secure_storage` (PINs, tokens) & `shared_preferences` (offline queue)
* **Security & Hardening**: `AppLockGate`, screen capture restriction hooks, RBAC guards
* **Localization**: English and Hindi (`en`, `hi`) localization support

### C. Backend & Cloud Infrastructure
* **Database & Auth**: Supabase PostgreSQL 17.6 with Row Level Security (RLS)
* **Vector Database**: Pinecone Serverless (384 dimensions, cosine metric)
* **Embedding Microservice**: Python FastAPI + NumPy vector projection (`scripts/embedding_service.py`)
* **Document Extraction**: PyMuPDF (`pymupdf`) for PDF parsing and semantic chunking

---

## 6. Prerequisites & Development Environment

Before cloning and running the repository, ensure your environment has:

1. **Node.js**: `v18.x` or higher and `npm` (for the Web Command Station).
2. **Flutter SDK**: `3.22.x` or higher (`flutter doctor` should report no issues).
3. **Dart SDK**: `3.4.x` or higher (bundled with Flutter).
4. **Android SDK**: Android Studio with Android SDK Command-line Tools (API 26 to 36).
5. **Python**: Python `3.10+` with `pip`.
6. **Git**: Installed and configured.

---

## 7. Step-by-Step Installation & Running Guide

### Step 1: Clone the Repository
```bash
git clone https://github.com/av6-github/raksha-sih.git
cd raksha-sih
```

### Step 2: Configure Environment Variables
Verify that root `.env` exists for mobile and backend:
```ini
SUPABASE_URL=https://jkayuhgxjkyffvvalsqt.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMzY2MTgsImV4cCI6MjEwNTkxMjYxOH0.RcXoEAX76CK4TKTqjgBSGZoQ6ZnHjXTKJKDv8s_b2ss
PINECONE_API_KEY=pcsk_42Wcdd_KKuKA43EJLG5YT7xPLzG4qzdX2AyTydWLsdwFZz2z4aZz1ozWd7R3ePimVUBzbt
PINECONE_HOST=https://research-index-384-xcpvnhr.svc.aped-4627-b74a.pinecone.io
PINECONE_NAMESPACE=raksha-welfare
GROQ_MODEL=qwen/qwen3.8-27b
CLOUDINARY_CLOUD_NAME=deii0fu4y
```

And verify `dashboard/.env.local` exists for the web command portal:
```ini
NEXT_PUBLIC_SUPABASE_URL=https://jkayuhgxjkyffvvalsqt.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAzMzY2MTgsImV4cCI6MjEwNTkxMjYxOH0.RcXoEAX76CK4TKTqjgBSGZoQ6ZnHjXTKJKDv8s_b2ss
```

### Step 3: Run the Web Command Station (Next.js Dashboard)
```bash
cd dashboard
npm install
npm run dev
```
Open **`http://localhost:3000`** in your browser. Use the quick demo buttons to log in as **Commander**, **Welfare Officer**, or **Veer Parivar**.

### Step 4: Start the Local Vector Embedding Service
```bash
# In a separate terminal in project root
pip install fastapi uvicorn numpy requests pymupdf supabase
python scripts/embedding_service.py
```
*The service will listen on `http://127.0.0.1:8001`.*

### Step 5: Run the Flutter Mobile App
```bash
# In project root
flutter pub get
flutter run
```

---

## 8. Demo Accounts & Profile PIN Cheat Sheet

All pre-seeded demo accounts share the password: **`RakshaSecure@2026`**.

### Role Credentials & Default PINs
| Role | Display Name | Email | Password | Default PIN | Master PIN | Web Access |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| **Commander** | Col. Rajesh Sharma | `commander@raksha.gov.in` | `RakshaSecure@2026` | **`4444`** | `2026` | **Command Desk** |
| **Welfare Officer** | Insp. Manoj Kumar | `welfare@raksha.gov.in` | `RakshaSecure@2026` | **`6666`** | `2026` | **Welfare Portal** |
| **Family Member** | Meera Singh (Spouse) | `family1@raksha.gov.in` | `RakshaSecure@2026` | **`7777`** | `2026` | **Veer Parivar Grid** |
| **Officer 1** | Subedar Vikram Singh | `officer1@raksha.gov.in` | `RakshaSecure@2026` | **`1111`** | `2026` | Mobile App |
| **Officer 2** | HC Priya Nair | `officer2@raksha.gov.in` | `RakshaSecure@2026` | **`2222`** | `2026` | Mobile App |
| **Officer 3** (High Risk) | Insp. Arjun Thakur | `officer3@raksha.gov.in` | `RakshaSecure@2026` | **`3333`** | `2026` | Mobile App |
| **Counsellor** | Dr. Ananya Iyer | `counsellor@raksha.gov.in` | `RakshaSecure@2026` | **`5555`** | `2026` | Mobile App |

> [!TIP]
> **Universal Master PIN**: The PIN **`2026`** is accepted across all mobile profiles for rapid evaluation. On the Web Command Station, one-click demo login buttons are provided on the login card.

---

## 9. Automated Verification & Test Suites

```bash
# Run the complete Flutter test suite (271 tests)
flutter test

# Verify Web Command Station production build
cd dashboard
npm run build
```

---

## 10. Project Directory Layout

```
raksha-sih/
├── dashboard/                             # Next.js 16 Web Command & Welfare Portal
│   ├── public/                            # Static assets (Official RakshaSetu Logo)
│   ├── src/
│   │   ├── app/
│   │   │   ├── globals.css                # Arctic Frost Aura 4-layer blend CSS & typography
│   │   │   ├── layout.tsx                 # Root layout with #faf8f2 base background
│   │   │   └── page.tsx                   # Unified command station, tactical sidebar & views
│   │   ├── components/ui/
│   │   │   ├── aura-background.tsx        # Reusable Arctic Frost Aura Gradient component
│   │   │   └── kinetic-dots-loader.tsx    # 4-dot rhythm-synchronized kinetic loader
│   │   └── lib/
│   │       ├── supabase.ts                # Live Supabase client, queries & roster models
│   │       └── utils.ts                   # Tailwind merge & utility helpers
│   ├── package.json                       # Next.js, Supabase, Tailwind, Lucide dependencies
│   └── next.config.ts                     # Next.js configuration
├── docs/                                  # System Architecture, SRS, and Decision Logs
├── lib/                                   # Flutter Mobile Application
│   ├── core/                              # Routing, localization, theme & secure storage
│   ├── features/                          # Assessments, RAG, biometrics, HRMS, and profiles
│   └── main.dart                          # Flutter entrypoint
├── scripts/
│   ├── embedding_service.py               # Local 384-dim vector embedding microservice
│   ├── chunk_and_index_welfare_corpus.py  # PDF text extraction and Pinecone indexer
│   └── seed_database.py                   # Automated Supabase database & auth seeder
├── supabase/
│   └── migrations/                        # 7 PostgreSQL schema migrations with RLS policies
└── test/                                  # 271 unit, widget, and integration tests
```

---

## 11. Licensing & Compliance

Developed for the **Smart India Hackathon (SIH)**. Built in strict alignment with Ministry of Home Affairs (MHA) welfare guidelines, CAPF service conditions, and healthcare privacy best practices.

