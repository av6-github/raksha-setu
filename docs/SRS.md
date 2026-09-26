# SRS.md
# AI-Based Predictive Personnel Stress and Welfare Monitoring System

**Tagline:** Morale wins wars.

## 1. Document Purpose

This Software Requirements Specification (SRS) defines the functional, non-functional, privacy, security, AI/ML, data, role, crisis-response, family-support, welfare, recognition, reporting, and deployment requirements for the Flutter-based officer welfare application and its supporting backend services.

The product is a **welfare-first, consent-based, explainable AI platform**. It learns each officer's personal baseline, detects meaningful deviation from that baseline, explains the reasons for flags, and routes the officer toward appropriate human support. **The AI recommends and prioritises. Humans decide.**

The application must not become a surveillance, punishment, promotion, posting, or disciplinary system.

## 2. Problem Statement

CAPF and other uniformed personnel face long deployments, irregular hours, separation from family, trauma exposure, workload pressure, and organisational stress. Existing identification through manual observation and self-reporting can be late, stigmatised, and inconsistent. The system shall identify early warning signals, support personnel before a crisis, and preserve privacy and trust.

## 3. Goals

1. Detect emerging psychological risk early.
2. Compare an officer primarily against their own historical baseline rather than a population average.
3. Combine organisational/HR indicators with private officer-provided wellness signals.
4. Explain every model-generated risk flag.
5. Route serious cases to humans rather than automating consequential decisions.
6. Provide a structured crisis protocol.
7. Include family and peer support with granular, revocable consent.
8. Provide welfare-scheme discovery through grounded RAG.
9. Improve unit-level workload and morale insights without exposing individual distress.
10. Maintain a hard welfare-HR/ACR firewall.
11. Support offline-first mobile use, Hindi and regional languages, and voice input.
12. Maintain auditable, role-based, privacy-preserving access.
13. Support a shadow-mode pilot before live decision support.

## 4. Scope

### 4.1 In Scope

- Flutter officer mobile application.
- Authentication, MFA/app lock and role-based access.
- Biweekly compulsory short wellness check-ins.
- Quarterly or triggered full assessments.
- PHQ-2, GAD-2, PHQ-9, GAD-7, PCL-5, DASS-21.
- PHQ-9 item 9 and C-SSRS crisis triage.
- Structured family/financial/organisational stressor categories.
- Optional wearable/biometric data.
- HRMS read-only integration.
- Personal baseline creation and cold-start cohort priors.
- Change-point/deviation detection.
- Risk prediction for elevated psychological risk in the next 30-60 days.
- SHAP explanations.
- Risk tiers: Green, Yellow, Orange, Red.
- Human review and counsellor scheduling.
- Graded intervention ladder.
- Clinician-controlled temporary off-duty workflow.
- 24x7 human crisis response integration.
- Stepped care and counsellor-capacity-aware queue prioritisation.
- Officer, welfare officer, counsellor, commander, and family experiences.
- Family consent and sharing controls.
- Flash family notifications.
- Morale Vault for family/friend voice and video.
- Operational-security content filtering and human review.
- Family education/training.
- Team-bonding and wellness sessions.
- Anonymous whistle-blower/welfare reporting.
- Performance metric and encouraging LLM feedback with strict guardrails.
- Commander progress/status tracking.
- ACR integration as contextual, non-clinical information only.
- Welfare-scheme RAG assistant with source citations.
- Bulletin board.
- Recognition and appreciation.
- Testimonials/trust commitments.
- Unit-level anomaly detection and workload balancing.
- Access logs visible to officers.
- Immutable audit logging and break-glass access.
- Data minimisation, pseudonymisation and identity/analytics separation.
- k-anonymity and differential privacy for aggregate views.
- Encryption and key-management architecture.
- Offline-first encrypted local storage and background sync.
- SMS/IVR fallback for poor connectivity.
- Federated/edge-learning architecture.
- Retention/deletion workflows.
- Bias, drift, calibration and subgroup monitoring.
- Synthetic-data development and shadow-mode pilot.
- KPI measurement and rollout support.

