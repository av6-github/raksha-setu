-- 20260925000004_family_morale_and_team.sql
-- Phase 0: Family Support, Morale Vault, Media OPSEC Reviews, and Team Sessions

-- 1. FAMILY_MEMBERS
-- Enrolled family members linked to an officer profile, subject to opt-in consent
CREATE TABLE family_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    identity_id UUID REFERENCES identities(id) ON DELETE SET NULL,
    relation VARCHAR(50) NOT NULL, -- 'spouse', 'parent', 'child', 'sibling', 'guardian'
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    is_emergency_contact BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. FAMILY_CONSENTS
-- Granular, revocable consent for family communication, morale vault, and emergency workflows
CREATE TABLE family_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    family_member_id UUID NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
    share_flash_notifications BOOLEAN NOT NULL DEFAULT FALSE,
    share_morale_messages BOOLEAN NOT NULL DEFAULT TRUE,
    share_training_material BOOLEAN NOT NULL DEFAULT TRUE,
    emergency_contact_authorized BOOLEAN NOT NULL DEFAULT TRUE,
    notification_window_start TIME,
    notification_window_end TIME,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_officer_family_consent UNIQUE (officer_id, family_member_id)
);

-- 3. MORALE_VAULT_MEDIA
-- Audio and video media uploaded by family/friends to bolster morale
CREATE TABLE morale_vault_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    family_member_id UUID REFERENCES family_members(id) ON DELETE SET NULL,
    media_url VARCHAR(500) NOT NULL,
    media_type VARCHAR(20) NOT NULL, -- 'audio', 'video', 'image'
    storage_provider VARCHAR(50) NOT NULL DEFAULT 'cloudinary',
    cloudinary_public_id VARCHAR(255),
    security_status VARCHAR(30) NOT NULL DEFAULT 'pending_review', -- 'pending_review', 'auto_flagged', 'human_approved', 'rejected'
    tags TEXT[],
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. MEDIA_SECURITY_REVIEWS
-- Operational security (OPSEC) review records ensuring location, insignia, or tactical data are not leaked
CREATE TABLE media_security_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    media_id UUID NOT NULL REFERENCES morale_vault_media(id) ON DELETE CASCADE,
    reviewer_identity_id UUID REFERENCES identities(id),
    automated_filter_score NUMERIC(4,3),
    detected_flags TEXT[], -- e.g., ['location_leak', 'insignia_detected', 'tactical_equipment']
    review_decision VARCHAR(20) NOT NULL, -- 'approved', 'rejected', 'quarantined'
    review_notes TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. FAMILY_TRAINING
-- Psychoeducational modules and resilience training content for family members
CREATE TABLE family_training (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    content_type VARCHAR(50) NOT NULL, -- 'resilience_guide', 'video_module', 'article'
    media_url VARCHAR(500),
    target_audience VARCHAR(50) NOT NULL DEFAULT 'all', -- 'spouse', 'parents', 'all'
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. TEAM_SESSIONS
-- Team-bonding and wellness sessions scheduled around duty/rest rosters (never grouped by stress score)
CREATE TABLE team_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id) ON DELETE CASCADE,
    facilitator_identity_id UUID REFERENCES identities(id),
    title VARCHAR(200) NOT NULL,
    topic VARCHAR(100) NOT NULL, -- 'sleep_hygiene', 'financial_resilience', 'family_stress', 'operational_decompression'
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(150),
    is_compulsory BOOLEAN NOT NULL DEFAULT FALSE,
    max_participants INTEGER NOT NULL DEFAULT 25,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. SESSION_ATTENDANCE
-- Attendance tracking with confidential option for 1-on-1 alternative session
CREATE TABLE session_attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES team_sessions(id) ON DELETE CASCADE,
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    attended BOOLEAN NOT NULL DEFAULT FALSE,
    opted_for_individual_alternative BOOLEAN NOT NULL DEFAULT FALSE,
    feedback_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_session_officer_attendance UNIQUE (session_id, officer_id)
);

-- INDEXES
CREATE INDEX idx_family_members_officer ON family_members(officer_id);
CREATE INDEX idx_morale_vault_officer ON morale_vault_media(officer_id, security_status);
CREATE INDEX idx_media_security_review ON media_security_reviews(media_id);
CREATE INDEX idx_team_sessions_unit_date ON team_sessions(unit_id, scheduled_at);
CREATE INDEX idx_session_attendance_officer ON session_attendance(officer_id);
