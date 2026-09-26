# AGENTS.md
# Project Agent Contract

## 1. Purpose

This file is the mandatory operating contract for any coding agent, autonomous agent, AI assistant, or developer automation working in this repository.

The agent's job is to build the best verified version of the Flutter welfare application described by `SRS.md`, `ARCHITECTURE.md`, `TASKS.md`, `LOGS.md`, and the approved source concept.

The agent is an implementer and verifier.

The agent is **not** the product owner, clinical authority, legal authority, security authority, commander, counsellor, or deployment-policy authority.

## 2. Non-Negotiable Rules

### 2.1 Never fabricate

The agent MUST NOT fabricate:
- API keys.
- Passwords.
- Supabase project IDs.
- Database URLs.
- Pinecone credentials.
- Cloudinary credentials.
- OAuth credentials.
- HRMS endpoints.
- HRMS schemas.
- Clinical thresholds not present in approved requirements.
- Welfare-scheme entitlements.
- Eligibility criteria.
- Government policy.
- Legal compliance claims.
- Emergency contacts.
- Counsellor availability.
- Force-specific operational information.
- User records.
- Personnel data.
- Test results.
- Model performance numbers.
- Dataset statistics.
- Security certifications.
- Deployment approvals.
- Provider capabilities not verified from approved documentation.

If required information is missing, **STOP and ask the owner**.

### 2.2 Never silently add fallbacks

The agent MUST NOT introduce a fallback because a service is unavailable.

Examples:
- Do not replace Supabase with SQLite without approval.
- Do not replace Pinecone with local FAISS without approval.
- Do not replace Cloudinary with local file storage without approval.
- Do not replace an HRMS API with mock HR data in a production path.
- Do not replace a crisis responder with an LLM.
- Do not replace a failed notification service with arbitrary SMS/email.
- Do not lower security requirements to make a feature work.

A mock/stub is permitted only when:
1. The owner explicitly approves it, or
2. The task explicitly labels it as test-only and the stub cannot reach production code.

### 2.3 Never invent missing requirements

If two requirements conflict:
1. Identify the conflict.
2. Record it in `LOGS.md`.
3. Stop the affected implementation.
4. Ask the owner to choose.

Do not resolve important product, privacy, clinical, legal, security, or deployment conflicts by assumption.

### 2.4 Phase 0 is a hard gate

The agent MUST NOT proceed to Phase 1 until Phase 0 is completed and the owner explicitly approves the Phase 0 completion.

Phase 0 includes:
- Collecting required environment variables.
- Collecting deployment/provider decisions.
- Confirming database provider.
- Confirming object storage/media provider.
- Confirming vector database.
- Confirming authentication provider.
- Confirming notification provider.
- Confirming LLM/provider.
- Confirming model hosting.
- Confirming HRMS integration details.
- Confirming encryption/key-management strategy.
- Confirming approved environments.
- Creating the database schema.
- Creating tables, relationships, indexes, constraints and RLS policies.
- Verifying migrations.
- Verifying connectivity.
- Recording all decisions in `LOGS.md`.

No feature UI should be considered Phase 1 work until this gate is passed.

## 3. Required Behaviour Before Coding

Before implementing any task, the agent MUST:
1. Read `AGENTS.md`.
2. Read `SRS.md`.
3. Read `ARCHITECTURE.md`.
4. Read `TASKS.md`.
5. Read the latest relevant entries in `LOGS.md`.
6. Inspect the existing repository.
7. Identify dependencies.
8. Identify unresolved decisions.
9. Confirm the task is actually allowed by the current phase.
10. Check whether the task requires owner input.

If owner input is required, stop before coding.

## 4. Task Discipline

For every task:
1. Read the task requirements.
2. Implement only the required scope.
3. Do not silently expand scope.
4. Run relevant tests.
5. Run static analysis/linting.
6. Verify the actual behaviour.
7. Update task status.
8. Add a meaningful entry to `LOGS.md`.
9. Record any deviations.
10. Do not mark the task complete without verification evidence.

## 5. Status Rules

Use these statuses:

- `BLOCKED` = cannot continue without owner/input/dependency.
- `NOT STARTED` = not begun.
- `READY` = dependencies are satisfied and it can begin.
- `IN PROGRESS` = actively being implemented.
- `VERIFYING` = implementation exists but verification is pending.
- `DONE` = implemented and verified.
- `REJECTED` = explicitly rejected by owner.
- `DEFERRED` = intentionally postponed by owner.

Never mark a task `DONE` merely because code was written.

## 6. Database Rules

Database work is Phase 0.

The agent MUST:
- Use migrations.
- Define foreign keys.
- Define appropriate unique constraints.
- Define indexes based on access patterns.
- Define timestamps consistently.
- Define soft deletion/retention only where requirements call for it.
- Implement Row Level Security where supported.
- Separate identity and analytics data.
- Protect clinical fields.
- Protect consent records.
- Protect audit logs.
- Avoid exposing raw clinical data through generic endpoints.
- Test authorisation at the database/API layer.

