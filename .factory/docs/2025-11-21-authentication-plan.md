# Authentication Implementation Plan (Rails 8, Tenant-Scoped)

## Purpose
Introduce secure, per-shop authentication without Devise, using Rails 8 primitives so staff users log in on their shop subdomain before accessing catalog, ordering, and preparation tools.

> **Model layer status**: ✅ Completed on 2025-11-22 00:11 UTC — credential columns, bcrypt wiring, fixtures, and unit tests are live.

## Guiding Principles
- **Tenant isolation first**: every auth decision happens inside an already-resolved `current_shop`; never mix credentials across shops.
- **User model owns credentials**: lean on `has_secure_password` with a dedicated concern for lock/ reset logic so we avoid extra identity tables until roles/SSO enter the picture.
- **Zero shared secrets**: normalize `email` (downcase/strip), require uniqueness on `[:shop_id, :email]`, and hash passwords with bcrypt (configurable cost per environment).
- **Defense in depth**: add account lockout, password reset tokens, audit timestamps, and strong session hygiene (CSRF, same-site cookies, signed ids).

## Data Model Changes
| Column | Type | Notes |
| --- | --- | --- |
| `password_digest` | string | Required by `has_secure_password`; NOT NULL once backfill completes. |
| `failed_attempts` | integer | Default 0; check constraint `>= 0`. |
| `locked_at` | datetime | Detect lock state; unlock via reset/admin. |
| `last_sign_in_at` | datetime | Audit trail per user. |
| `last_sign_in_ip` | inet/string | Optional, useful for audit alerts. |
| `reset_password_token` | string | Unique per user when active. |
| `reset_password_sent_at` | datetime | Enforce expiry (e.g., 30 minutes). |

Additional constraints/indexes:
- `add_index :users, [:shop_id, :email], unique: true` enforcing tenant uniqueness (case-insensitive via functional index if DB supports).
- `add_index :users, :reset_password_token, unique: true, where: "reset_password_token IS NOT NULL"`.
- `CHECK (char_length(password_digest) >= 60)` once all users migrated, ensuring presence of bcrypt hash.

## Application Components
1. **Model layer**
   - `User` includes new `Users::Credentials` concern that encapsulates `has_secure_password`, lock/unlock helpers, token generation, and normalization hooks.
   - Validations: password length (8-72), presence on create, confirmation optional; `email` presence + format.
2. **Session management**
   - `Shops::SessionsController` (HTML/Turbo) with `new/create/destroy` actions, scoped under subdomain constraint.
   - `Auth::Login` service: verifies credentials, increments `failed_attempts`, locks accounts at threshold (configurable, default 5), records `last_sign_in_at/ip` on success.
3. **Password reset**
   - `Shops::PasswordResetsController` with `new/create/edit/update`; no registration flows per requirement.
   - `Auth::GenerateResetToken` (assigns signed token, enqueues mail) and `Auth::ResetPassword` (validates token age, resets password, clears attempts + token).
   - Mailer: `UserMailer#password_reset` referencing shop branding + reset URL (subdomain aware).
4. **Session helpers**
   - `ApplicationController` adds `current_user`, `sign_in(user)`, `sign_out`, `require_authentication` before-actions for protected controllers.
   - Store `user_id` in signed encrypted cookies keyed per shop to prevent cross-tenant leaks.

## Security Considerations
- **Password hashing**: `has_secure_password` (bcrypt) with environment-specific cost; add smoke test so CI fails if bcrypt missing.
- **Lockout & alerts**: after `MAX_FAILED_ATTEMPTS`, set `locked_at` and email staff instructions to reset; optional unlock job for admins.
- **Token management**: generate reset tokens via `has_secure_token`, store digest if we need one-way comparison, and expire tokens after 30 minutes.
- **Session hardening**: rotate session id on login, enable `SameSite=Lax` cookies, enforce TLS-only cookies, and log IP/user agent for anomaly detection.

## Implementation Phases
1. **Foundation (Week 1) — ✅ Completed 2025-11-22**
   - Ship migration adding credential columns + indexes; backfill fixtures/seeds with generated passwords.
   - Update `User` model with concern, validations, and normalization tests.
2. **Session Flow (Week 2) — ✅ Completed 2025-11-22**
   - Build Sessions controller/views, `Auth::Login` service, and Turbo-friendly form with error states.
   - Wire `require_authentication` across existing shop dashboards; ensure friendly redirect back to login.
3. **Password Reset & Lockout (Week 3)**
   - Implement reset controllers/services, mailer, and UI forms; integrate lockout notifications and unlock path.
   - Add background job to purge expired tokens nightly.
4. **Hardening & Observability (Week 4)**
   - Add audit logging (structured events for login success/failure), metrics (failed logins per shop), and basic rate limiting (Rack::Attack or Solid Rack).
   - Final QA: system tests for login/logout/reset, throttling tests, penetration checklist.
5. **Localization Cleanup (Week 5)**
   - Extract all user-facing authentication messages (flash alerts/notices, validation errors, mailer copy) into locale files for translation.
   - Ensure controllers/services reference I18n keys and add tests covering missing translations in CI.

## Testing Strategy
- **Model tests**: password validation, lockout transitions, token generation/expiry, normalization.
- **Service tests**: `Auth::Login` (success/failure paths), `Auth::GenerateResetToken`, `Auth::ResetPassword`.
- **Request tests**: Sessions + PasswordResets controllers ensuring tenant scoping and redirects.
- **System tests**: full login/logout + reset path using Turbo.
- **Security tests**: rack attack throttling specs, regression test to ensure locked users cannot authenticate.

## Rollout Checklist
- Rotate env secrets to include `AUTH_MAX_FAILED_ATTEMPTS`, `AUTH_RESET_TOKEN_EXPIRY_MINUTES`.
- Backfill passwords for existing staff users via rake task emailing unique reset links.
- Update runbooks/support docs on unlocking accounts and handling password requests.
- Coordinate staged rollout per shop to verify tenant-specific login pages before forcing auth globally.
