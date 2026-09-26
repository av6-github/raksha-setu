-- 20260925000001_core_and_hr.sql
-- Phase 0: Core Identity, Organisation, and HR Data Models

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. ROLES
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL, -- e.g., 'officer', 'welfare_officer', 'counsellor', 'commander', 'family', 'admin'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. UNITS
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    parent_unit_id UUID REFERENCES units(id),
    location VARCHAR(100),
    is_high_hardship BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. IDENTITIES (Auth Wrapper)
-- Links to Supabase auth.users but allows local metadata without mixing schemas
CREATE TABLE identities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE NOT NULL, -- Reference to auth.users.id
    role_id UUID REFERENCES roles(id),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    status VARCHAR(20) DEFAULT 'active', -- active, suspended, separated
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. OFFICERS
CREATE TABLE officers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    identity_id UUID UNIQUE REFERENCES identities(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES units(id),
    service_number VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    designation VARCHAR(100),
    date_of_joining DATE NOT NULL,
    blood_group VARCHAR(10),
    gender VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE, -- Duty availability
    limited_duty BOOLEAN DEFAULT FALSE,
    welfare_supported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. POSTINGS
CREATE TABLE postings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    unit_id UUID REFERENCES units(id),
    start_date DATE NOT NULL,
    end_date DATE,
    is_high_hazard BOOLEAN DEFAULT FALSE,
    hardship_score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. DEPLOYMENTS
CREATE TABLE deployments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    location VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    operation_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. LEAVE_RECORDS
CREATE TABLE leave_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    leave_type VARCHAR(50) NOT NULL, -- earned, casual, medical, etc.
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL, -- applied, approved, rejected
    rejection_reason VARCHAR(255),
    is_operational_rejection BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. SHIFTS
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID REFERENCES units(id),
    name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_night_shift BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. DUTY_RECORDS
CREATE TABLE duty_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    shift_id UUID REFERENCES shifts(id),
    duty_date DATE NOT NULL,
    hours_worked NUMERIC(4,1) NOT NULL,
    is_overtime BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. TRANSFERS
CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    from_unit_id UUID REFERENCES units(id),
    to_unit_id UUID REFERENCES units(id),
    transfer_date DATE NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. TRAINING_RECORDS
CREATE TABLE training_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officers(id) ON DELETE CASCADE,
    course_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20), -- enrolled, completed, failed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_officers_unit ON officers(unit_id);
CREATE INDEX idx_leave_officer ON leave_records(officer_id);
CREATE INDEX idx_duty_officer_date ON duty_records(officer_id, duty_date);
CREATE INDEX idx_postings_officer ON postings(officer_id);

-- RLS (Row Level Security) Boilerplate
ALTER TABLE identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE officers ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE duty_records ENABLE ROW LEVEL SECURITY;

-- We will apply specific RLS policies in a dedicated security migration.
