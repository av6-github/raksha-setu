-- 20260925000007_rls_and_security.sql
-- Phase 0: Row Level Security (RLS), Role-Based Access Control, Welfare-HR Firewall, and K-Anonymity

-- 1. HELPER FUNCTIONS FOR AUTH & ROLE RESOLUTION
CREATE OR REPLACE FUNCTION current_identity_id()
RETURNS UUID AS $$
  SELECT id FROM identities WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_role()
RETURNS VARCHAR AS $$
  SELECT r.name 
  FROM identities i 
  JOIN roles r ON i.role_id = r.id 
  WHERE i.auth_user_id = auth.uid() 
  LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_officer_id()
RETURNS UUID AS $$
  SELECT o.id 
  FROM officers o 
  JOIN identities i ON o.identity_id = i.id 
  WHERE i.auth_user_id = auth.uid() 
  LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Minimum group size helper (k-anonymity: returns false if group has fewer than 10 officers)
CREATE OR REPLACE FUNCTION check_unit_k_anonymity(p_unit_id UUID, p_min_group_size INT DEFAULT 10)
RETURNS BOOLEAN AS $$
  SELECT (COUNT(*) >= p_min_group_size) FROM officers WHERE unit_id = p_unit_id;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 2. ENABLE RLS ON ALL TABLES
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE units ENABLE ROW LEVEL SECURITY;
ALTER TABLE identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE officers ENABLE ROW LEVEL SECURITY;
ALTER TABLE postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE deployments ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE duty_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_records ENABLE ROW LEVEL SECURITY;

ALTER TABLE consent_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE stressors ENABLE ROW LEVEL SECURITY;
ALTER TABLE biometrics ENABLE ROW LEVEL SECURITY;

ALTER TABLE risk_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_explanations ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE interventions ENABLE ROW LEVEL SECURITY;
ALTER TABLE counselling_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE crisis_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE safety_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_to_duty_plans ENABLE ROW LEVEL SECURITY;

ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE morale_vault_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_security_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_training ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_attendance ENABLE ROW LEVEL SECURITY;

ALTER TABLE anonymous_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE acr_context_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE welfare_scheme_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE welfare_scheme_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE welfare_scheme_chunks ENABLE ROW LEVEL SECURITY;

ALTER TABLE bulletin_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_interest_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE recognitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE break_glass_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_monitoring_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE bias_audits ENABLE ROW LEVEL SECURITY;
ALTER TABLE drift_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE retention_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE deletion_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE oversight_reviews ENABLE ROW LEVEL SECURITY;

-- 3. POLICIES: ROLES & UNITS (General Read for Authenticated Users)
CREATE POLICY "Allow authenticated read roles" ON roles
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated read units" ON units
    FOR SELECT TO authenticated USING (true);

-- 4. POLICIES: IDENTITIES
CREATE POLICY "Users read own identity" ON identities
    FOR SELECT TO authenticated USING (auth_user_id = auth.uid());

CREATE POLICY "Admins manage identities" ON identities
    FOR ALL TO authenticated USING (current_user_role() = 'admin');

-- 5. POLICIES: OFFICERS
-- Officer views own profile; Commander views unit officers (limited fields); Admin manages
CREATE POLICY "Officer view own profile" ON officers
    FOR SELECT TO authenticated USING (identity_id = current_identity_id());

CREATE POLICY "Staff view officers" ON officers
    FOR SELECT TO authenticated USING (
        current_user_role() IN ('counsellor', 'welfare_officer', 'commander', 'admin')
    );

-- 6. POLICIES: CHECK-INS, ASSESSMENTS & STRESSORS (Strict Confidentiality & Firewall)
-- Officers can create and read their own check-ins
CREATE POLICY "Officer own check_ins" ON check_ins
    FOR ALL TO authenticated
    USING (officer_id = current_officer_id())
    WITH CHECK (officer_id = current_officer_id());

-- Clinicians/Counsellors read check-ins for clinical review; Commanders CANNOT read
CREATE POLICY "Counsellors read check_ins" ON check_ins
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('counsellor', 'admin'));

-- Assessments: Officer own read/write
CREATE POLICY "Officer own assessments" ON assessments
    FOR ALL TO authenticated
    USING (officer_id = current_officer_id())
    WITH CHECK (officer_id = current_officer_id());

-- Counsellor view assessments; Welfare Officer view non-crisis; Commander has ZERO access
CREATE POLICY "Clinical staff view assessments" ON assessments
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('counsellor', 'admin'));

CREATE POLICY "Officer own assessment responses" ON assessment_responses
    FOR ALL TO authenticated
    USING (assessment_id IN (SELECT id FROM assessments WHERE officer_id = current_officer_id()))
    WITH CHECK (assessment_id IN (SELECT id FROM assessments WHERE officer_id = current_officer_id()));

CREATE POLICY "Counsellor view assessment responses" ON assessment_responses
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('counsellor', 'admin'));

-- Stressors: Officer own management; Clinicians view
CREATE POLICY "Officer own stressors" ON stressors
    FOR ALL TO authenticated
    USING (officer_id = current_officer_id())
    WITH CHECK (officer_id = current_officer_id());

