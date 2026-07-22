import { PDFParse } from "pdf-parse";
import mammoth from "mammoth";

export class UnsupportedFileTypeError extends Error {}

const DOCX_MIME_TYPES = new Set([
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
]);

export async function extractResumeText(buffer: Buffer, mimeType: string, filename: string): Promise<string> {
  const lowerName = filename.toLowerCase();

  if (mimeType === "application/pdf" || lowerName.endsWith(".pdf")) {
    const parser = new PDFParse({ data: buffer });
    const result = await parser.getText();
    return result.text.trim();
  }

  if (DOCX_MIME_TYPES.has(mimeType) || lowerName.endsWith(".docx")) {
    const result = await mammoth.extractRawText({ buffer });
    return result.value.trim();
  }

  if (mimeType === "text/plain" || lowerName.endsWith(".txt")) {
    return buffer.toString("utf-8").trim();
  }

  throw new UnsupportedFileTypeError(`Unsupported file type: ${mimeType || lowerName}`);
}
