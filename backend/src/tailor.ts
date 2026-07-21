import Anthropic from "@anthropic-ai/sdk";
import { config } from "./config";

const anthropic = new Anthropic({ apiKey: config.anthropicApiKey });

const SYSTEM_PROMPT = `You are an expert resume writer and career coach. You tailor an existing resume \
to a specific target job description without inventing experience the candidate doesn't have.

Rules you must follow:
- Never fabricate employers, titles, dates, degrees, certifications, or metrics that are not \
implied by the original resume.
- You MAY rephrase, reorder, and re-emphasize existing bullet points to mirror the language and \
priorities of the job description (including relevant keywords for applicant tracking systems).
- You MAY reorder sections or bullets so the most relevant experience appears first.
- Keep the same overall factual content: same jobs, same dates, same education.
- Output ONLY the final tailored resume as clean plain text, ready to paste into a document. \
Do not include commentary, explanations, or markdown code fences before or after it.`;

export interface TailorResult {
  tailoredResume: string;
}

export async function tailorResume(resumeText: string, jobDescription: string): Promise<TailorResult> {
  const message = await anthropic.messages.create({
    model: "claude-sonnet-5",
    max_tokens: 4096,
    system: SYSTEM_PROMPT,
    messages: [
      {
        role: "user",
        content: `CURRENT RESUME:\n"""\n${resumeText}\n"""\n\nTARGET JOB DESCRIPTION:\n"""\n${jobDescription}\n"""\n\nRewrite the resume tailored to this job.`,
      },
    ],
  });

  const textBlock = message.content.find((block) => block.type === "text");
  if (!textBlock || textBlock.type !== "text") {
    throw new Error("Claude did not return a text response");
  }

  return { tailoredResume: textBlock.text.trim() };
}
