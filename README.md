# Align

An iOS app that rewrites a resume to fit a specific job description, using
the Claude API. Paste your current resume and a job posting in, get a
tailored version out — same facts, reordered and reworded to match what the
job is actually asking for.

## Project layout

- `ios/Align.swiftpm` — the iOS app (SwiftUI, Swift Playgrounds App
  project format).
- `backend/` — small Express/TypeScript API that calls the Claude API on the
  app's behalf. See `backend/README.md`.

## Why a backend at all?

The Anthropic API key can't ship inside the app bundle — anyone could
extract it and run up your bill. The app calls your backend, and the
backend calls Claude.

## Running it

1. **Backend**: follow `backend/README.md` to run it locally or deploy it
   somewhere public (Render/Fly/Railway all work with the free tier).
2. **iOS app**: on a Mac, open `ios/Align.swiftpm` in Xcode 15+ (or
   Swift Playgrounds on iPad/Mac). Run it on a simulator or device, tap the
   gear icon, and set the server URL + shared secret to match your backend.

This container can write and typecheck the backend, but building/running the
iOS app requires Xcode on macOS — that part can't be done from here. The
`.swiftpm` format was chosen specifically because it's plain text (unlike a
hand-authored `.xcodeproj`, which is a fragile binary-plist-adjacent format)
and Xcode opens/builds/archives it natively, including submitting to
TestFlight/App Store via **Product → Archive**.

## Current scope (MVP)

Paste resume + paste job description → tailored resume → copy/share. No
accounts, no payment, no resume file upload (PDF/DOCX) yet, no history of
past tailored resumes. Natural next steps once this loop feels good:

- Resume file import (PDF/DOCX) instead of paste-only
- Sign in + saved history of past tailors
- Real per-user auth/quotas on the backend (the current shared-secret model
  is a placeholder, not production auth)
- App Store metadata, icon, privacy nutrition label (the app sends resume
  text to your backend/Claude, so the privacy label needs to disclose that)
