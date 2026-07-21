import cors from "cors";
import express from "express";
import rateLimit from "express-rate-limit";
import { z } from "zod";
import { config } from "./config";
import { requireSharedSecret } from "./auth";
import { tailorResume } from "./tailor";

const app = express();

app.use(express.json({ limit: "1mb" }));
app.use(
  cors({
    origin: config.allowedOrigins.length > 0 ? config.allowedOrigins : false,
  })
);

const tailorRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

const tailorRequestSchema = z.object({
  resumeText: z.string().trim().min(1, "resumeText is required").max(20000),
  jobDescription: z.string().trim().min(1, "jobDescription is required").max(20000),
});

app.get("/healthz", (_req, res) => {
  res.json({ status: "ok" });
});

app.post("/v1/tailor", requireSharedSecret, tailorRateLimit, async (req, res) => {
  const parsed = tailorRequestSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.issues[0]?.message ?? "Invalid request" });
    return;
  }

  try {
    const result = await tailorResume(parsed.data.resumeText, parsed.data.jobDescription);
    res.json(result);
  } catch (error) {
    console.error("tailorResume failed", error);
    res.status(502).json({ error: "Failed to tailor resume. Please try again." });
  }
});

app.listen(config.port, () => {
  console.log(`Tailor Resume backend listening on port ${config.port}`);
});