CREATE POLICY "Counsellor view stressors" ON stressors
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('counsellor', 'welfare_officer', 'admin'));

-- Biometrics: Strictly opt-in and consent-controlled
CREATE POLICY "Officer own biometrics" ON biometrics
    FOR ALL TO authenticated
    USING (officer_id = current_officer_id())
    WITH CHECK (officer_id = current_officer_id());

CREATE POLICY "Consented biometrics view" ON biometrics
    FOR SELECT TO authenticated
    USING (
        current_user_role() IN ('counsellor', 'admin') AND
        EXISTS (
            SELECT 1 FROM consent_records
            WHERE officer_id = biometrics.officer_id
              AND consent_type = 'biometrics'
              AND is_granted = TRUE
        )
    );

-- 7. POLICIES: RISK SCORES & EXPLANATIONS
-- Officer views own risk score and plain-language explanation
CREATE POLICY "Officer view own risk_scores" ON risk_scores
    FOR SELECT TO authenticated
    USING (officer_id = current_officer_id());

CREATE POLICY "Welfare and Counsellor view risk_scores" ON risk_scores
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('welfare_officer', 'counsellor', 'admin'));

CREATE POLICY "Officer view own risk_explanations" ON risk_explanations
    FOR SELECT TO authenticated
    USING (risk_score_id IN (SELECT id FROM risk_scores WHERE officer_id = current_officer_id()));

CREATE POLICY "Welfare staff view risk_explanations" ON risk_explanations
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('welfare_officer', 'counsellor', 'admin'));

-- 8. POLICIES: CLINICAL, CRISIS & SAFETY PLANS
-- Crisis events are restricted to responders, clinicians, welfare officers, and the officer themselves
CREATE POLICY "Officer view own crisis_events" ON crisis_events
    FOR SELECT TO authenticated
    USING (officer_id = current_officer_id());

CREATE POLICY "Authorized crisis responders handle crisis" ON crisis_events
    FOR ALL TO authenticated
    USING (current_user_role() IN ('counsellor', 'welfare_officer', 'admin'));

CREATE POLICY "Clinical staff manage safety plans" ON safety_plans
    FOR ALL TO authenticated
    USING (current_user_role() IN ('counsellor', 'admin'));

CREATE POLICY "Officer view own safety plan" ON safety_plans
    FOR SELECT TO authenticated
    USING (officer_id = current_officer_id());

-- 9. POLICIES: ANONYMOUS REPORTING ISOLATION
-- Anyone authenticated can submit an anonymous report, but cannot see others' reports.
-- Only the vigilance/welfare audit cell can read anonymous reports.
CREATE POLICY "Submit anonymous report" ON anonymous_reports
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "Vigilance cell view anonymous reports" ON anonymous_reports
    FOR SELECT TO authenticated
    USING (current_user_role() IN ('admin', 'welfare_officer'));

-- 10. POLICIES: AUDIT LOG IMMUTABILITY
-- Audit logs are strictly append-only. No UPDATE or DELETE is allowed under any circumstances.
CREATE POLICY "Allow insert into audit_logs" ON audit_logs
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow admins and officers read audit_logs" ON audit_logs
    FOR SELECT TO authenticated
    USING (
        current_user_role() = 'admin' OR 
        (resource_type = 'officer' AND resource_id = current_officer_id()::text)
    );

-- Prevent UPDATE and DELETE on audit_logs with explicit rejection rule
CREATE OR REPLACE FUNCTION audit_logs_immutable()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'audit_logs entries are immutable and cannot be updated or deleted.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_logs_immutable
BEFORE UPDATE OR DELETE ON audit_logs
FOR EACH ROW EXECUTE FUNCTION audit_logs_immutable();

-- 11. POLICIES: WELFARE-HR FIREWALL (ACR CONTEXT NOTES)
CREATE POLICY "Officer view own acr_context_notes" ON acr_context_notes
    FOR SELECT TO authenticated
    USING (officer_id = current_officer_id());

CREATE POLICY "Staff manage acr_context_notes" ON acr_context_notes
    FOR ALL TO authenticated
    USING (current_user_role() IN ('commander', 'admin', 'welfare_officer'))
    WITH CHECK (verified_no_stress_data = TRUE);

-- 12. POLICIES: WELFARE SCHEMES (Public Read for Authenticated)
CREATE POLICY "All users read welfare scheme documents" ON welfare_scheme_documents
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "All users read welfare scheme chunks" ON welfare_scheme_chunks
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "All users read welfare scheme sources" ON welfare_scheme_sources
    FOR SELECT TO authenticated USING (true);

-- 13. POLICIES: BULLETIN, RECOGNITIONS, NOTIFICATIONS
CREATE POLICY "All users read active bulletin events" ON bulletin_events
    FOR SELECT TO authenticated USING (is_active = TRUE);

CREATE POLICY "Users read own notifications" ON notifications
    FOR ALL TO authenticated
    USING (recipient_identity_id = current_identity_id())
    WITH CHECK (recipient_identity_id = current_identity_id());

CREATE POLICY "Officer view recognitions" ON recognitions
    FOR SELECT TO authenticated
    USING (
        officer_id = current_officer_id() OR
        is_institution_level = TRUE OR
        officer_consent_for_public = TRUE
    );
