# ARCHITECTURE.md
# AI-Based Predictive Personnel Stress and Welfare Monitoring System

## 1. Architecture Principles

1. Welfare over surveillance.
2. Officer agency over automated action.
3. Personal baseline over generic population threshold.
4. Explainability by default.
5. Human-in-the-loop for consequential decisions.
6. Crisis handling is human-only.
7. Minimum necessary data exposure.
8. Hard welfare-HR/ACR firewall.
9. Offline-first mobile experience.
10. Provider abstraction and replaceable infrastructure.
11. No fabricated data, entitlements, clinical advice, or operational facts.
12. Audit everything sensitive.
13. Prefer remote managed services where approved, but never violate the deployment policy defined during Phase 0.

## 2. High-Level Architecture

```text
                         ┌───────────────────────────┐
                         │       Flutter App         │
                         │ Officer / Family /       │
                         │ Support Experiences       │
                         └─────────────┬─────────────┘
                                       │
                         TLS 1.3 / Authenticated API
                                       │
                         ┌─────────────▼─────────────┐
                         │ API / Application Layer   │
                         │ Auth, RBAC/ABAC, consent  │
                         │ workflows, orchestration  │
                         └──────┬─────────┬──────────┘
                                │         │
                 ┌──────────────┘         └────────────────┐
                 ▼                                         ▼
       ┌─────────────────┐                       ┌─────────────────┐
       │ Supabase/Postgres│                       │ Object Storage  │
       │ or approved DB   │                       │ / Media Layer   │
       │ transactional DB │                       │ Cloudinary or   │
       └────────┬────────┘                       │ approved store  │
                │                                └────────┬────────┘
                │                                         │
                ▼                                         ▼
       ┌─────────────────┐                       ┌─────────────────┐
       │ Analytics / ML  │                       │ Media Security  │
       │ baseline        │                       │ filter + review │
       │ deviation       │                       └─────────────────┘
       │ risk model      │
       │ SHAP            │
       └───────┬─────────┘
               │
        ┌──────▼──────────┐
        │ Risk Orchestrator│
        │ tiers + routing  │
        └──────┬──────────┘
               │
       ┌───────┼───────────────────────┐
       ▼       ▼                       ▼
  Welfare   Counsellor             Commander
  Console   Console                Aggregate View

               ┌──────────────────────────────┐
               │ Pinecone / Approved Vector DB│
               │ Welfare-scheme RAG           │
               └──────────────┬───────────────┘
                              ▼
                     Approved Scheme Sources

               ┌──────────────────────────────┐
               │ HRMS Read-Only Gateway       │
               │ minimal pseudonymised feed   │
               └──────────────────────────────┘
```

## 3. Flutter Application

### 3.1 Suggested Structure

```text
lib/
  core/
    config/
    routing/
    security/
    networking/
    storage/
    localization/
    logging/
    errors/
  features/
    auth/
    officer_dashboard/
    checkins/
    assessments/
    crisis/
    risk/
    explanations/
    interventions/
    family/
    morale_vault/
    team_sessions/
    anonymous_reporting/
    welfare_assistant/
    bulletin/
    recognition/
    performance/
    consent/
    access_log/
    notifications/
  shared/
    widgets/
    models/
    services/
```

Use feature-oriented modularity rather than a monolithic screen tree.

### 3.2 State Management

Use a maintainable state-management approach selected during Phase 0/Phase 1. Do not add a package merely because it is popular. The choice must be documented.

### 3.3 Local Storage

The mobile app requires:
- Encrypted local store.
- Offline queue.
- Sync metadata.
- Pending check-ins.
- Approved cached content.
- Consent state.
- Notification preferences.

Sensitive data must never be stored in plaintext local files.

## 4. Backend Architecture

Use a service/API layer between Flutter and data providers.

```text
Flutter
  ↓
API Gateway / Backend
  ↓
┌───────────────────────────────────────────────────────┐
│ Auth Service                                           │
│ Consent Service                                        │
│ Officer Service                                        │
│ HR Integration Service                                 │
│ Assessment Service                                     │
│ Risk Service                                           │
│ Intervention Service                                   │
│ Crisis Service                                         │
│ Family Service                                         │
│ Media Service                                          │
│ Welfare RAG Service                                    │
│ Bulletin Service                                       │
│ Recognition Service                                    │
│ Reporting Service                                      │
│ Audit Service                                          │
│ Notification Service                                   │
│ ML Monitoring Service                                  │
└───────────────────────────────────────────────────────┘
  ↓
Database / Object Storage / Vector DB / ML infrastructure
```

The first implementation may be a modular monolith if that reduces complexity, provided the domain boundaries remain explicit.

## 5. Database Architecture

### 5.1 Identity Separation

Use separate logical stores/schemas for:
- Identity data.
- Pseudonymised analytics.
- Clinical/assessment data.
- Audit data.

The analytics layer should operate on pseudonymous identifiers wherever possible.

### 5.2 Core Tables

Minimum logical tables:

```text
officers
identities
roles
units
postings
deployments
leave_records
duty_records
shifts
transfers
training_records
check_ins
assessments
assessment_responses
stressors
biometrics
consent_records
risk_scores
risk_explanations
risk_events
interventions
counselling_sessions
crisis_events
safety_plans
followups
return_to_duty_plans
family_members
family_consents
morale_vault_media
media_security_reviews
family_training
team_sessions
session_attendance
anonymous_reports
performance_records
progress_updates
acr_context_notes
welfare_scheme_documents
welfare_scheme_chunks
welfare_scheme_sources
bulletin_events
event_interest_preferences
recognitions
testimonials
notifications
notification_preferences
audit_logs
break_glass_events
model_versions
model_predictions
model_monitoring_metrics
bias_audits
drift_metrics
retention_policies
deletion_requests
oversight_reviews
```

### 5.3 Provider Strategy

The project owner requested remote services such as:
- Supabase.
- Pinecone.
- Cloudinary.

These may be used for a prototype only if the owner explicitly approves them after reviewing the conflict with the source architecture requirement of on-prem/government-controlled deployment.

Use repository interfaces such as:

```text
DatabaseRepository
ObjectStorageRepository
VectorStoreRepository
NotificationRepository
IdentityProvider
AuditRepository
```

This prevents permanent vendor lock-in.

## 6. HRMS Integration

```text
Force HRMS
   │
   │ read-only
   ▼
API Gateway
   │
   ├── schema validation
   ├── field allowlist
   ├── pseudonymisation
   ├── rate limits
   ├── audit logging
   ▼
HR Integration Service
   ▼
Analytics Store
```

Never permit a welfare-system write-back into HRMS unless a separately approved requirement exists.

## 7. Personal Baseline Pipeline

```text
Officer data + HR data
          │
          ▼
Data validation
          │
          ▼
Normalisation
          │
          ├── New officer → cohort prior
          │
          ▼
4-6 week baseline
          │
          ▼
Individual baseline model
          │
          ▼
Rolling updates
```

Baseline signals include:
- Leave.
- Deployment.
- Duty hours.
- Night shifts.
- Consecutive duty.
- Transfers.
- Training.
- Sleep.
- Check-in scores.
- Clinical scores.
- Approved voluntary biometrics.

## 8. Deviation Detection

Use change-point detection:
- CUSUM and/or
- Bayesian online change-point detection.

The output should contain:
- Feature.
- Baseline value.
- Current value.
- Direction.
- Magnitude.
- Duration.
- Confidence/strength.
- Context.

## 9. Risk Model

Target:
**Elevated psychological risk within 30-60 days.**

Candidate labels:
- PHQ-9 >= 10.
- GAD-7 >= 10.
- PCL-5 >= 33.
- Counsellor-confirmed cases.
- Clinician-adjudicated samples.

Candidate model:
- LightGBM/XGBoost.

Required outputs:
```text
risk_score
risk_tier
model_version
prediction_window
top_features
explanation
calibration_metadata
```

No score may directly trigger punishment, ACR scoring, posting, promotion, or automatic off-duty status.

## 10. SHAP Explainability

Pipeline:

```text
Features
   ↓
Risk Model
   ↓
Prediction
   ↓
SHAP
   ↓
Feature ranking
   ↓
Plain-language explanation
   ↓
Officer / Welfare reviewer
```

The explanation generator must not invent reasons. It can only explain features actually present in the model input and approved explanation templates.

## 11. Risk Orchestration

```text
Risk Event
   ↓
Validate trigger
   ↓
Determine tier
   ├── Green → routine support
   ├── Yellow → welfare outreach
   ├── Orange → counsellor workflow
   └── Red → immediate human crisis workflow
```

Red events must bypass ordinary LLM interaction.

## 12. Crisis Architecture

```text
PHQ-9 item 9 / C-SSRS / direct disclosure
                 ↓
          Crisis Classifier
                 ↓
        Immediate Human Handoff
          ┌──────┴──────┐
          ▼             ▼
   Human Responder   Clinician
          │             │
          └──────┬──────┘
                 ▼
          Safety Planning
                 ↓
     Optional family contact
                 ↓
      Follow-up / return plan
```

LLM is never the crisis responder.

## 13. Family Architecture

Consent model:

```text
Officer
  │
  ├── select family member
  ├── select information/category
  ├── select purpose
  ├── set notification windows
  └── revoke
        │
        ▼
  Consent Service
        │
        ▼
Family Feature
```

Every share must have:
- Purpose.
- Scope.
- Recipient.
- Timestamp.
- Expiry/revocation state.

## 14. Morale Vault Media Pipeline

```text
Upload
  ↓
Virus/file validation
  ↓
Automated operational-security filter
  ↓
Risk classification
  ├── safe → available
  └── suspicious → human review
                         ↓
                    approve/reject
```

Detect:
- Location clues.
- Uniform/insignia.
- Operations references.

Never expose flagged media until approved.