### 4.2 Explicitly Out of Scope

- Automatic punishment.
- Automatic disciplinary action.
- Automatic promotion/posting decisions.
- Stress scores entering ACR as scored inputs.
- Automatic temporary off-duty decisions.
- AI/LLM acting as a crisis responder.
- AI independently deciding weapon/access restrictions.
- Individual commander access to clinical detail by default.
- Fabricated welfare schemes, entitlements, benefits, citations, clinical guidance, or operational facts.
- Public disclosure of individual personnel or deployment information.

## 5. Users and Roles

### 5.1 Officer

Can:
- Complete check-ins and assessments.
- View own trends and scores.
- View SHAP explanations.
- View recommendations.
- Manage family consent and sharing.
- View upcoming sessions.
- View who accessed their information.
- Use the welfare-scheme assistant.
- Use support, recognition, bulletin-board, team-session, and reporting features.
- Control voluntary biometrics.
- Control notification windows.
- Review trust commitments.

The officer can always view everything about themselves that the system stores and is permitted to expose.

### 5.2 Welfare Officer

Can:
- Receive escalated cases.
- See pseudonymised risk tiers.
- Review SHAP explanations.
- Initiate welfare outreach.
- Coordinate family-support pipelines subject to consent.
- Coordinate wellness sessions and interventions.

### 5.3 Counsellor / Clinician

Can:
- View full clinical detail when unlocked by officer engagement or a red-tier trigger.
- Conduct risk assessment.
- Create safety plans.
- Recommend interventions.
- Recommend temporary off-duty status.
- Manage crisis cases.
- Work with family where permitted.
- Participate in follow-up and return-to-duty plans.

### 5.4 Commander

Default:
- Sees aggregated unit/company/platoon risk and workload insights.
- Sees roster/workload recommendations.
- Sees officer availability status as available / welfare-supported / limited duty.
- Does not see individual stress reasons or clinical details by default.

Individual detail may be unlocked only by:
- Officer consent;
- Clinician recommendation; or
- Defined high-risk threshold requiring action.

Even when unlocked, the system must expose only the minimum information required to act.

### 5.5 Family Member

Only after officer consent:
- Receives permitted messages.
- Uploads non-operational Morale Vault media.
- Views family-support/training content.
- Participates in counsellor-led support when authorised.

### 5.6 Welfare/Vigilance Cell

Receives anonymous reports through a technically separated channel.

### 5.7 System Administrator / Security Administrator

Manages infrastructure, configuration, access policies, audit systems, and operational controls. Administrative access must not imply access to clinical content unless separately authorised and audited.

## 6. Functional Requirements

### FR-01 Authentication and Access

- Support secure authentication.
- Support MFA where configured.
- Support app lock.
- Enforce RBAC/ABAC.
- Support break-glass access.
- Log every individual-record access.
- Make individual access history visible to the officer.
- Separate identity vault from pseudonymised analytics data.

### FR-02 Biweekly Check-In

Every two weeks:
- Require a short check-in of approximately two minutes.
- Include PHQ-2, GAD-2, sleep and workload.
- Permit optional free-text or voice note.
- Treat responses as confidential and non-disciplinary.
- Work offline and sync later.
- Record completion status.

### FR-03 Full Assessment

Quarterly, or when a trigger occurs:
- PHQ-9.
- GAD-7.
- PCL-5.
- DASS-21.

PHQ-9 item 9 above zero must immediately invoke the crisis workflow.

### FR-04 Contextual Stressors

Allow officer to report:
- Family issues.
- Financial issues.
- Organisational issues.

These categories must be treated as stressors and must be used only for approved welfare/analytics purposes.

### FR-05 Voluntary Biometrics

Support opt-in data such as:
- Sleep.
- Heart-rate variability.
- Activity.