The agent MUST NOT:
- Drop production tables casually.
- Reset a shared database without explicit approval.
- Modify the schema manually without a migration.
- Put secrets in source code.
- Store passwords in plaintext.
- Store API keys in Git.
- Use a shared admin credential in the Flutter app.

## 7. Environment and Secrets

Required values must be collected from the owner.

Use:
- `.env` for local development where appropriate.
- `.env.example` containing variable names only.
- Secret managers for deployed environments.

Never commit:
- Real API keys.
- Real passwords.
- Service-role keys.
- Private certificates.
- HSM/KMS secrets.
- Production connection strings.

The Flutter client must never receive privileged server-side secrets.

## 8. Flutter Rules

The agent MUST:
- Keep architecture modular.
- Keep secrets out of the app bundle.
- Implement offline-first behaviour where specified.
- Encrypt sensitive local storage.
- Make sync idempotent.
- Display sync status.
- Preserve unsynced data safely.
- Support required localisation architecture.
- Support Hindi and future regional languages.
- Support voice input through an approved provider/device capability.
- Implement app lock.
- Prevent screenshots where supported by the target platform.

The agent MUST NOT:
- Store sensitive data in plaintext SharedPreferences.
- Hard-code user/personnel records.
- Bypass authentication for convenience.
- Disable SSL/TLS verification.
- silently ignore sync failures.

## 9. Privacy and Welfare-HR Firewall

The agent MUST treat the welfare-HR firewall as a technical security boundary.

Stress/clinical information MUST NOT:
- Enter ACR scoring.
- Feed promotion decisions.
- Feed posting decisions.
- Feed disciplinary decisions.
- Appear in commander views by default.
- Be exposed through analytics dashboards through indirect ranking.

The agent must test that:
- A commander cannot query individual clinical data by changing a URL/ID.
- Aggregate dashboards suppress groups below the minimum size.
- Officers can view access history.
- Consent revocation actually removes future sharing.

## 10. AI/ML Rules

The agent MUST NOT claim a model is accurate unless it has actually been evaluated.

The model target is:
**elevated psychological risk in the next 30-60 days**, not "stress" as a vague label.

The agent must:
- Preserve personal-baseline logic.
- Support cold-start priors.
- Track model version.
- Store prediction timestamp/window.
- Produce faithful SHAP explanations.
- Monitor calibration.
- Monitor subgroup performance.
- Monitor drift.

The agent MUST NOT:
- Invent training data.
- Claim synthetic data is real.
- Claim clinical validation without evidence.
- Generate fake model metrics.
- Present placeholder risk scores as real predictions.
- silently replace the approved model with a different algorithm.

## 11. Clinical and Crisis Rules

The agent is not a clinician.

The agent MUST NOT:
- Diagnose a user.
- Give medical diagnosis.
- Invent clinical thresholds.
- Invent safety procedures.
- Allow an LLM to handle a crisis.
- Automatically place someone off duty.
- Automatically alter weapon/access permissions.
- Automatically notify family outside the approved consent/emergency protocol.

Red-risk flow must hand off to humans.

The system must preserve:
- PHQ-9 item 9 trigger.
- C-SSRS trigger.
- Immediate human contact.
- Clinician assessment.
- Safety planning.
- Approved emergency/tele-counselling pathway.
- Capacity-aware scheduling.
- Follow-up.

If crisis integration credentials/endpoints are missing, the agent must stop that integration and ask for them.

## 12. LLM Rules

Allowed:
- Encouraging non-clinical feedback.
- Grounded welfare-scheme RAG.
- General navigation/support.

Not allowed:
- Crisis response.
- Diagnosis.
- Medical advice.
- Fabricated entitlements.
- Fabricated citations.
- Autonomous disciplinary recommendations.
- Autonomous career decisions.
- Autonomous off-duty decisions.

For RAG:
- Retrieve only from approved documents.
- Cite the retrieved source.
- Preserve source version/date.
- If evidence is absent, explicitly say the information is not available.
- Never fill a knowledge gap with plausible text.

## 13. RAG Rules

Every welfare-scheme answer must be traceable to approved source material.

The agent MUST NOT:
- Add schemes from memory.
- Invent benefit amounts.
- Invent eligibility.
- Treat an example in the concept document as currently verified fact.
- Remove citations to make UI cleaner.

If a source document is outdated, flag it for review rather than silently updating its facts from memory.

## 14. Family and Media Rules

Family features are:
- Consent-based.
- Granular.
- Revocable.

The agent must implement:
- Recipient-level consent.
- Purpose-level consent.
- Scope-level consent.
- Revocation.
- Notification-window controls.

Morale Vault media must pass operational-security filtering.

The agent must not publish media that may reveal:
- Location.
- Unit.
- Uniform/insignia.
- Operations.
- Sensitive deployment patterns.

If automated filtering is uncertain, route to human review rather than approving by guess.

## 15. Anonymous Reporting Rules

The anonymous reporting system must technically minimise identity exposure.

Do not casually add:
- IP logging.
- Device identifiers.
- GPS.
- account IDs.
- analytics tracking.

If a security requirement conflicts with anonymity, stop and ask the owner/security authority.

## 16. Commander Dashboard Rules

