-- 20260925000002_assessments_and_checkins.sql
-- Phase 0: Assessments, Biweekly Check-ins, Contextual Stressors, Biometrics, and Officer Consent

-- 1. CONSENT_RECORDS
-- Manages officer explicit, granular, and revocable consent across features
CREATE TABLE consent_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    consent_type VARCHAR(50) NOT NULL, -- 'biometrics', 'family_sharing', 'acr_read_context', 'public_recognition', 'research_co_design'
    is_granted BOOLEAN NOT NULL DEFAULT FALSE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE,
    scope TEXT, -- Specific parameters or data points authorized
    version VARCHAR(20) NOT NULL DEFAULT '1.0',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CHECK_INS
-- Biweekly short check-in responses (PHQ-2, GAD-2, sleep, workload, encrypted text/voice)
CREATE TABLE check_ins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    check_in_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    phq2_score INTEGER CHECK (phq2_score BETWEEN 0 AND 6),
    gad2_score INTEGER CHECK (gad2_score BETWEEN 0 AND 6),
    sleep_quality_score INTEGER CHECK (sleep_quality_score BETWEEN 1 AND 5),
    workload_score INTEGER CHECK (workload_score BETWEEN 1 AND 5),
    free_text_encrypted TEXT, -- Encrypted field for officer private notes
    voice_note_url TEXT,
    voice_note_duration_sec INTEGER,
    is_offline_submission BOOLEAN DEFAULT FALSE,
    synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ASSESSMENTS
-- Comprehensive clinical assessments (PHQ-9, GAD-7, PCL-5, DASS-21, C-SSRS)
CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    assessment_type VARCHAR(50) NOT NULL, -- 'phq9', 'gad7', 'pcl5', 'dass21', 'cssrs'
    trigger_reason VARCHAR(100) NOT NULL DEFAULT 'quarterly_routine', -- 'quarterly_routine', 'elevated_risk_trigger', 'clinician_initiated'
    total_score NUMERIC(5,2) NOT NULL,
    severity_tier VARCHAR(20) NOT NULL, -- 'normal', 'mild', 'moderate', 'severe', 'crisis'
    phq9_item9_score INTEGER DEFAULT 0 CHECK (phq9_item9_score BETWEEN 0 AND 3),
    is_crisis_flagged BOOLEAN DEFAULT FALSE, -- Set TRUE immediately if PHQ-9 item 9 > 0 or C-SSRS positive
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. ASSESSMENT_RESPONSES
-- Granular item-level responses for auditing and clinical assessment review
CREATE TABLE assessment_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assessment_id UUID NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_identifier VARCHAR(50) NOT NULL, -- e.g., 'PHQ9_Q1', 'GAD7_Q3'
    question_text TEXT,
    response_value INTEGER NOT NULL,
    response_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. STRESSORS
-- Self-reported contextual stressors (family, financial, organisational, operational)
CREATE TABLE stressors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL, -- 'family', 'financial', 'organisational', 'operational', 'health'
    description_encrypted TEXT,
    severity_level INTEGER CHECK (severity_level BETWEEN 1 AND 5),
    is_active BOOLEAN DEFAULT TRUE,
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. BIOMETRICS
-- Voluntary, opt-in biometric telemetry (sleep, HRV, activity). Strictly consent-controlled.
CREATE TABLE biometrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    recorded_date DATE NOT NULL,
    sleep_hours NUMERIC(4,2),
    hrv_rmssd NUMERIC(6,2),
    resting_heart_rate INTEGER,
    activity_steps INTEGER,
    device_source VARCHAR(100), -- 'fitbit', 'apple_health', 'garmin', 'manual'
    sync_status VARCHAR(20) DEFAULT 'synced',
    consent_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_officer_biometric_date UNIQUE (officer_id, recorded_date)
);

-- INDEXES
CREATE INDEX idx_consent_officer ON consent_records(officer_id, consent_type);
CREATE INDEX idx_check_ins_officer_date ON check_ins(officer_id, check_in_date);
CREATE INDEX idx_assessments_officer_type ON assessments(officer_id, assessment_type);
CREATE INDEX idx_assessments_crisis ON assessments(is_crisis_flagged) WHERE is_crisis_flagged = TRUE;
CREATE INDEX idx_stressors_officer ON stressors(officer_id, is_active);
CREATE INDEX idx_biometrics_officer_date ON biometrics(officer_id, recorded_date);