The feature must be:
- Voluntary.
- Consent-controlled.
- Legally authorised.
- Revocable.
- Clearly separated from mandatory data.

### FR-06 HRMS Integration

Read-only integration shall consume minimal approved fields:
- Leave applications, approvals and rejections.
- Leave rejection reason, including operational necessity vs other.
- Deployment history.
- Safe/unsafe/high-hardship postings.
- Hardship duration/frequency.
- Time since low-hazard posting.
- Duty hours.
- Night shifts.
- Consecutive duty days.
- Overtime.
- Transfer frequency and recency.
- Gaps between transfers.
- Training load and timing.
- Rolling workload trends.
- Approved performance/context fields where relevant.

Organisational decisions such as operationally rejected leave must not be treated as personal blame signals.

### FR-07 Personal Baseline

For each officer:
- Build baseline during first 4-6 weeks.
- Use check-ins and HR data.
- Use cohort priors for new joiners.
- Cohort priors may use role, posting type, and service stage.
- Gradually shrink from cohort priors toward individual observations.
- Do not treat day one and day sixty as equally informative.

### FR-08 Deviation Detection

Detect meaningful deviations such as:
- Sustained sleep deterioration.
- Rising leave rejections.
- Increasing duty hours.
- Worsening check-in scores.
- Sudden change following an incident or life event.
- Combined workload changes.

Candidate techniques include CUSUM or Bayesian online change-point detection.

### FR-09 Risk Prediction

The predictive target is:
**elevated psychological risk in the next 30-60 days**, not a generic label of "stressed."

Ground-truth/label candidates:
- PHQ-9 >= 10.
- GAD-7 >= 10.
- PCL-5 >= 33.
- Counsellor-confirmed cases.
- Clinician-adjudicated review of a sample.

Candidate model:
- LightGBM/XGBoost.
- SHAP explanations.
- Optional lightweight time-series models later.

### FR-10 Explainability

Every risk flag must include:
- Top contributing features.
- Plain-language explanation.
- Direction/magnitude where meaningful.
- Relevant time window.

Example style:
"Leave rejections have increased sharply, sleep responses have worsened over recent check-ins, and the officer has had consecutive hardship postings."

Explanations must be shown to the welfare reviewer and officer.

### FR-11 Group Anomaly Detection

Group officers anonymously by approved organisational dimensions such as:
- Unit.
- Posting.
- Shift pattern.
- Issue type.

Do not group by stress score in a way that exposes individuals.

Detect:
- Whole-company distress after incidents.
- Posting-associated recurring distress.
- Workload imbalance.
- Organisational problem patterns.

Outputs must support unit-level interventions and workload rebalancing.

### FR-12 Risk Tiers

**Green:** within baseline.
- Routine check-ins.
- Self-help content.

**Yellow:** sustained deviation or moderate scores.
- Welfare outreach.
- Wellness session.
- Workload review.

**Orange:** severe scores or strong model flag with life-event trigger.
- Counsellor contact within defined window.
- Private officer meeting.
- Graded intervention options.

**Red:** PHQ-9 item 9 above zero, positive C-SSRS, or direct disclosure.
- Immediate human contact.

### FR-13 Intervention Ladder

For elevated cases:
1. Model flags.
2. Welfare officer reviews.
3. Counsellor meeting is automatically scheduled/offered.
4. Officer receives a private explanation.
5. Officer and human support staff choose options together.
6. Options include:
   - Workload adjustment.
   - Leave.
   - Shift change.
   - Light duty.
   - Counselling sessions.
   - Temporary off-duty.
7. Temporary off-duty requires clinician recommendation.
8. Commander receives only "medically unavailable" rather than the reason.
9. Follow-up review.
10. Return-to-duty plan.

No automated punishment.

### FR-14 Crisis Protocol

