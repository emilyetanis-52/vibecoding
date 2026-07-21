import { NextFunction, Request, Response } from "express";
import { config } from "./config";

export function requireSharedSecret(req: Request, res: Response, next: NextFunction) {
  const header = req.header("authorization") ?? "";
  const [scheme, token] = header.split(" ");

  if (scheme !== "Bearer" || token !== config.appSharedSecret) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  next();
}
