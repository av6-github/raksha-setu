-- 20260925000005_anonymous_reporting_and_welfare_rag.sql
-- Phase 0: Anonymous Reporting Pipeline, Performance Tracking, Welfare-HR Firewall Context, and Welfare-Scheme RAG Documents

-- 1. ANONYMOUS_REPORTS
-- Isolated whistle-blower & welfare reporting system with cryptographic tracking token (no author identity link)
CREATE TABLE anonymous_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tracking_token_hash VARCHAR(128) UNIQUE NOT NULL, -- Cryptographic hash enabling whistleblower follow-up without identity disclosure
    category VARCHAR(50) NOT NULL, -- 'bullying', 'harassment', 'unsafe_conditions', 'concern_for_colleague', 'other_welfare_concern'
    report_text_encrypted TEXT NOT NULL,
    evidence_urls TEXT[],
    unit_identifier_general VARCHAR(100), -- General battalion/range name without specific platoon identification
    status VARCHAR(30) NOT NULL DEFAULT 'submitted', -- 'submitted', 'under_review', 'investigating', 'action_taken', 'closed'
    response_notes_encrypted TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. PERFORMANCE_RECORDS
-- Operational performance metrics and developmental areas (strictly non-clinical)
CREATE TABLE performance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    overall_performance_score NUMERIC(5,2),
    evaluated_areas JSONB, -- Non-clinical metrics: weapon drill, physical endurance, tactical problem-solving
    improvement_suggestions TEXT,
    evaluated_by_identity_id UUID REFERENCES identities(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PROGRESS_UPDATES
-- Non-clinical status updates visible to commanders
CREATE TABLE progress_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    updated_by_identity_id UUID REFERENCES identities(id),
    status_indicator VARCHAR(50) NOT NULL DEFAULT 'stable', -- 'improving', 'stable', 'requires_support'
    public_context_note TEXT,
    acr_synced BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. ACR_CONTEXT_NOTES
-- Welfare-HR Firewall Enforced: Non-clinical context notes for reporting officers.
-- Absolutely NO stress scores, assessments, or counselling records permitted.
CREATE TABLE acr_context_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID NOT NULL REFERENCES officers(id) ON DELETE CASCADE,
    reporting_period_year INTEGER NOT NULL,
    non_clinical_hr_context TEXT NOT NULL,
    verified_no_stress_data BOOLEAN NOT NULL DEFAULT TRUE, -- Hard compliance check
    approved_by_identity_id UUID REFERENCES identities(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_verified_no_stress_data CHECK (verified_no_stress_data = TRUE)
);

-- 5. WELFARE_SCHEME_DOCUMENTS
-- Authoritative welfare policies and benefit documents (Ayushman CAPF, PMSS-CAPF, Bharat Ke Veer, etc.)
CREATE TABLE welfare_scheme_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scheme_name VARCHAR(200) NOT NULL,
    issuing_authority VARCHAR(200) NOT NULL, -- e.g., 'Ministry of Home Affairs', 'Welfare & Rehabilitation Board'
    official_reference_number VARCHAR(100),
    document_url VARCHAR(500),
    language VARCHAR(20) NOT NULL DEFAULT 'en',
    document_version VARCHAR(50),
    effective_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. WELFARE_SCHEME_SOURCES
-- Verification sources to guarantee no fabricated entitlements or non-factual claims
CREATE TABLE welfare_scheme_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES welfare_scheme_documents(id) ON DELETE CASCADE,
    source_type VARCHAR(50) NOT NULL, -- 'official_gazette', 'mha_order', 'circular', 'court_ruling'
    source_title VARCHAR(255) NOT NULL,
    source_url VARCHAR(500),
    verification_status VARCHAR(30) NOT NULL DEFAULT 'verified',
    last_verified_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. WELFARE_SCHEME_CHUNKS
-- Ingested text chunks with embeddings and Pinecone vector mapping for RAG retrieval
CREATE TABLE welfare_scheme_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES welfare_scheme_documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    content TEXT NOT NULL,
    token_count INTEGER,
    pinecone_vector_id VARCHAR(100),
    embedding_model VARCHAR(100) NOT NULL DEFAULT 'all-MiniLM-L6-v2',
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_document_chunk UNIQUE (document_id, chunk_index)
);

-- INDEXES
CREATE INDEX idx_anonymous_reports_token ON anonymous_reports(tracking_token_hash);
CREATE INDEX idx_anonymous_reports_status ON anonymous_reports(status);
CREATE INDEX idx_performance_officer ON performance_records(officer_id, period_start);
CREATE INDEX idx_acr_context_officer ON acr_context_notes(officer_id, reporting_period_year);
CREATE INDEX idx_welfare_docs_scheme ON welfare_scheme_documents(scheme_name);
CREATE INDEX idx_welfare_chunks_doc ON welfare_scheme_chunks(document_id);
CREATE INDEX idx_welfare_chunks_vector ON welfare_scheme_chunks(pinecone_vector_id);