Critical cases must:
- Use PHQ-9 item 9 and C-SSRS screening as specified by the approved clinical protocol.
- Immediately hand off to a human.
- Provide 24x7 human responder integration.
- Integrate the force tele-counselling desk and, where approved, national Tele-MANAS 14416.
- Support immediate clinician risk assessment.
- Support safety planning.
- Permit clinician-led, command-authorised review of access to weapons/means according to force policy.
- Permit counsellor-family contact under consent/emergency-safety protocol.
- Prioritise cases according to counsellor capacity.
- Use stepped care.

**The LLM must never handle a crisis.**

### FR-15 Officer Dashboard

Show:
- Own trends.
- Scores.
- SHAP explanations.
- Recommendations.
- Upcoming sessions.
- Family/consent settings.
- Data-access log.
- Support resources.
- Bulletin board.
- Recognition.
- Welfare schemes.

### FR-16 Welfare Dashboard

Show:
- Pseudonymised risk tiers.
- Escalations.
- SHAP explanations where authorised.
- Workload/welfare context.
- Family-support pipeline.

### FR-17 Commander Dashboard

Show:
- Unit/company/platoon aggregate risk.
- Aggregate workload.
- Roster recommendations.
- Unit-level trends.
- Welfare-supported/available/limited-duty status.
- Performance/progress where authorised.

Do not show individual clinical reasons by default.

### FR-18 Family Support

All family involvement:
- Opt-in.
- Granular.
- Revocable.

Features:
- Flash supportive notifications.
- Generic notifications that do not reveal duty patterns.
- Officer-selected notification windows.
- Morale Vault voice/video.
- Automated operational-security filter.
- Human review of flagged media.
- Family training.
- Case-specific guidance with consent.
- Emergency family protocol when consent is impossible.

### FR-19 Morale Vault Security

Family/friend media must be checked for:
- Location.
- Uniform details.
- Insignia.
- Operational references.

The system must not publish unsafe content. Automated filtering must be backed by human review.

### FR-20 Team Cohesion

Schedule:
- Team-bonding sessions.
- HR wellness sessions.

Scheduling:
- Around common leave/free time.
- Avoid duty/rest conflicts.
- Group by role, unit and shift.
- Never group by stress score.
- Attendance compulsory as specified by policy.
- Sharing voluntary.
- Trained facilitator required.
- Topics: sleep, finances, family, resilience.
- One-to-one alternative always available.

### FR-21 Anonymous Reporting

Provide anonymous reporting for:
- Bullying.
- Harassment.
- Unsafe conditions.
- Concern for a colleague.
- Other welfare concerns.

Reports must go to a separate independent welfare/vigilance cell. Identity protection must be technical, not merely procedural.

### FR-22 Performance Metric

Calculate an officer performance metric and identify areas for improvement where performance is negative.

The implementation must not convert stress/clinical scores into ACR/promotion scores.

### FR-23 Encouraging LLM Feedback

LLM may communicate approved improvement areas using:
- Supportive tone.
- Approved templates.
- Vetted content.
- On-prem/approved hosting.
- No medical diagnosis.
- No medical advice.
- Output filters.
- Refusal-plus-routing for sensitive topics.
- Human-reviewed prompts.
- Full logging.
- No crisis role.

### FR-24 Commander Progress Tracking

Authorised commanders may:
- View performance/progress.
- Update officer status.

### FR-25 ACR Integration

ACR data may contain:
- Name.
- Designation.
- Service period.
- Health status as part of source system where applicable.
- Aptitude.
- Intelligence.
- Efficiency.
- Execution.
- Character/conduct.
- Integrity.
- Reliability.
- Discipline.
- Social conduct.
- Grading.

System rules:
- Stress data is not an ACR scored input.
- Stress assessments/counselling records never appear in ACR.
- Stress information does not feed promotion/posting decisions.
- ACR-style performance data may be read into the welfare engine with officer awareness.
- Non-clinical HR context notes may be provided to reporting officers.
- Any use of stress information in evaluation requires explicit officer consent.

### FR-26 Welfare-Scheme RAG Assistant

