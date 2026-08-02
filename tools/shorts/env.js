// Loads tools/shorts/.env into process.env.
//
// Setting a Windows environment variable means getting PowerShell-only syntax
// right in whatever shell happens to be open, which is a needless place to lose
// half an hour. A plain key=value file edited in Notepad works everywhere.
//
// Real environment variables always win, so CI or a shell export still
// overrides the file.

import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
export const envFile = path.join(here, '.env');

if (existsSync(envFile)) {
  for (const rawLine of readFileSync(envFile, 'utf8').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;

    const eq = line.indexOf('=');
    if (eq < 0) continue;

    const name = line.slice(0, eq).trim();
    let value = line.slice(eq + 1).trim();
    // Tolerate quotes people add out of habit.
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (name && value && !process.env[name]) process.env[name] = value;
  }
}
