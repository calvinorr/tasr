# Spec: User Authentication

## Objective

Implement user authentication so that users can create accounts, log in, and access protected features.

## Context

Currently the app has no authentication. All features are public. We need to add:
- User registration
- Login/logout
- Session persistence
- Protected routes

## Approach

Use Clerk for authentication because:
1. Easy integration with Next.js
2. Built-in UI components
3. Handles session management
4. Social login support

## Scope

### In Scope
- Email/password authentication
- Google OAuth
- Protected API routes
- User profile page

### Out of Scope
- Role-based permissions (future track)
- Admin panel (future track)
- Two-factor authentication (future track)

## Success Criteria

1. Users can register with email/password
2. Users can log in with Google
3. Protected routes redirect to login
4. Session persists across page refreshes
5. Logout clears session

## Dependencies

- Clerk account setup
- Environment variables configured
- Next.js middleware

## Risks

- Clerk free tier limits (1000 MAU)
- OAuth callback configuration complexity