## 15. RAG Welfare Assistant

```text
Approved official documents
        ↓
Ingestion
        ↓
OCR / parsing where necessary
        ↓
Chunking + metadata
        ↓
Embeddings
        ↓
Pinecone / approved vector DB
        ↓
Retriever
        ↓
Reranker
        ↓
LLM
        ↓
Answer + source citations
```

Rules:
- Only answer from approved corpus.
- Cite source.
- Do not invent entitlement.
- If evidence is absent, say it is unavailable.
- Current eligibility/amounts must be verified before production.
- Preserve document version/date.

## 16. LLM Architecture

LLM use is limited to approved non-crisis areas:
- Encouraging feedback.
- Welfare-scheme RAG.
- General support/navigation.

LLM must have:
- Approved prompts.
- Vetted knowledge.
- Output filtering.
- Sensitive-topic routing.
- Full logging.
- No diagnosis.
- No crisis response.
- No autonomous consequential action.

## 17. Bulletin and Recognition

Bulletin recommendation inputs:
- Officer location where authorised.
- Interests.
- Free-time preferences.
- Event metadata.

Recognition inputs:
- Approved achievements.
- Milestones.
- Leadership commendations.

Public recognition requires explicit consent and security review.

## 18. Anonymous Reporting

Use a technically separated submission path.

Do not store identity with the report by default.

If anti-abuse controls require metadata, the privacy model must be explicitly documented and approved rather than silently adding identification.

## 19. Team Session Scheduler

Inputs:
- Unit.
- Role.
- Shift.
- Common free time.
- Leave windows.

Never use stress score as a grouping key.

Output:
- Session.
- Facilitator.
- Attendance requirements.
- One-to-one alternative.

## 20. Access Control Matrix

| Role | Default access |
|---|---|
| Officer | Own data, explanations, support, access log |
| Welfare officer | Pseudonymised tiers and escalations |
| Counsellor | Full clinical detail when authorised |
| Commander | Aggregated unit insights and duty status |
| Family | Explicitly consented data only |
| Vigilance cell | Anonymous reports |
| Admin | Technical administration, not automatic clinical access |

Break-glass access must be:
- Explicit.
- Reason-coded.
- Logged.
- Reviewed.
- Visible in audit systems as required.

## 21. Privacy-Preserving Analytics

For aggregate commander views:
- Enforce minimum group size, e.g. 10.
- Use differential privacy where appropriate.
- Suppress small groups.
- Never expose individual stress ranking.
- Never sort named personnel by stress.

## 22. Security

Required:
- AES-256 at rest.
- TLS 1.3.
- Field-level encryption for clinical fields.
- HSM/KMS.
- MFA.
- RBAC/ABAC.
- Immutable logs.
- Break-glass logging.
- Secure secrets management.
- No credentials in Git.
- Environment separation.

## 23. Offline Sync

```text
Flutter local encrypted DB
        ↓
Pending operation queue
        ↓
Connectivity detected
        ↓
Authenticated sync
        ↓
Server validation
        ↓
Idempotent write
        ↓
Sync acknowledgement
```

Conflict strategy must be domain-specific. Never silently overwrite clinical/consent data.

## 24. Remote Services and Deployment Decision

The user requested maximum remote usage and named Supabase, Pinecone and Cloudinary. The source concept specifies on-prem/government-controlled infrastructure and no public cloud.

Therefore:

- Phase 0 must capture the approved deployment target.
- Do not deploy sensitive production data to public SaaS merely for convenience.
- Prototype-only remote services must be explicitly marked.
- All remote providers must be replaceable.
- If government deployment is required, create adapters for government-approved database, object storage, vector search, KMS and notification services.
- Cloudinary is suitable only if media policy permits external storage.
- Pinecone is suitable only if welfare-document and query-data policy permits external vector storage.
- Supabase is suitable only if database/identity policy permits external managed infrastructure.

## 25. Observability

Track:
- API health.
- Sync failures.
- Notification delivery.
- Crisis routing status.
- Model drift.
- Calibration.
- Bias metrics.
- Queue capacity.
- Storage failures.
- Audit-log integrity.

Do not log raw clinical answers, crisis content, family private messages, or media unnecessarily.

## 26. Failure Handling

No silent fallbacks.

When a dependency fails:
- Show a controlled user-facing state.
- Preserve data locally if safe.
- Queue for retry where appropriate.
- Notify authorised operators.
- Ask the owner before changing providers or behaviour.

Crisis routing must use a pre-approved redundant human pathway, not an invented substitute.

## 27. Architecture Acceptance

Before implementation is considered complete:
- All source requirements have traceable components.
- Every role has tested access boundaries.
- Crisis flows reach humans.
- Welfare-HR firewall is technically enforced.
- RAG answers are source-grounded.
- Model explanations are faithful to actual features.
- Offline mode works.
- Access logs work.
- Consent revocation works.
- Aggregate dashboards cannot expose small groups.
- No undocumented fallback has been introduced.
