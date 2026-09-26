-- 20260925000003_risk_interventions_and_crisis.sql
-- Phase 0: Predictive Risk Scores, SHAP Explanations, Interventions, and Clinical Crisis Management

-- 1. RISK_SCORES
-- Predictive risk outputs for elevated psychological risk in 30-60 days
CREATE TABLE risk_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    score_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    risk_probability NUMERIC(5,4) NOT NULL, -- 0.0000 to 1.0000
    risk_tier VARCHAR(20) NOT NULL, -- 'green', 'yellow', 'orange', 'red'
    model_version VARCHAR(50) NOT NULL,
    prediction_window_days INTEGER NOT NULL DEFAULT 60,
    confidence_interval_low NUMERIC(5,4),
    confidence_interval_high NUMERIC(5,4),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. RISK_EXPLANATIONS
-- Feature attribution explanations (SHAP values & human-readable templates)
CREATE TABLE risk_explanations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    risk_score_id UUID NOT NULL REFERENCES risk_scores(id) ON DELETE CASCADE,
    feature_name VARCHAR(100) NOT NULL,
    shap_value NUMERIC(8,5) NOT NULL,
    feature_value NUMERIC(10,4),
    direction VARCHAR(20) NOT NULL, -- 'increases_risk', 'decreases_risk'
    plain_language_explanation TEXT NOT NULL,
    rank_order INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. RISK_EVENTS
-- Baseline deviation and change-point events (CUSUM, BOCPD, anomaly triggers)
CREATE TABLE risk_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'deviation_cusum', 'bocpd_changepoint', 'sustained_sleep_drop', 'high_leave_rejections', 'incident_aftermath'
    detected_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    baseline_value NUMERIC(8,2),
    current_value NUMERIC(8,2),
    status VARCHAR(20) NOT NULL DEFAULT 'open', -- 'open', 'reviewed', 'resolved'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. INTERVENTIONS
-- Graded intervention ladder (workload adjustment, leave, shift change, light duty, counselling, temporary off-duty)
CREATE TABLE interventions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    recommended_by_type VARCHAR(50) NOT NULL, -- 'welfare_officer', 'clinician', 'system_tier'
    intervention_type VARCHAR(50) NOT NULL, -- 'workload_adjustment', 'leave_granted', 'shift_change', 'light_duty', 'counselling', 'temporary_off_duty'
    status VARCHAR(30) NOT NULL DEFAULT 'proposed', -- 'proposed', 'accepted', 'in_progress', 'completed', 'declined'
    proposed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    actioned_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. COUNSELLING_SESSIONS
-- Confidential clinical sessions conducted by qualified clinicians/counsellors
CREATE TABLE counselling_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    counsellor_identity_id UUID REFERENCES identities(id),
    session_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    session_type VARCHAR(50) NOT NULL, -- 'routine', 'welfare_followup', 'crisis_escalation', 'tele_counselling'
    session_notes_encrypted TEXT,
    risk_level_assessed VARCHAR(20), -- 'low', 'moderate', 'elevated', 'imminent'
    recommendations TEXT,
    attended BOOLEAN NOT NULL DEFAULT TRUE,
    next_session_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. CRISIS_EVENTS
-- Emergency crisis disclosures/flags (PHQ-9 item 9, C-SSRS, direct disclosure). Strictly routed to human responders.
CREATE TABLE crisis_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    trigger_source VARCHAR(50) NOT NULL, -- 'phq9_item9', 'cssrs_positive', 'direct_disclosure', 'officer_sos'
    triggered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    responder_identity_id UUID REFERENCES identities(id),
    desk_routed VARCHAR(50) NOT NULL DEFAULT 'force_tele_counselling', -- 'force_tele_counselling', 'tele_manas_14416', 'duty_clinician'
    status VARCHAR(30) NOT NULL DEFAULT 'active', -- 'active', 'contained', 'hospitalised', 'resolved'
    notes_encrypted TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. SAFETY_PLANS
-- Clinician-authored crisis safety plan with copings, contacts, and means-restriction recommendations
CREATE TABLE safety_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crisis_event_id UUID REFERENCES crisis_events(id) ON DELETE CASCADE,
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    clinician_identity_id UUID REFERENCES identities(id),
    warning_signs TEXT NOT NULL,
    coping_strategies TEXT NOT NULL,
    social_contacts_encrypted TEXT,
    professional_resources TEXT NOT NULL,
    means_restriction_recommendation TEXT,
    plan_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. FOLLOWUPS
-- Scheduled clinician and welfare follow-up check-ins post-crisis or post-intervention
CREATE TABLE followups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crisis_event_id UUID REFERENCES crisis_events(id) ON DELETE SET NULL,
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    clinician_identity_id UUID REFERENCES identities(id),
    scheduled_date DATE NOT NULL,
    conducted_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'completed', 'missed', 'rescheduled'
    assessment_notes_encrypted TEXT,
    next_action TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. RETURN_TO_DUTY_PLANS
-- Gradual reintegration plan after temporary off-duty status. Commander only sees 'medically unavailable' until cleared.
CREATE TABLE return_to_duty_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    clinician_identity_id UUID REFERENCES identities(id),
    off_duty_start DATE NOT NULL,
    expected_return_date DATE,
    actual_return_date DATE,
    graded_steps TEXT,
    commander_status_disclosed VARCHAR(50) NOT NULL DEFAULT 'medically_unavailable',
    clinician_clearance_granted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_risk_scores_officer ON risk_scores(officer_id, score_date);
CREATE INDEX idx_risk_scores_tier ON risk_scores(risk_tier);
CREATE INDEX idx_risk_explanations_score ON risk_explanations(risk_score_id);
CREATE INDEX idx_risk_events_officer ON risk_events(officer_id, status);
CREATE INDEX idx_interventions_officer ON interventions(officer_id, status);
CREATE INDEX idx_counselling_sessions_officer ON counselling_sessions(officer_id, session_date);
CREATE INDEX idx_crisis_events_officer_status ON crisis_events(officer_id, status);
CREATE INDEX idx_safety_plans_officer ON safety_plans(officer_id);
CREATE INDEX idx_followups_officer_date ON followups(officer_id, scheduled_date);
CREATE INDEX idx_return_to_duty_officer ON return_to_duty_plans(officer_id);
