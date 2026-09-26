-- 20260925000006_bulletin_recognition_audit_and_ml.sql
-- Phase 0: Bulletin Events, Recognition, Notifications, Immutable Audit Trail, ML Governance & Data Retention

-- 1. BULLETIN_EVENTS
-- Welfare and community bulletin board items (sports, cultural, wellness camps, community)
CREATE TABLE bulletin_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'sports', 'cultural', 'family_day', 'training', 'wellness_camp', 'community_programme'
    location VARCHAR(150),
    event_start TIMESTAMP WITH TIME ZONE NOT NULL,
    event_end TIMESTAMP WITH TIME ZONE NOT NULL,
    target_unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. EVENT_INTEREST_PREFERENCES
-- Officer personal interests and notification preferences for bulletin events
CREATE TABLE event_interest_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    interested_categories TEXT[],
    location_preference VARCHAR(100),
    notification_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_officer_event_pref UNIQUE (officer_id)
);

-- 3. RECOGNITIONS
-- Milestones, commendations, and institutional appreciation notes (OPSEC cleared; public requires consent)
CREATE TABLE recognitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    awarded_by_identity_id UUID REFERENCES identities(id),
    title VARCHAR(150) NOT NULL,
    citation TEXT NOT NULL,
    award_category VARCHAR(50) NOT NULL, -- 'milestone', 'leadership_commendation', 'appreciation_note'
    is_institution_level BOOLEAN NOT NULL DEFAULT FALSE,
    officer_consent_for_public BOOLEAN NOT NULL DEFAULT FALSE,
    opsec_cleared BOOLEAN NOT NULL DEFAULT TRUE,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TESTIMONIALS
-- Curated officer/veteran testimonials on welfare and mental health support to reduce stigma
CREATE TABLE testimonials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author_role_display VARCHAR(100) NOT NULL, -- e.g., 'Sub-Inspector, 45 Bn CRPF (Retired)'
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by_identity_id UUID REFERENCES identities(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. NOTIFICATIONS
-- In-app and push notification delivery records
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_identity_id UUID NOT NULL REFERENCES identities(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL, -- 'checkin_reminder', 'session_alert', 'morale_vault_ready', 'welfare_update', 'crisis_escalation'
    payload JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. NOTIFICATION_PREFERENCES
-- Officer/user notification quiet hours and channel preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identity_id UUID NOT NULL REFERENCES identities(id) ON DELETE CASCADE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    allow_push BOOLEAN NOT NULL DEFAULT TRUE,
    allow_sms BOOLEAN NOT NULL DEFAULT FALSE,
    emergency_override BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_identity_notif_pref UNIQUE (identity_id)
);

-- 7. AUDIT_LOGS
-- Immutable append-only audit trail for all sensitive reads and modifications
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_identity_id UUID REFERENCES identities(id),
    action VARCHAR(100) NOT NULL, -- 'READ_CLINICAL', 'UPDATE_RISK', 'EXPORT_AGGREGATE', 'BREAK_GLASS'
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 8. BREAK_GLASS_EVENTS
-- High-privilege emergency clinical access logs requiring post-hoc oversight review
CREATE TABLE break_glass_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_identity_id UUID NOT NULL REFERENCES identities(id),
    officer_id UUID NOT NULL REFERENCES officers(id),
    reason TEXT NOT NULL,
    authorized_by VARCHAR(100) NOT NULL,
    access_granted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    access_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    review_status VARCHAR(30) NOT NULL DEFAULT 'pending_review', -- 'pending_review', 'validated_emergency', 'unjustified_breach'
    reviewer_identity_id UUID REFERENCES identities(id),
    reviewed_at TIMESTAMP WITH TIME ZONE
);

-- 9. MODEL_VERSIONS
-- Registry of predictive ML models (LightGBM/XGBoost/CUSUM) and operational calibration metrics
CREATE TABLE model_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL,
    version_tag VARCHAR(50) UNIQUE NOT NULL,
    algorithm VARCHAR(50) NOT NULL, -- 'LightGBM', 'XGBoost', 'CUSUM', 'BOCPD'
    hyperparameters JSONB,
    training_data_hash VARCHAR(128),
    trained_at TIMESTAMP WITH TIME ZONE NOT NULL,
    pr_auc NUMERIC(5,4),
    brier_score NUMERIC(5,4),
    high_risk_recall NUMERIC(5,4),
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_shadow_mode BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. MODEL_PREDICTIONS
-- Audit log of all model inferences (enabling shadow pilot validation against ground truth)
CREATE TABLE model_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_version_id UUID REFERENCES model_versions(id),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    prediction_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    predicted_probability NUMERIC(5,4) NOT NULL,
    predicted_tier VARCHAR(20) NOT NULL,
    is_shadow_prediction BOOLEAN NOT NULL DEFAULT TRUE,
    ground_truth_verified BOOLEAN,
    verified_at TIMESTAMP WITH TIME ZONE
);

