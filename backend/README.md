# Tailor Resume — Backend

Small Express/TypeScript API that takes a resume + a target job description and
returns a tailored resume, using the Claude API. This exists so the Anthropic
API key never ships inside the iOS app.

## Setup

```bash
cd backend
cp .env.example .env      # then fill in ANTHROPIC_API_KEY and APP_SHARED_SECRET
npm install
npm run dev                # http://localhost:3000
```

`APP_SHARED_SECRET` is a random string you generate (`openssl rand -hex 32`).
The iOS app sends it as `Authorization: Bearer <secret>` on every request —
it just keeps random people who don't have the app off your Claude bill. It
is **not** per-user authentication; add real auth (e.g. Sign in with Apple +
per-user API keys/quotas) before this handles paying users at scale.

## API

`POST /v1/tailor`

Headers: `Authorization: Bearer <APP_SHARED_SECRET>`, `Content-Type: application/json`

Body:
```json
{ "resumeText": "...", "jobDescription": "..." }
```

Response:
```json
{ "tailoredResume": "..." }
```

Rate limited to 20 requests/hour per IP by default (`src/index.ts`).

## Deploying

Any Node host works (Render, Fly.io, Railway, an EC2 box, etc.):

```bash
npm run build
npm start
```

Set `ANTHROPIC_API_KEY`, `APP_SHARED_SECRET`, and `PORT` as environment
variables on the host. Once deployed, put the public HTTPS URL into the iOS
app's Settings screen (or hardcode it as the default in `AppSettings.swift`).
