# Plan: User Authentication

Track: `feat-auth`
Created: 2025-01-03
Status: In Progress

---

## Phase 1: Setup

- [x] Install Clerk dependencies <!-- commit: abc1234 -->
- [x] Configure environment variables <!-- commit: def5678 -->
- [ ] Create Clerk application <!-- commit: -->
- [ ] Setup middleware for auth <!-- commit: -->

## Phase 2: Core Auth

- [ ] Add ClerkProvider to app <!-- commit: -->
- [ ] Create sign-in page <!-- commit: -->
- [ ] Create sign-up page <!-- commit: -->
- [ ] Add sign-out button <!-- commit: -->

## Phase 3: Protected Routes

- [ ] Create auth middleware <!-- commit: -->
- [ ] Protect /dashboard route <!-- commit: -->
- [ ] Protect API routes <!-- commit: -->
- [ ] Add redirect after login <!-- commit: -->

## Phase 4: User Profile

- [ ] Create profile page <!-- commit: -->
- [ ] Display user info <!-- commit: -->
- [ ] Add avatar upload <!-- commit: -->

## Phase 5: Testing

- [ ] Test registration flow <!-- commit: -->
- [ ] Test login/logout <!-- commit: -->
- [ ] Test protected routes <!-- commit: -->
- [ ] Test session persistence <!-- commit: -->

---

## Notes

- Remember to add Clerk webhook for user sync
- Google OAuth requires callback URL setup