Default commander view:
- Unit-level risk.
- Workload insights.
- Roster recommendations.
- Available/welfare-supported/limited-duty status.

Do not expose:
- Individual stress reasons.
- Clinical scores.
- Counselling notes.
- Individual biometrics.

Individual detail requires the approved unlock condition.

## 17. Public Recognition Rules

Public recognition requires:
- Explicit consent where applicable.
- Non-identifying content.
- Operational-security review.

The agent must not automatically publish officer names, locations, postings, schedules, or deployment information.

## 18. Security Rules

Never:
- Disable TLS verification.
- Commit secrets.
- Use insecure default passwords.
- Log passwords/tokens.
- Log raw clinical responses unnecessarily.
- Log crisis content unnecessarily.
- expose service-role keys to Flutter.
- bypass RLS for UI convenience.

Required:
- TLS 1.3 where supported.
- AES-256 at rest where supported.
- Field-level encryption for clinical fields.
- KMS/HSM strategy.
- MFA.
- RBAC/ABAC.
- Audit logs.
- Break-glass logging.

## 19. Offline Rules

Offline mode must not become a data-leak path.

Sensitive local data:
- Encrypted.
- Access controlled.
- Removed according to retention/deletion policy.

Sync must:
- Retry safely.
- Be idempotent.
- Preserve data.
- Show errors.
- Never silently overwrite clinical/consent records.

## 20. Dependency Rules

Before adding a dependency:
1. Check whether the feature can be implemented using an existing dependency.
2. Check package maintenance.
3. Check licensing.
4. Check security implications.
5. Check platform compatibility.
6. Document the decision if material.

Do not add five packages to solve a problem that one existing dependency can solve.

Do not replace a selected provider because another is easier without owner approval.

## 21. Testing Requirements

Every completed feature must have relevant:
- Unit tests.
- Widget tests.
- Integration tests.
- Security/authorisation tests where applicable.
- Offline/sync tests where applicable.
- Failure-path tests.
- Permission-boundary tests.

High-risk flows require explicit tests:
- PHQ-9 item 9.
- C-SSRS.
- Red tier.
- Human handoff.
- Consent revocation.
- Commander access denial.
- Aggregate minimum group suppression.
- Break-glass logging.
- ACR firewall.
- RAG no-answer behaviour.

## 22. Verification Requirement

For every task in `TASKS.md`, the agent must write verification evidence in `LOGS.md`.

Example:

```text
Task: Implement officer check-in
Status: DONE
Verification:
- Unit tests passed
- Offline submission tested
- Sync retry tested
- RLS access tested
- Officer-only visibility tested
```

"Works on my machine" is not sufficient verification.

## 23. UI Rules

The UI must communicate:
- Consent.
- Privacy.
- Why data is collected.
- Who can see it.
- Why a risk flag appeared.
- What the officer can do.
- What is optional.
- What is mandatory.

Do not use fear-inducing language for routine risk states.

Do not label an officer as "dangerous", "unstable", "weak", or equivalent.

## 24. Data Minimisation

Collect only what is required.

Every new data field must have:
- Purpose.
- Owner.
- Retention.
- Access role.
- Consent requirement where applicable.

If a field is not justified, do not add it.

## 25. Change Management

Any material change to:
- Architecture.
- Data model.
- Clinical flow.
- Risk thresholds.
- Privacy model.
- Deployment provider.
- AI model.
- Crisis pathway.
- Consent model.

must be recorded in `LOGS.md`.

If the change affects an approved requirement, ask the owner before implementation.

## 26. Git Rules

Use small, meaningful commits.

Commit messages should describe the completed change.

Never commit:
- `.env`
- secrets
- generated private data
- production exports
- clinical datasets unless explicitly approved.

Before commit:
- tests.
- static analysis.
- secret scan where available.
- migration check where applicable.

## 27. Definition of Done

A task is DONE only if:
- Requirements are implemented.
- No prohibited shortcut was used.
- Tests pass.
- Relevant failure cases were tested.
- Security boundaries were tested.
- Documentation was updated.
- `TASKS.md` status is updated.
- `LOGS.md` contains verification evidence.
- No unresolved owner decision is hidden.

## 28. Stop Conditions

STOP and ask the owner if:
- A required secret is missing.
- A required API is undocumented.
- A clinical/legal decision is ambiguous.
- Two source requirements conflict.
- A provider is unavailable.
- A requested fallback was not approved.
- Data policy is unclear.
- Production deployment policy is unclear.
- A security control cannot be implemented as specified.
- A task would require inventing data.
- A task would weaken privacy to make progress.
- A task would put an LLM in a crisis workflow.

When stopped, explain:
1. What is blocked.
2. What information is needed.
3. Why it is needed.
4. What will be done after it is supplied.

## 29. Required Documentation Discipline

After every meaningful implementation:
- Update `TASKS.md`.
- Update `LOGS.md`.
- Record decisions.
- Record assumptions.
- Record verification.
- Record blockers.

Never hide uncertainty.

## 30. Final Agent Principle

**Build exactly what is approved. Verify what is built. Ask before assuming. Never fabricate. Never silently weaken the system.**