Provide multilingual plain-language answers from an approved, regularly updated scheme library.

Must:
- Cite source documents.
- Refuse to invent entitlements.
- Show source date/version where available.
- Distinguish retrieved facts from unavailable information.

Potential source areas from the concept:
- Ayushman CAPF.
- PMSS-CAPF.
- CAPF e-Awas/housing.
- Pension/ex-gratia provisions.
- Bharat Ke Veer.
- CAPF Punarvaas.
- Risk and Hardship Allowances.
- Modernisation Plan-IV.

All figures and current eligibility details must be verified against authoritative sources before production use.

### FR-27 Bulletin Board

Show tailored events based on:
- Location.
- Interests.
- Free time.

Potential categories:
- Sports.
- Cultural events.
- Family days.
- Training.
- Wellness camps.
- Community programmes.

### FR-28 Recognition

Provide:
- Personalised appreciation.
- Milestone notes.
- Leadership commendations.

Public appreciation may be enabled only:
- At institution level; or
- With explicit officer consent.

Public content must be non-identifying and reviewed for operational security.

### FR-29 Trust and Adoption

App shall display:
- No link to ACR for stress scores.
- No disciplinary use.
- Consent controls.
- Officer access logs.
- Independent oversight information.
- Testimonials where legally and operationally approved.

Support co-design and shadow-mode pilot with volunteer officers/welfare staff.

## 7. Data Requirements

### 7.1 Core Entities

At minimum, the backend data model shall support:

- officers
- identities
- roles
- units
- postings
- deployments
- leave_records
- duty_records
- shifts
- transfers
- training_records
- check_ins
- assessments
- assessment_responses
- stressors
- biometrics
- consent_records
- risk_scores
- risk_explanations
- risk_events
- interventions
- counselling_sessions
- crisis_events
- safety_plans
- followups
- return_to_duty_plans
- family_members
- family_consents
- morale_vault_media
- media_security_reviews
- family_training
- team_sessions
- session_attendance
- anonymous_reports
- performance_records
- progress_updates
- acr_context_notes
- welfare_scheme_documents
- welfare_scheme_chunks
- welfare_scheme_sources
- bulletin_events
- event_interest_preferences
- recognitions
- testimonials
- notifications
- notification_preferences
- audit_logs
- break_glass_events
- model_versions
- model_predictions
- model_monitoring_metrics
- bias_audits
- drift_metrics
- retention_policies
- deletion_requests
- oversight_reviews

The exact schema must be created during **Phase 0 only after the owner provides required environment/configuration values and approves the final schema**.

## 8. Security and Privacy Requirements

- AES-256 at rest.
- TLS 1.3 in transit.
- Field-level encryption for clinical data.
- HSM/KMS-managed keys.
- Identity vault separated from analytics.
- RBAC/ABAC.
- MFA.
- Immutable audit logs.
- Break-glass access always logged and reviewed.
- Officer-visible access history.
- k-anonymity minimum group size, e.g. 10, for unit dashboards.
- Differential privacy for aggregate statistics.
- HRMS read-only API gateway.
- Data minimisation.
- Encrypted local mobile store.
- On-device baseline computation where feasible.
- Background sync.
- SMS/IVR poor-connectivity fallback.
- No screenshots.
- Defined retention windows.
- Deletion on request/separation/retention expiry where permitted.
- Only de-identified aggregates persist beyond approved retention.
- Anti-stigmatisation safeguards.
- Welfare-HR firewall.
- Bias audits.
- Independent ethics/oversight.

## 9. Deployment Requirements

The source concept specifies:
- On-prem or government-controlled cloud.
- Isolated per-force tenant.
- No public cloud.

The project owner's preference is to keep services remote and use managed services such as Supabase, Pinecone and Cloudinary. This creates a deployment-policy conflict with the source requirement. **No public-cloud production deployment may be assumed.** Phase 0 must explicitly decide the approved environment.