-- 11. MODEL_MONITORING_METRICS
-- Calibration, PR-AUC, and Brier score tracking over rolling 30-day windows
CREATE TABLE model_monitoring_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_version_id UUID REFERENCES model_versions(id) ON DELETE CASCADE,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    metric_name VARCHAR(100) NOT NULL, -- 'pr_auc', 'brier_score', 'precision_at_k', 'high_risk_recall'
    metric_value NUMERIC(10,5) NOT NULL,
    window_days INTEGER NOT NULL DEFAULT 30
);

-- 12. BIAS_AUDITS
-- Disparity, recall, and false-positive rate audits across subgroups (gender, rank, region, hardship)
CREATE TABLE bias_audits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_version_id UUID REFERENCES model_versions(id) ON DELETE CASCADE,
    audit_date DATE NOT NULL,
    audited_subgroup VARCHAR(100) NOT NULL, -- 'gender', 'rank', 'hardship_posting', 'region'
    sample_size INTEGER NOT NULL,
    false_positive_rate NUMERIC(5,4) NOT NULL,
    false_negative_rate NUMERIC(5,4) NOT NULL,
    disparity_metric NUMERIC(5,4) NOT NULL,
    is_compliant BOOLEAN NOT NULL DEFAULT TRUE,
    auditor_identity_id UUID REFERENCES identities(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. DRIFT_METRICS
-- Population Stability Index (PSI) and Kolmogorov-Smirnov (KS) feature drift detection
CREATE TABLE drift_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_version_id UUID REFERENCES model_versions(id) ON DELETE CASCADE,
    feature_name VARCHAR(100) NOT NULL,
    psi_score NUMERIC(8,5) NOT NULL,
    ks_statistic NUMERIC(8,5),
    drift_detected BOOLEAN NOT NULL DEFAULT FALSE,
    computed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. RETENTION_POLICIES
-- Configurable data retention windows and disposal actions (delete / anonymize)
CREATE TABLE retention_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(100) NOT NULL,
    retention_period_days INTEGER NOT NULL,
    action_after_expiry VARCHAR(50) NOT NULL DEFAULT 'anonymize', -- 'delete', 'anonymize', 'archive'
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. DELETION_REQUESTS
-- Officer-initiated or separation-driven data deletion requests
CREATE TABLE deletion_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    requester_identity_id UUID REFERENCES identities(id),
    request_type VARCHAR(50) NOT NULL, -- 'voluntary_biometrics', 'morale_vault_media', 'officer_separation'
    status VARCHAR(30) NOT NULL DEFAULT 'submitted', -- 'submitted', 'processing', 'completed', 'rejected'
    justification TEXT,
    processed_by_identity_id UUID REFERENCES identities(id),
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 16. OVERSIGHT_REVIEWS
-- Independent ethics and clinical oversight committee audit reports
CREATE TABLE oversight_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_date DATE NOT NULL,
    review_type VARCHAR(50) NOT NULL, -- 'ethics_board', 'clinical_audit', 'firewall_verification', 'anti_stigmatisation'
    findings TEXT NOT NULL,
    corrective_actions TEXT,
    approved_by_identity_id UUID REFERENCES identities(id),
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_bulletin_events_active ON bulletin_events(is_active, event_start);
CREATE INDEX idx_recognitions_officer ON recognitions(officer_id);
CREATE INDEX idx_notifications_recipient ON notifications(recipient_identity_id, is_read);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_identity_id, created_at);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_break_glass_officer ON break_glass_events(officer_id);
CREATE INDEX idx_model_predictions_officer ON model_predictions(officer_id, prediction_timestamp);
CREATE INDEX idx_drift_metrics_feature ON drift_metrics(model_version_id, feature_name);
