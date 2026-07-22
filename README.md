# Align

*Everything aligned, except the one thing that makes you stand out.*

An iOS app that rewrites a resume to fit a specific job description, using
the Claude API. Upload your resume once, paste a job posting, and get a
tailored version out — same facts, reordered and reworded to match what the
job is actually asking for, plus an honest alignment score and a list of
what matched vs. what's worth double-checking.

## Flow

1. **Add your resume** — upload a PDF/DOCX/TXT once; it's extracted to text
   and stored on-device for every future tailor.
2. **Paste the job description** — full posting, the more detail the better.
3. **Aligning** — the backend calls Claude to tailor the resume and score it.
4. **Results** — an alignment %, what matched, and gaps worth reviewing
   (e.g. "posting wants 6+ years, resume shows 5") before you view the full
   tailored resume.
5. **Paywall** — free tier is 1 tailored resume/month; Align Pro
   ($9.99/mo) is unlimited. See "Subscriptions" below.

## Project layout

- `ios/Align.swiftpm` — the iOS app (SwiftUI, Swift Playgrounds App
  project format).
- `backend/` — small Express/TypeScript API that calls the Claude API on the
  app's behalf. See `backend/README.md`.

## Why a backend at all?

The Anthropic API key can't ship inside the app bundle — anyone could
extract it and run up your bill. The app calls your backend, and the
backend calls Claude. It's also where PDF/DOCX text extraction happens
(`pdf-parse` / `mammoth`), so the app only ever ships plain text.

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

## Subscriptions (StoreKit)

The paywall UI and purchase code (`StoreKitService.swift`, StoreKit 2) are
wired up, but the actual product — `com.emilytanis.align.pro.monthly`,
$9.99/mo, referenced in `PaywallView.swift` — needs to be created for real
in **App Store Connect → Monetization → Subscriptions** before purchases
work in production; that's an account-holder action I can't do from here.

For testing in the simulator right now, without any App Store Connect
setup: in Xcode, **Product → Scheme → Edit Scheme → Run → Options →
StoreKit Configuration**, select `Align.storekit`. That file already
defines the same product locally so you can exercise the full purchase
flow.

Free-tier usage (1 tailor/month) is tracked on-device only (`UsageTracker.swift`)
— there's no server-side enforcement yet, so it resets if the app is
reinstalled. Fine for now, not fine once this has real paying users.

## Current scope

Resume upload (PDF/DOCX/TXT, stored locally) → job description → aligning →
score + matched/gaps → tailored resume → copy/share, with a working local
paywall gate. Natural next steps once this feels good:

- Sign in + saved history of past tailors (currently nothing is saved
  except the one base resume)
- Server-side enforcement of the free/paid tier (right now a reinstall
  resets the free quota)
- Real per-user auth/quotas on the backend (the current shared-secret model
  just keeps non-app-users off your Claude bill, it isn't per-user auth)
- App Store metadata, marketing screenshots, privacy nutrition label (the
  app sends resume text to your backend/Claude, so the label needs to
  disclose that)
- A brand font (Söhne/General Sans/Inter) — currently using the system
  font since no font file has been supplied/licensed for embedding
