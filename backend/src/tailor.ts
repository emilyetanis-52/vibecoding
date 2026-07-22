import Anthropic from "@anthropic-ai/sdk";
import { config } from "./config";

const anthropic = new Anthropic({ apiKey: config.anthropicApiKey });

const SYSTEM_PROMPT = `You are an expert resume writer and career coach. You tailor an existing resume \
to a specific target job description without inventing experience the candidate doesn't have, and you \
assess how well the resume aligns to the role.

Rules you must follow:
- Never fabricate employers, titles, dates, degrees, certifications, or metrics that are not \
implied by the original resume.
- You MAY rephrase, reorder, and re-emphasize existing bullet points to mirror the language and \
priorities of the job description (including relevant keywords for applicant tracking systems).
- You MAY reorder sections or bullets so the most relevant experience appears first.
- Keep the same overall factual content: same jobs, same dates, same education.
- Be direct and specific in "matched" and "gaps" -- name the actual requirement and the actual \
resume detail, no vague filler ("great fit", "strong candidate").
- "gaps" should call out real discrepancies (e.g. the posting asks for more years of experience \
than the resume shows, a required tool/certification the resume doesn't mention) -- not things \
that were fixed by tailoring.
- alignmentScore is your honest 0-100 estimate of how well the CANDIDATE'S UNDERLYING EXPERIENCE \
(not just wording) matches the role's requirements.

Call the submit_tailored_resume tool exactly once with your result. Do not respond with plain text.`;

const RESULT_TOOL = {
  name: "submit_tailored_resume",
  description: "Submit the tailored resume along with an alignment assessment.",
  input_schema: {
    type: "object" as const,
    properties: {
      alignmentScore: {
        type: "integer",
        minimum: 0,
        maximum: 100,
        description: "0-100 estimate of how well the candidate's actual experience matches the role.",
      },
      matched: {
        type: "array",
        items: {
          type: "object",
          properties: {
            title: { type: "string", description: "Short label, e.g. a requirement from the posting." },
            detail: { type: "string", description: "One sentence on how the resume backs it up." },
          },
          required: ["title", "detail"],
        },
      },
      gaps: {
        type: "array",
        items: {
          type: "object",
          properties: {
            title: { type: "string", description: "Short label for the discrepancy." },
            detail: { type: "string", description: "One sentence describing the gap." },
          },
          required: ["title", "detail"],
        },
      },
      tailoredResume: {
        type: "string",
        description: "The full tailored resume as clean plain text, ready to paste into a document.",
      },
    },
    required: ["alignmentScore", "matched", "gaps", "tailoredResume"],
  },
};

export interface MatchItem {
  title: string;
  detail: string;
}

export interface TailorResult {
  alignmentScore: number;
  matched: MatchItem[];
  gaps: MatchItem[];
  tailoredResume: string;
}

export async function tailorResume(resumeText: string, jobDescription: string): Promise<TailorResult> {
  const message = await anthropic.messages.create({
    model: "claude-sonnet-5",
    max_tokens: 4096,
    system: SYSTEM_PROMPT,
    tools: [RESULT_TOOL],
    tool_choice: { type: "tool", name: RESULT_TOOL.name },
    messages: [
      {
        role: "user",
        content: `CURRENT RESUME:\n"""\n${resumeText}\n"""\n\nTARGET JOB DESCRIPTION:\n"""\n${jobDescription}\n"""\n\nTailor the resume to this job and assess alignment.`,
      },
    ],
  });

  const toolUse = message.content.find(
    (block): block is Anthropic.ToolUseBlock => block.type === "tool_use" && block.name === RESULT_TOOL.name
  );
  if (!toolUse) {
    throw new Error("Claude did not return a tailored resume");
  }

  const result = toolUse.input as TailorResult;
  return {
    alignmentScore: Math.max(0, Math.min(100, Math.round(result.alignmentScore))),
    matched: result.matched ?? [],
    gaps: result.gaps ?? [],
    tailoredResume: result.tailoredResume.trim(),
  };
}