Architecture should therefore use provider interfaces/abstractions so approved remote services can be used in a prototype without hard-coding the product to an unapproved deployment model.

## 10. Offline-First Requirements

The Flutter app shall:
- Continue core check-ins without connectivity.
- Encrypt locally stored sensitive data.
- Queue sync operations.
- Resolve retries safely.
- Avoid duplicate submissions.
- Show sync status.
- Avoid silently dropping data.
- Use SMS/IVR fallback only if explicitly approved and configured.

## 11. ML Requirements

- Personal baseline first.
- Cold-start cohort priors.
- Change-point detection.
- Gradient-boosting risk model.
- SHAP.
- Optional later time-series models.
- PR-AUC.
- High-risk recall.
- Precision@k based on counsellor capacity.
- Brier score.
- Reliability curves.
- Subgroup recall/false-positive audits by rank, region, posting, gender and language.
- Separate organisational factors from individual behaviour.
- Feature/score drift monitoring.
- Scheduled retraining.
- Seasonal/operation-cycle effects.
- Synthetic data first.
- Shadow-mode pilot before live influence.

## 12. Non-Functional Requirements

### Reliability
No critical data loss. Crisis routing must fail safely.

### Explainability
Every model flag must have human-readable reasons.

### Privacy
Least privilege and minimum necessary exposure.

### Availability
Critical human routing should be designed for 24x7 operation.

### Performance
The officer app should remain responsive on constrained devices and networks.

### Accessibility
Support regional languages, voice input, readable UI, and low-connectivity conditions.

### Auditability
Every sensitive access and high-impact action must be traceable.

### Maintainability
Backend providers, models, storage, vector databases and LLM providers must be replaceable through interfaces.

### Scalability
Support growth from pilot unit to multiple battalions/forces.

## 13. KPI Requirements

Measure:
- Time from first deviation to first contact.
- Share of high-risk cases detected.
- Serious incident rate per 1,000 personnel.
- Fatigue-related duty errors.
- PHQ-9/GAD-7/DASS-21 change over time.
- Duty availability.
- Unit readiness indicators.
- Variance in hours and consecutive duty days.
- Attrition.
- Early-retirement requests.
- Satisfaction.
- Use of unit-level insights for resource allocation.
- Serious incident trends in pilot vs control.
- Check-in completion rate.
- Family opt-in rate.
- Trust score.
- Anonymous-channel usage.

## 14. Rollout

### Phase 0
Design/consent, co-design, legal/ethics review, clinical validation, environment and database setup.

### Phase 1
Shadow pilot. Silent model scoring compared with counsellor judgement.

### Phase 2
Live pilot with check-ins, dashboards, family opt-in, crisis desk and KPI/control-unit comparison.

### Phase 3
Scale across battalions/forces, federated learning and more languages.

### Phase 4
Expand to state police, disaster response, emergency services and other high-stress government workforces.

## 15. Risk Requirements

| Risk | Required mitigation |
|---|---|
| Career fear | Welfare-HR firewall, no stress ACR link, access logs, testimonials |
| Stigma | Commanders see trends, not individual reasons |
| False positives/negatives | Tiered thresholds, human review, multiple safety nets, calibration |
| Counsellor shortage | Stepped care, capacity scheduling, tele-counselling, peers |
| Cyber threats | Approved infrastructure, encryption, audit, break-glass |
| Operational leakage | Media filters, generic notifications, no public identity |
| LLM errors | Vetted RAG, templates, guardrails, no crisis role |
| Survey fatigue | Two-minute biweekly check-ins, full battery quarterly/triggered |

## 16. Acceptance Principle

The system is acceptable only when it can demonstrate that it:
1. Helps personnel before crises.
2. Preserves officer agency.
3. Explains AI decisions.
4. Keeps welfare data separated from disciplinary/career systems.
5. Routes critical cases to humans.
6. Does not fabricate welfare information.
7. Does not expose individuals through aggregate views.
8. Can operate under approved deployment and connectivity constraints.
