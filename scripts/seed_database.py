#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
seed_database.py — Comprehensive seeding script for Raksha-SIH Supabase project.

Execution order respects FK dependencies:
  auth.users → roles → units → identities → officers →
  leave_records → duty_records → check_ins → assessments →
  assessment_responses → biometrics → consent_records →
  risk_scores → interventions → family_members → team_sessions →
  bulletin_events → recognitions → counselling_sessions (counsellor_cases)
"""

import uuid
import requests
import json
from datetime import datetime, date, timedelta, timezone
from supabase import create_client, Client

# ─── CONFIG ──────────────────────────────────────────────────────────────────
SUPABASE_URL = "https://jkayuhgxjkyffvvalsqt.supabase.co"
SERVICE_ROLE_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprYXl1aGd4amt5ZmZ2dmFsc3F0Iiwicm9sZSI6"
    "InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDMzNjYxOCwiZXhwIjoyMTA1OTEyNjE4fQ."
    "dqjnBLXee05nP-pVrr10-4awOkGsfkwEniOAGJW6DUo"
)
AUTH_ADMIN_URL = f"{SUPABASE_URL}/auth/v1/admin/users"
HEADERS = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
}

supabase: Client = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

# ─── TRACKING ────────────────────────────────────────────────────────────────
seeded_counts: dict = {}
skipped_tables: list = []
errors: list = []

TODAY = date.today()
NOW = datetime.now(timezone.utc)


def ts(d: date) -> str:
    """Convert date to ISO timestamp string."""
    return datetime.combine(d, datetime.min.time()).replace(tzinfo=timezone.utc).isoformat()


def safe_insert(table: str, data: list | dict, label: str = "") -> list:
    """Insert data into table, handling errors gracefully. Returns inserted rows."""
    if isinstance(data, dict):
        data = [data]
    if not data:
        return []
    try:
        res = supabase.table(table).insert(data).execute()
        count = len(res.data) if res.data else len(data)
        seeded_counts[table] = seeded_counts.get(table, 0) + count
        tag = f" ({label})" if label else ""
        print(f"  ✅ {table}{tag}: inserted {count} row(s)")
        return res.data or []
    except Exception as e:
        err_str = str(e)
        if "relation" in err_str and "does not exist" in err_str:
            if table not in skipped_tables:
                skipped_tables.append(table)
            print(f"  ⚠️  {table}: TABLE DOES NOT EXIST — skipping")
        else:
            errors.append(f"{table}: {err_str[:200]}")
            print(f"  ❌ {table}: {err_str[:200]}")
        return []


# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1 — CREATE AUTH USERS
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 1: Creating Auth Users")
print("═" * 70)

auth_users_spec = [
    {"email": "officer1@raksha.gov.in",  "role": "officer"},
    {"email": "officer2@raksha.gov.in",  "role": "officer"},
    {"email": "officer3@raksha.gov.in",  "role": "officer"},
    {"email": "commander@raksha.gov.in", "role": "commander"},
    {"email": "counsellor@raksha.gov.in","role": "counsellor"},
    {"email": "welfare@raksha.gov.in",   "role": "welfare_officer"},
    {"email": "family1@raksha.gov.in",   "role": "family"},
    {"email": "family2@raksha.gov.in",   "role": "family"},
]
PASSWORD = "RakshaSecure@2026"

auth_user_ids: dict = {}   # email → auth_user_id (UUID str)

for spec in auth_users_spec:
    email = spec["email"]
    payload = {
        "email": email,
        "password": PASSWORD,
        "email_confirm": True,
        "user_metadata": {"app_role": spec["role"]},
    }
    resp = requests.post(AUTH_ADMIN_URL, headers=HEADERS, json=payload)
    if resp.status_code in (200, 201):
        user_data = resp.json()
        uid = user_data.get("id")
        auth_user_ids[email] = uid
        print(f"  ✅ Created: {email}  → {uid}")
    elif resp.status_code == 422 and "already" in resp.text.lower():
        # User already exists — fetch their ID
        list_resp = requests.get(AUTH_ADMIN_URL, headers=HEADERS)
        if list_resp.status_code == 200:
            all_users = list_resp.json().get("users", [])
            existing = next((u for u in all_users if u.get("email") == email), None)
            if existing:
                uid = existing["id"]
                auth_user_ids[email] = uid
                print(f"  ♻️  Already exists: {email} → {uid}")
            else:
                print(f"  ❌ Could not find existing user: {email}")
        else:
            print(f"  ❌ Failed to list users: {list_resp.text[:100]}")
    else:
        print(f"  ❌ Failed to create {email}: {resp.status_code} {resp.text[:150]}")

print(f"\n  Auth user IDs map: {json.dumps(auth_user_ids, indent=2)}")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2 — ROLES TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 2: Seeding roles")
print("═" * 70)

role_names = ["officer", "commander", "counsellor", "welfare_officer", "family", "admin"]
role_ids: dict = {}  # name → UUID str

for rname in role_names:
    rid = str(uuid.uuid4())
    role_ids[rname] = rid

roles_data = [
    {"id": role_ids["officer"],        "name": "officer",        "description": "Field officer / constable"},
    {"id": role_ids["commander"],      "name": "commander",      "description": "Unit commander with operational oversight"},
    {"id": role_ids["counsellor"],     "name": "counsellor",     "description": "Clinical counsellor / psychologist"},
    {"id": role_ids["welfare_officer"],"name": "welfare_officer","description": "Welfare officer managing HR & welfare schemes"},
    {"id": role_ids["family"],         "name": "family",         "description": "Enrolled family member"},
    {"id": role_ids["admin"],          "name": "admin",          "description": "System administrator"},
]
safe_insert("roles", roles_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3 — UNITS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 3: Seeding units")
print("═" * 70)

unit_hq_id  = str(uuid.uuid4())
unit_12bn_id = str(uuid.uuid4())
unit_45bn_id = str(uuid.uuid4())

units_data = [
    {
        "id": unit_hq_id,
        "name": "HQ CRPF Delhi",
        "location": "New Delhi",
        "is_high_hardship": False,
    },
    {
        "id": unit_12bn_id,
        "name": "12 Battalion CRPF (Charlie Company)",
        "parent_unit_id": unit_hq_id,
        "location": "Rajasthan",
        "is_high_hardship": True,
    },
    {
        "id": unit_45bn_id,
        "name": "45 Battalion BSF (Alpha Company)",
        "parent_unit_id": unit_hq_id,
        "location": "Punjab",
        "is_high_hardship": True,
    },
]
safe_insert("units", units_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4 — IDENTITIES TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 4: Seeding identities")
print("═" * 70)

identity_ids: dict = {}  # email → identity UUID str

email_role_map = {
    "officer1@raksha.gov.in":   "officer",
    "officer2@raksha.gov.in":   "officer",
    "officer3@raksha.gov.in":   "officer",
    "commander@raksha.gov.in":  "commander",
    "counsellor@raksha.gov.in": "counsellor",
    "welfare@raksha.gov.in":    "welfare_officer",
    "family1@raksha.gov.in":    "family",
    "family2@raksha.gov.in":    "family",
}

identities_data = []
for email, role_name in email_role_map.items():
    auth_uid = auth_user_ids.get(email)
    if not auth_uid:
        print(f"  ⚠️  No auth UID for {email} — skipping identity")
        continue
    iid = str(uuid.uuid4())
    identity_ids[email] = iid
    identities_data.append({
        "id": iid,
        "auth_user_id": auth_uid,
        "role_id": role_ids[role_name],
        "email": email,
        "status": "active",
    })

safe_insert("identities", identities_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5 — OFFICERS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 5: Seeding officers")
print("═" * 70)

officer1_id = str(uuid.uuid4())
officer2_id = str(uuid.uuid4())
officer3_id = str(uuid.uuid4())

officers_data = [
    {
        "id": officer1_id,
        "identity_id": identity_ids.get("officer1@raksha.gov.in"),
        "unit_id": unit_12bn_id,
        "service_number": "CRPF-2026-7788",
        "first_name": "Vikram",
        "last_name": "Singh",
        "designation": "Subedar",
        "date_of_joining": "2019-06-15",
        "blood_group": "O+",
        "gender": "male",
        "is_available": True,
        "limited_duty": False,
        "welfare_supported": False,
    },
    {
        "id": officer2_id,
        "identity_id": identity_ids.get("officer2@raksha.gov.in"),
        "unit_id": unit_12bn_id,
        "service_number": "CRPF-2022-4421",
        "first_name": "Priya",
        "last_name": "Nair",
        "designation": "Head Constable",
        "date_of_joining": "2022-03-10",
        "blood_group": "A+",
        "gender": "female",
        "is_available": True,
        "limited_duty": False,
        "welfare_supported": False,
    },
    {
        "id": officer3_id,
        "identity_id": identity_ids.get("officer3@raksha.gov.in"),
        "unit_id": unit_45bn_id,
        "service_number": "BSF-2018-9932",
        "first_name": "Arjun",
        "last_name": "Thakur",
        "designation": "Inspector",
        "date_of_joining": "2018-08-20",
        "blood_group": "B+",
        "gender": "male",
        "is_available": True,
        "limited_duty": True,
        "welfare_supported": True,
    },
]
safe_insert("officers", officers_data)

officer_ids = {
    "officer1@raksha.gov.in": officer1_id,
    "officer2@raksha.gov.in": officer2_id,
    "officer3@raksha.gov.in": officer3_id,
}
print(f"\n  Officer UUIDs:")
for email, oid in officer_ids.items():
    print(f"    {email} → {oid}")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6 — LEAVE_RECORDS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 6: Seeding leave_records")
print("═" * 70)

leave_records = []

# Officer 1 — Vikram Singh
leave_records += [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "leave_type": "earned",
        "start_date": "2026-08-01",
        "end_date": "2026-08-10",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "leave_type": "casual",
        "start_date": "2026-09-05",
        "end_date": "2026-09-07",
        "status": "applied",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "leave_type": "earned",
        "start_date": "2026-07-14",
        "end_date": "2026-07-20",
        "status": "rejected",
        "rejection_reason": "Operational exigency — border deployment",
        "is_operational_rejection": True,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "leave_type": "medical",
        "start_date": "2026-06-01",
        "end_date": "2026-06-05",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
]

# Officer 2 — Priya Nair
leave_records += [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "leave_type": "casual",
        "start_date": "2026-08-15",
        "end_date": "2026-08-17",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "leave_type": "earned",
        "start_date": "2026-07-01",
        "end_date": "2026-07-12",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "leave_type": "earned",
        "start_date": "2026-09-20",
        "end_date": "2026-09-25",
        "status": "rejected",
        "rejection_reason": "Unit on high alert — operational requirement",
        "is_operational_rejection": True,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "leave_type": "maternity",
        "start_date": "2026-05-01",
        "end_date": "2026-06-30",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "leave_type": "casual",
        "start_date": "2026-09-10",
        "end_date": "2026-09-12",
        "status": "applied",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
]

# Officer 3 — Arjun Thakur
leave_records += [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "leave_type": "earned",
        "start_date": "2026-06-10",
        "end_date": "2026-06-20",
        "status": "rejected",
        "rejection_reason": "Active field operation — cannot be relieved",
        "is_operational_rejection": True,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "leave_type": "casual",
        "start_date": "2026-08-25",
        "end_date": "2026-08-27",
        "status": "rejected",
        "rejection_reason": "Manpower shortage in unit",
        "is_operational_rejection": True,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "leave_type": "medical",
        "start_date": "2026-09-01",
        "end_date": "2026-09-07",
        "status": "approved",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "leave_type": "earned",
        "start_date": "2026-09-26",
        "end_date": "2026-10-05",
        "status": "applied",
        "rejection_reason": None,
        "is_operational_rejection": False,
    },
]

safe_insert("leave_records", leave_records)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7 — DUTY_RECORDS TABLE (14 days each)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 7: Seeding duty_records")
print("═" * 70)

import random
random.seed(42)

duty_records = []
hours_map = {
    officer1_id: (9.0, 10.0),
    officer2_id: (9.0, 9.5),
    officer3_id: (9.5, 10.5),
}

for oid, (low, high) in hours_map.items():
    for i in range(14):
        d = TODAY - timedelta(days=i+1)
        duty_records.append({
            "id": str(uuid.uuid4()),
            "officer_id": oid,
            "duty_date": d.isoformat(),
            "hours_worked": round(random.uniform(low, high), 1),
            "is_overtime": random.random() < 0.3,
        })

safe_insert("duty_records", duty_records)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 8 — CHECK_INS TABLE (biweekly × 4 = 8 weeks back)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 8: Seeding check_ins")
print("═" * 70)

check_in_profiles = {
    officer1_id: {"phq2": (1, 2), "gad2": (0, 1), "sleep": (3, 4), "workload": (3, 4)},
    officer2_id: {"phq2": (0, 1), "gad2": (0, 0), "sleep": (4, 5), "workload": (2, 3)},
    officer3_id: {"phq2": (3, 5), "gad2": (2, 4), "sleep": (1, 3), "workload": (4, 5)},
}

check_ins = []
for oid, profile in check_in_profiles.items():
    for i in range(4):
        # Biweekly = every 14 days, going back from today
        weeks_back = (i + 1) * 2
        dt = NOW - timedelta(weeks=weeks_back)
        check_ins.append({
            "id": str(uuid.uuid4()),
            "officer_id": oid,
            "check_in_date": dt.isoformat(),
            "phq2_score": random.randint(*profile["phq2"]),
            "gad2_score": random.randint(*profile["gad2"]),
            "sleep_quality_score": random.randint(*profile["sleep"]),
            "workload_score": random.randint(*profile["workload"]),
            "is_offline_submission": False,
        })

safe_insert("check_ins", check_ins)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 9 — ASSESSMENTS TABLE (PHQ-9 + GAD-7 per officer)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 9: Seeding assessments")
print("═" * 70)

# Pre-generate assessment IDs for later use in assessment_responses
asmt_ids: dict = {}  # "officer_email_type" → assessment_id

phq9_assessments = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "assessment_type": "phq9",
        "trigger_reason": "quarterly_routine",
        "total_score": 8.0,
        "severity_tier": "mild",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=30)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "assessment_type": "phq9",
        "trigger_reason": "quarterly_routine",
        "total_score": 3.0,
        "severity_tier": "normal",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=28)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "assessment_type": "phq9",
        "trigger_reason": "elevated_risk_trigger",
        "total_score": 14.0,
        "severity_tier": "moderate",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=7)).isoformat(),
    },
]

gad7_assessments = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "assessment_type": "gad7",
        "trigger_reason": "quarterly_routine",
        "total_score": 6.0,
        "severity_tier": "mild",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=30)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "assessment_type": "gad7",
        "trigger_reason": "quarterly_routine",
        "total_score": 2.0,
        "severity_tier": "normal",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=28)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "assessment_type": "gad7",
        "trigger_reason": "elevated_risk_trigger",
        "total_score": 11.0,
        "severity_tier": "moderate",
        "phq9_item9_score": 0,
        "is_crisis_flagged": False,
        "completed_at": (NOW - timedelta(days=7)).isoformat(),
    },
]

all_assessments = phq9_assessments + gad7_assessments
safe_insert("assessments", all_assessments)

# Map for later use
asmt_ids["o1_phq9"] = phq9_assessments[0]["id"]
asmt_ids["o2_phq9"] = phq9_assessments[1]["id"]
asmt_ids["o3_phq9"] = phq9_assessments[2]["id"]
asmt_ids["o1_gad7"] = gad7_assessments[0]["id"]
asmt_ids["o2_gad7"] = gad7_assessments[1]["id"]
asmt_ids["o3_gad7"] = gad7_assessments[2]["id"]

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 10 — ASSESSMENT_RESPONSES TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 10: Seeding assessment_responses")
print("═" * 70)

PHQ9_QUESTIONS = [
    ("PHQ9_Q1", "Little interest or pleasure in doing things"),
    ("PHQ9_Q2", "Feeling down, depressed, or hopeless"),
    ("PHQ9_Q3", "Trouble falling or staying asleep, or sleeping too much"),
    ("PHQ9_Q4", "Feeling tired or having little energy"),
    ("PHQ9_Q5", "Poor appetite or overeating"),
    ("PHQ9_Q6", "Feeling bad about yourself"),
    ("PHQ9_Q7", "Trouble concentrating on things"),
    ("PHQ9_Q8", "Moving or speaking so slowly that others noticed"),
    ("PHQ9_Q9", "Thoughts that you would be better off dead"),
]

GAD7_QUESTIONS = [
    ("GAD7_Q1", "Feeling nervous, anxious, or on edge"),
    ("GAD7_Q2", "Not being able to stop or control worrying"),
    ("GAD7_Q3", "Worrying too much about different things"),
    ("GAD7_Q4", "Trouble relaxing"),
    ("GAD7_Q5", "Being so restless that it is hard to sit still"),
    ("GAD7_Q6", "Becoming easily annoyed or irritable"),
    ("GAD7_Q7", "Feeling afraid, as if something awful might happen"),
]

RESPONSE_TEXT_MAP = {0: "Not at all", 1: "Several days", 2: "More than half the days", 3: "Nearly every day"}

# PHQ-9 score distributions (must sum to total_score)
phq9_score_dist = {
    "o1": [1, 1, 1, 2, 1, 0, 1, 1, 0],  # sum=8
    "o2": [0, 0, 1, 1, 0, 0, 1, 0, 0],  # sum=3
    "o3": [2, 2, 2, 2, 2, 1, 1, 1, 0],  # sum=13... adjust
}
# Arjun score=14: distribute 14 across 9 items
phq9_score_dist["o3"] = [2, 2, 2, 2, 1, 2, 1, 1, 1]  # sum=14

gad7_score_dist = {
    "o1": [1, 1, 1, 1, 1, 0, 1],  # sum=6
    "o2": [0, 0, 1, 0, 1, 0, 0],  # sum=2
    "o3": [2, 2, 2, 1, 2, 1, 1],  # sum=11
}

assessment_responses = []

def build_responses(asmt_id, questions, score_dist):
    rows = []
    for (qid, qtext), score in zip(questions, score_dist):
        rows.append({
            "id": str(uuid.uuid4()),
            "assessment_id": asmt_id,
            "question_identifier": qid,
            "question_text": qtext,
            "response_value": score,
            "response_text": RESPONSE_TEXT_MAP.get(score, str(score)),
        })
    return rows

assessment_responses += build_responses(asmt_ids["o1_phq9"], PHQ9_QUESTIONS, phq9_score_dist["o1"])
assessment_responses += build_responses(asmt_ids["o2_phq9"], PHQ9_QUESTIONS, phq9_score_dist["o2"])
assessment_responses += build_responses(asmt_ids["o3_phq9"], PHQ9_QUESTIONS, phq9_score_dist["o3"])
assessment_responses += build_responses(asmt_ids["o1_gad7"], GAD7_QUESTIONS, gad7_score_dist["o1"])
assessment_responses += build_responses(asmt_ids["o2_gad7"], GAD7_QUESTIONS, gad7_score_dist["o2"])
assessment_responses += build_responses(asmt_ids["o3_gad7"], GAD7_QUESTIONS, gad7_score_dist["o3"])

safe_insert("assessment_responses", assessment_responses)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 11 — BIOMETRICS TABLE (7 days each)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 11: Seeding biometrics")
print("═" * 70)

biometric_profiles = {
    officer1_id: {
        "sleep_range":  (6.2, 6.8),
        "hrv_range":    (38.0, 45.0),
        "steps_range":  (7500, 9000),
        "hr_range":     (68, 75),
    },
    officer2_id: {
        "sleep_range":  (7.0, 7.5),
        "hrv_range":    (50.0, 58.0),
        "steps_range":  (9000, 11000),
        "hr_range":     (60, 68),
    },
    officer3_id: {
        "sleep_range":  (4.5, 5.5),
        "hrv_range":    (28.0, 35.0),
        "steps_range":  (5000, 7000),
        "hr_range":     (75, 85),
    },
}

biometrics = []
for oid, p in biometric_profiles.items():
    for i in range(7):
        d = TODAY - timedelta(days=i+1)
        biometrics.append({
            "id": str(uuid.uuid4()),
            "officer_id": oid,
            "recorded_date": d.isoformat(),
            "sleep_hours": round(random.uniform(*p["sleep_range"]), 2),
            "hrv_rmssd": round(random.uniform(*p["hrv_range"]), 2),
            "resting_heart_rate": random.randint(*p["hr_range"]),
            "activity_steps": random.randint(*p["steps_range"]),
            "device_source": "garmin",
            "sync_status": "synced",
            "consent_verified": True,
        })

safe_insert("biometrics", biometrics)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 12 — CONSENT_RECORDS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 12: Seeding consent_records")
print("═" * 70)

consent_records = []

consent_config = {
    officer1_id: {"public_recognition": True},
    officer2_id: {"public_recognition": True},
    officer3_id: {"public_recognition": False},
}

for oid, extra in consent_config.items():
    # biometrics consent
    consent_records.append({
        "id": str(uuid.uuid4()),
        "officer_id": oid,
        "consent_type": "biometrics",
        "is_granted": True,
        "scope": "sleep_hours,hrv_rmssd,activity_steps,resting_heart_rate",
        "version": "1.0",
    })
    # family_sharing consent
    consent_records.append({
        "id": str(uuid.uuid4()),
        "officer_id": oid,
        "consent_type": "family_sharing",
        "is_granted": True,
        "scope": "flash_notifications,morale_messages",
        "version": "1.0",
    })
    # public_recognition consent
    consent_records.append({
        "id": str(uuid.uuid4()),
        "officer_id": oid,
        "consent_type": "public_recognition",
        "is_granted": extra["public_recognition"],
        "scope": "milestone,commendation",
        "version": "1.0",
    })

safe_insert("consent_records", consent_records)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 13 — RISK_SCORES TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 13: Seeding risk_scores")
print("═" * 70)

risk_score_ids: dict = {}  # email → risk_score_id

risk_scores_data = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "score_date": NOW.isoformat(),
        "risk_probability": 0.4200,
        "risk_tier": "yellow",
        "model_version": "lgbm-v1.0-shadow",
        "prediction_window_days": 60,
        "confidence_interval_low": 0.3500,
        "confidence_interval_high": 0.4900,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "score_date": NOW.isoformat(),
        "risk_probability": 0.1500,
        "risk_tier": "green",
        "model_version": "lgbm-v1.0-shadow",
        "prediction_window_days": 60,
        "confidence_interval_low": 0.0900,
        "confidence_interval_high": 0.2100,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "score_date": NOW.isoformat(),
        "risk_probability": 0.7100,
        "risk_tier": "orange",
        "model_version": "lgbm-v1.0-shadow",
        "prediction_window_days": 60,
        "confidence_interval_low": 0.6300,
        "confidence_interval_high": 0.7900,
    },
]

inserted_risks = safe_insert("risk_scores", risk_scores_data)
risk_score_ids["officer1_id"] = risk_scores_data[0]["id"]
risk_score_ids["officer2_id"] = risk_scores_data[1]["id"]
risk_score_ids["officer3_id"] = risk_scores_data[2]["id"]

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 14 — INTERVENTIONS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 14: Seeding interventions")
print("═" * 70)

interventions_data = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "recommended_by_type": "welfare_officer",
        "intervention_type": "counselling",
        "status": "in_progress",
        "proposed_at": (NOW - timedelta(days=5)).isoformat(),
        "actioned_at": (NOW - timedelta(days=3)).isoformat(),
        "notes": "Referred to unit counsellor following elevated PHQ-9 score (14) and repeated operational leave rejections.",
    },
]
safe_insert("interventions", interventions_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 15 — CRISIS_EVENTS TABLE (0 events)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 15: crisis_events — 0 active crises (skipping insert)")
print("═" * 70)
# Verify table exists by doing a select
try:
    supabase.table("crisis_events").select("id").limit(1).execute()
    seeded_counts["crisis_events"] = 0
    print("  ✅ crisis_events: table exists, 0 rows inserted (by design)")
except Exception as e:
    if "does not exist" in str(e):
        skipped_tables.append("crisis_events")
        print("  ⚠️  crisis_events: TABLE DOES NOT EXIST")
    else:
        print(f"  ℹ️  crisis_events: {str(e)[:100]}")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 16 — FAMILY_MEMBERS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 16: Seeding family_members")
print("═" * 70)

family_member_ids: dict = {}

fm1_id = str(uuid.uuid4())
fm3a_id = str(uuid.uuid4())
fm3b_id = str(uuid.uuid4())

family_members_data = [
    # Officer1 — Vikram Singh: spouse Meera Singh
    {
        "id": fm1_id,
        "officer_id": officer1_id,
        "identity_id": identity_ids.get("family1@raksha.gov.in"),
        "relation": "spouse",
        "first_name": "Meera",
        "last_name": "Singh",
        "phone": "9876543210",
        "email": "meera.singh@gmail.com",
        "is_emergency_contact": True,
        "is_verified": True,
    },
    # Officer3 — Arjun Thakur: spouse Kavya Thakur
    {
        "id": fm3a_id,
        "officer_id": officer3_id,
        "relation": "spouse",
        "first_name": "Kavya",
        "last_name": "Thakur",
        "phone": "9988776655",
        "email": "kavya.thakur@gmail.com",
        "is_emergency_contact": True,
        "is_verified": True,
    },
    # Officer3 — parent Ram Prasad Thakur
    {
        "id": fm3b_id,
        "officer_id": officer3_id,
        "relation": "parent",
        "first_name": "Ram Prasad",
        "last_name": "Thakur",
        "phone": "9876001122",
        "is_emergency_contact": False,
        "is_verified": False,
    },
]
safe_insert("family_members", family_members_data)
family_member_ids = {"fm1": fm1_id, "fm3a": fm3a_id, "fm3b": fm3b_id}

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 17 — TEAM_SESSIONS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 17: Seeding team_sessions")
print("═" * 70)

counsellor_identity_id = identity_ids.get("counsellor@raksha.gov.in")

team_sessions_data = [
    {
        "id": str(uuid.uuid4()),
        "unit_id": unit_12bn_id,
        "facilitator_identity_id": counsellor_identity_id,
        "title": "Sleep Hygiene & Recovery Workshop",
        "topic": "sleep_hygiene",
        "scheduled_at": (NOW + timedelta(days=10)).isoformat(),
        "location": "Unit Welfare Hall, Rajasthan",
        "is_compulsory": False,
        "max_participants": 25,
        "status": "scheduled",
    },
    {
        "id": str(uuid.uuid4()),
        "unit_id": unit_12bn_id,
        "facilitator_identity_id": counsellor_identity_id,
        "title": "Operational Decompression Session",
        "topic": "operational_decompression",
        "scheduled_at": (NOW + timedelta(days=21)).isoformat(),
        "location": "Unit Welfare Hall, Rajasthan",
        "is_compulsory": False,
        "max_participants": 30,
        "status": "scheduled",
    },
]
safe_insert("team_sessions", team_sessions_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 18 — BULLETIN_EVENTS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 18: Seeding bulletin_events")
print("═" * 70)

bulletin_events_data = [
    {
        "id": str(uuid.uuid4()),
        "title": "CRPF Sports Meet 2026",
        "description": "Annual inter-battalion sports meet featuring athletics, football, and kabaddi.",
        "category": "sports",
        "location": "CRPF Sports Ground, New Delhi",
        "event_start": (NOW + timedelta(days=15)).isoformat(),
        "event_end": (NOW + timedelta(days=17)).isoformat(),
        "target_unit_id": unit_hq_id,
        "is_active": True,
    },
    {
        "id": str(uuid.uuid4()),
        "title": "Families of the Force Day — 2026",
        "description": "Annual family day celebration honouring the families of our officers. Cultural programs, awards, and community bonding.",
        "category": "family_day",
        "location": "Unit Parade Ground, Rajasthan",
        "event_start": (NOW + timedelta(days=30)).isoformat(),
        "event_end": (NOW + timedelta(days=30)).isoformat(),
        "target_unit_id": unit_12bn_id,
        "is_active": True,
    },
    {
        "id": str(uuid.uuid4()),
        "title": "CRPF Wellness Camp 2026",
        "description": "Multi-day wellness camp covering yoga, meditation, stress management techniques, and Ayush health sessions.",
        "category": "wellness_camp",
        "location": "CRPF Welfare Centre, Punjab",
        "event_start": (NOW + timedelta(days=45)).isoformat(),
        "event_end": (NOW + timedelta(days=47)).isoformat(),
        "target_unit_id": unit_45bn_id,
        "is_active": True,
    },
    {
        "id": str(uuid.uuid4()),
        "title": "Independence Day Cultural Programme",
        "description": "Cultural evening with folk dance, music, and poetry celebrating our national heritage and service spirit.",
        "category": "cultural",
        "location": "HQ CRPF Auditorium, New Delhi",
        "event_start": (NOW + timedelta(days=55)).isoformat(),
        "event_end": (NOW + timedelta(days=55)).isoformat(),
        "target_unit_id": unit_hq_id,
        "is_active": True,
    },
    {
        "id": str(uuid.uuid4()),
        "title": "Counter-Insurgency Training Seminar",
        "description": "Advanced tactical training seminar on modern counter-insurgency techniques and officer welfare during extended ops.",
        "category": "training",
        "location": "BSF Training Centre, Punjab",
        "event_start": (NOW + timedelta(days=20)).isoformat(),
        "event_end": (NOW + timedelta(days=22)).isoformat(),
        "target_unit_id": unit_45bn_id,
        "is_active": True,
    },
]
safe_insert("bulletin_events", bulletin_events_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 19 — RECOGNITIONS TABLE
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 19: Seeding recognitions")
print("═" * 70)

commander_identity_id = identity_ids.get("commander@raksha.gov.in")

recognitions_data = [
    # Officer1 — Leadership commendation
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "awarded_by_identity_id": commander_identity_id,
        "title": "Outstanding Leadership — Operation Shaurya",
        "citation": (
            "Subedar Vikram Singh demonstrated exemplary leadership during Operation Shaurya, "
            "ensuring the safety of personnel under severe field conditions. His calm under pressure "
            "and tactical acumen prevented potential casualties."
        ),
        "award_category": "leadership_commendation",
        "is_institution_level": False,
        "officer_consent_for_public": True,
        "opsec_cleared": True,
        "awarded_at": (NOW - timedelta(days=60)).isoformat(),
    },
    # Officer2 — 5-year milestone
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "awarded_by_identity_id": commander_identity_id,
        "title": "5 Years of Distinguished Service",
        "citation": (
            "Head Constable Priya Nair is recognised for completing five years of dedicated and "
            "distinguished service to the force. Her consistent performance and commitment to duty "
            "serve as an inspiration to the unit."
        ),
        "award_category": "milestone",
        "is_institution_level": False,
        "officer_consent_for_public": True,
        "opsec_cleared": True,
        "awarded_at": (NOW - timedelta(days=15)).isoformat(),
    },
]
safe_insert("recognitions", recognitions_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 20 — COUNSELLING_SESSIONS (counsellor_cases bridge)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 20: Seeding counselling_sessions (counsellor cases)")
print("═" * 70)

counselling_sessions_data = [
    # Case 1: Officer1 — mild, routine session
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "counsellor_identity_id": counsellor_identity_id,
        "session_date": (NOW - timedelta(days=14)).isoformat(),
        "session_type": "routine",
        "risk_level_assessed": "low",
        "recommendations": "Continue with routine check-ins. Encourage adequate rest between duties.",
        "attended": True,
        "next_session_date": (NOW + timedelta(days=14)).isoformat(),
    },
    # Case 2: Officer3 — moderate, welfare follow-up
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "counsellor_identity_id": counsellor_identity_id,
        "session_date": (NOW - timedelta(days=3)).isoformat(),
        "session_type": "welfare_followup",
        "risk_level_assessed": "elevated",
        "recommendations": (
            "Schedule bi-weekly sessions. Coordinate with welfare officer for leave facilitation. "
            "Monitor sleep patterns and biometrics closely."
        ),
        "attended": True,
        "next_session_date": (NOW + timedelta(days=11)).isoformat(),
    },
]
safe_insert("counselling_sessions", counselling_sessions_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 21 — RISK_EXPLANATIONS (SHAP values for each risk score)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 21: Seeding risk_explanations")
print("═" * 70)

risk_explanations = []

# Officer 1 explanations (moderate risk 0.42)
for rank, (feature, shap, val, direction, explanation) in enumerate([
    ("leave_rejections_90d", 0.12300, 2.0, "increases_risk", "2 operational leave rejections in 90 days increases risk."),
    ("sleep_hours_avg_7d",  -0.08200, 6.5, "decreases_risk", "Average sleep of 6.5 hours is below optimal but stable."),
    ("phq2_score_latest",    0.06100, 2.0, "increases_risk", "Latest PHQ-2 score of 2 indicates mild depressive symptoms."),
    ("duty_hours_avg_14d",   0.04500, 9.5, "increases_risk", "Duty hours averaging 9.5 h/day above threshold."),
], start=1):
    risk_explanations.append({
        "id": str(uuid.uuid4()),
        "risk_score_id": risk_score_ids["officer1_id"],
        "feature_name": feature,
        "shap_value": round(shap, 5),
        "feature_value": val,
        "direction": direction,
        "plain_language_explanation": explanation,
        "rank_order": rank,
    })

# Officer 2 explanations (low risk 0.15)
for rank, (feature, shap, val, direction, explanation) in enumerate([
    ("sleep_hours_avg_7d",  -0.09500, 7.2, "decreases_risk", "Good average sleep of 7.2 hours significantly reduces risk."),
    ("phq2_score_latest",   -0.05200, 1.0, "decreases_risk", "Minimal PHQ-2 score indicates good mood baseline."),
    ("leave_rejections_90d", 0.02100, 1.0, "increases_risk", "One leave rejection is a minor risk factor."),
], start=1):
    risk_explanations.append({
        "id": str(uuid.uuid4()),
        "risk_score_id": risk_score_ids["officer2_id"],
        "feature_name": feature,
        "shap_value": round(shap, 5),
        "feature_value": val,
        "direction": direction,
        "plain_language_explanation": explanation,
        "rank_order": rank,
    })

# Officer 3 explanations (high risk 0.71)
for rank, (feature, shap, val, direction, explanation) in enumerate([
    ("phq9_score_latest",    0.19800, 14.0, "increases_risk", "PHQ-9 score of 14 (moderate) is the primary risk driver."),
    ("leave_rejections_90d", 0.15200, 3.0,  "increases_risk", "3 operational leave rejections compound stress significantly."),
    ("sleep_hours_avg_7d",   0.13100, 5.0,  "increases_risk", "Average sleep of 5 hours is well below safe threshold."),
    ("hrv_rmssd_avg_7d",     0.08700, 31.0, "increases_risk", "Low HRV RMSSD of 31ms indicates physiological stress."),
    ("gad7_score_latest",    0.07400, 11.0, "increases_risk", "GAD-7 score of 11 indicates moderate anxiety."),
], start=1):
    risk_explanations.append({
        "id": str(uuid.uuid4()),
        "risk_score_id": risk_score_ids["officer3_id"],
        "feature_name": feature,
        "shap_value": round(shap, 5),
        "feature_value": val,
        "direction": direction,
        "plain_language_explanation": explanation,
        "rank_order": rank,
    })

safe_insert("risk_explanations", risk_explanations)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 22 — POSTINGS TABLE (one posting per officer)
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 22: Seeding postings")
print("═" * 70)

postings_data = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "unit_id": unit_12bn_id,
        "start_date": "2019-06-15",
        "end_date": None,
        "is_high_hazard": True,
        "hardship_score": 8,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "unit_id": unit_12bn_id,
        "start_date": "2022-03-10",
        "end_date": None,
        "is_high_hazard": True,
        "hardship_score": 7,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "unit_id": unit_45bn_id,
        "start_date": "2018-08-20",
        "end_date": None,
        "is_high_hazard": True,
        "hardship_score": 9,
    },
]
safe_insert("postings", postings_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 23 — MODEL_VERSIONS & MODEL_PREDICTIONS
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 23: Seeding model_versions and model_predictions")
print("═" * 70)

model_version_id = str(uuid.uuid4())
model_version_data = {
    "id": model_version_id,
    "model_name": "RakshaRisk-LightGBM",
    "version_tag": "lgbm-v1.0-shadow",
    "algorithm": "LightGBM",
    "hyperparameters": {"n_estimators": 500, "learning_rate": 0.05, "max_depth": 6},
    "trained_at": (NOW - timedelta(days=90)).isoformat(),
    "pr_auc": 0.7823,
    "brier_score": 0.1102,
    "high_risk_recall": 0.8100,
    "is_active": False,
    "is_shadow_mode": True,
}
safe_insert("model_versions", [model_version_data])

model_predictions_data = [
    {
        "id": str(uuid.uuid4()),
        "model_version_id": model_version_id,
        "officer_id": officer1_id,
        "prediction_timestamp": NOW.isoformat(),
        "predicted_probability": 0.4200,
        "predicted_tier": "yellow",
        "is_shadow_prediction": True,
        "ground_truth_verified": None,
    },
    {
        "id": str(uuid.uuid4()),
        "model_version_id": model_version_id,
        "officer_id": officer2_id,
        "prediction_timestamp": NOW.isoformat(),
        "predicted_probability": 0.1500,
        "predicted_tier": "green",
        "is_shadow_prediction": True,
        "ground_truth_verified": None,
    },
    {
        "id": str(uuid.uuid4()),
        "model_version_id": model_version_id,
        "officer_id": officer3_id,
        "prediction_timestamp": NOW.isoformat(),
        "predicted_probability": 0.7100,
        "predicted_tier": "orange",
        "is_shadow_prediction": True,
        "ground_truth_verified": None,
    },
]
safe_insert("model_predictions", model_predictions_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 24 — NOTIFICATIONS
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 24: Seeding notifications")
print("═" * 70)

notifications_data = []
for email, iid in identity_ids.items():
    if "officer" in email:
        notifications_data.append({
            "id": str(uuid.uuid4()),
            "recipient_identity_id": iid,
            "title": "Biweekly Check-in Due",
            "body": "Your biweekly wellness check-in is due. This takes only 2 minutes.",
            "notification_type": "checkin_reminder",
            "is_read": False,
            "sent_at": (NOW - timedelta(days=1)).isoformat(),
        })

notifications_data.append({
    "id": str(uuid.uuid4()),
    "recipient_identity_id": identity_ids.get("welfare@raksha.gov.in"),
    "title": "Officer Welfare Alert",
    "body": "Inspector Arjun Thakur (BSF-2018-9932) has been flagged for welfare attention. Risk tier: Orange.",
    "notification_type": "welfare_update",
    "is_read": False,
    "sent_at": (NOW - timedelta(hours=2)).isoformat(),
})

safe_insert("notifications", notifications_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 25 — STRESSORS
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 25: Seeding stressors")
print("═" * 70)

stressors_data = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "category": "organisational",
        "severity_level": 3,
        "is_active": True,
        "reported_at": (NOW - timedelta(days=45)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "category": "family",
        "severity_level": 4,
        "is_active": True,
        "reported_at": (NOW - timedelta(days=20)).isoformat(),
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "category": "operational",
        "severity_level": 5,
        "is_active": True,
        "reported_at": (NOW - timedelta(days=10)).isoformat(),
    },
]
safe_insert("stressors", stressors_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 26 — RETENTION_POLICIES
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 26: Seeding retention_policies")
print("═" * 70)

retention_data = [
    {"id": str(uuid.uuid4()), "table_name": "biometrics",             "retention_period_days": 730, "action_after_expiry": "anonymize", "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "check_ins",              "retention_period_days": 1825,"action_after_expiry": "anonymize", "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "assessments",            "retention_period_days": 3650,"action_after_expiry": "archive",   "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "counselling_sessions",   "retention_period_days": 3650,"action_after_expiry": "archive",   "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "crisis_events",          "retention_period_days": 3650,"action_after_expiry": "archive",   "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "audit_logs",             "retention_period_days": 2555,"action_after_expiry": "delete",    "is_active": True},
    {"id": str(uuid.uuid4()), "table_name": "morale_vault_media",     "retention_period_days": 365, "action_after_expiry": "delete",    "is_active": True},
]
safe_insert("retention_policies", retention_data)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 27 — WELFARE SCHEME DOCUMENTS
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 27: Seeding welfare_scheme_documents")
print("═" * 70)

welfare_doc_ids = [str(uuid.uuid4()) for _ in range(3)]
welfare_docs = [
    {
        "id": welfare_doc_ids[0],
        "scheme_name": "Ayushman CAPF Health Scheme",
        "issuing_authority": "Ministry of Home Affairs",
        "official_reference_number": "MHA/2021/CAPF/HEALTH/001",
        "language": "en",
        "document_version": "2.1",
        "effective_date": "2021-01-23",
    },
    {
        "id": welfare_doc_ids[1],
        "scheme_name": "PMSS-CAPF (Prime Minister Scholarship Scheme)",
        "issuing_authority": "Ministry of Home Affairs",
        "official_reference_number": "MHA/PMSS/2022/007",
        "language": "en",
        "document_version": "3.0",
        "effective_date": "2022-04-01",
    },
    {
        "id": welfare_doc_ids[2],
        "scheme_name": "Bharat Ke Veer Welfare Fund",
        "issuing_authority": "Ministry of Home Affairs",
        "official_reference_number": "MHA/BKV/2017/001",
        "language": "en",
        "document_version": "1.5",
        "effective_date": "2017-04-09",
    },
]
safe_insert("welfare_scheme_documents", welfare_docs)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 28 — PROGRESS_UPDATES
# ═══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 70)
print("STEP 28: Seeding progress_updates")
print("═" * 70)

welfare_identity_id = identity_ids.get("welfare@raksha.gov.in")

progress_updates_data = [
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer1_id,
        "updated_by_identity_id": welfare_identity_id,
        "status_indicator": "stable",
        "public_context_note": "Officer performing well in unit duties. No welfare concerns flagged.",
        "acr_synced": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer2_id,
        "updated_by_identity_id": welfare_identity_id,
        "status_indicator": "improving",
        "public_context_note": "Officer on track. Regular attendance and positive unit engagement noted.",
        "acr_synced": False,
    },
    {
        "id": str(uuid.uuid4()),
        "officer_id": officer3_id,
        "updated_by_identity_id": welfare_identity_id,
        "status_indicator": "requires_support",
        "public_context_note": "Officer enrolled in limited duty. Welfare support in progress.",
        "acr_synced": False,
    },
]
safe_insert("progress_updates", progress_updates_data)

# ═══════════════════════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

print("\n\n" + "═" * 70)
print("SEEDING COMPLETE — FINAL SUMMARY")
print("═" * 70)

print("\n📊 Tables seeded successfully:")
total_rows = 0
for table, count in sorted(seeded_counts.items()):
    print(f"  {'✅' if count > 0 else 'ℹ️ '} {table:<35} {count:>4} row(s)")
    total_rows += count
print(f"\n  Total rows inserted: {total_rows}")

if skipped_tables:
    print(f"\n⚠️  Tables NOT in DB (schema not applied):")
    for t in skipped_tables:
        print(f"  - {t}")

if errors:
    print(f"\n❌ Errors encountered:")
    for e in errors:
        print(f"  - {e}")

print("\n🔑 Auth User IDs:")
for email, uid in auth_user_ids.items():
    print(f"  {email:<35} → {uid}")

print("\n🪖 Officer UUIDs (for next agent):")
print(f"  officer1 (Vikram Singh)  → {officer1_id}")
print(f"  officer2 (Priya Nair)    → {officer2_id}")
print(f"  officer3 (Arjun Thakur)  → {officer3_id}")

print("\n🏛️  Unit UUIDs:")
print(f"  HQ CRPF Delhi            → {unit_hq_id}")
print(f"  12 Bn CRPF Charlie Co    → {unit_12bn_id}")
print(f"  45 Bn BSF Alpha Co       → {unit_45bn_id}")

print("\n🆔 Identity UUIDs:")
for email, iid in identity_ids.items():
    print(f"  {email:<35} → {iid}")

print("\n" + "═" * 70)
print("Done.")
print("═" * 70)
