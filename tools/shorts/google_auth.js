// Google Cloud auth for the TTS calls.
//
// Two modes, in this order:
//   1. A service account JSON key  (GOOGLE_APPLICATION_CREDENTIALS=<path>)
//   2. A plain API key             (GOOGLE_TTS_API_KEY=<key>)
//
// The service account path signs a JWT and trades it for an access token, which
// is the standard flow — no extra dependency, node:crypto can do RS256. Tokens
// are cached in memory for the life of the process.
//
// Nothing in here ever logs the key material.

import './env.js';
import { existsSync, readFileSync } from 'node:fs';
import { createSign } from 'node:crypto';

const SCOPE = 'https://www.googleapis.com/auth/cloud-platform';

export function credentialsPath() {
  return process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim() || null;
}

export function apiKey() {
  return process.env.GOOGLE_TTS_API_KEY?.trim() || null;
}

export function authMode() {
  if (credentialsPath()) return 'service-account';
  if (apiKey()) return 'api-key';
  return null;
}

function loadCredentials() {
  const file = credentialsPath();
  if (!existsSync(file)) {
    throw new Error(
      `서비스 계정 키 파일을 찾을 수 없습니다:\n  ${file}\n` +
        '.env 의 GOOGLE_APPLICATION_CREDENTIALS 경로를 확인하세요.',
    );
  }

  let creds;
  try {
    creds = JSON.parse(readFileSync(file, 'utf8'));
  } catch {
    throw new Error(`서비스 계정 키 파일이 올바른 JSON 이 아닙니다:\n  ${file}`);
  }

  for (const field of ['client_email', 'private_key', 'token_uri']) {
    if (!creds[field]) {
      throw new Error(
        `서비스 계정 키에 "${field}" 가 없습니다. OAuth 클라이언트 ID 파일을 받으신 게 아닌지 확인하세요.\n  ${file}`,
      );
    }
  }
  return creds;
}

const base64url = (value) => Buffer.from(value).toString('base64url');

let cached = null; // { token, expiresAt }

async function fetchAccessToken() {
  const creds = loadCredentials();
  const now = Math.floor(Date.now() / 1000);

  const header = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claims = base64url(
    JSON.stringify({
      iss: creds.client_email,
      scope: SCOPE,
      aud: creds.token_uri,
      iat: now,
      exp: now + 3600,
    }),
  );
  const signature = base64url(
    createSign('RSA-SHA256').update(`${header}.${claims}`).sign(creds.private_key),
  );

  const response = await fetch(creds.token_uri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${header}.${claims}.${signature}`,
    }),
  });

  if (!response.ok) {
    const detail = await response.text();
    throw new Error(
      `액세스 토큰 발급 실패 (${response.status}). 키 파일이 유효한지, 서비스 계정이 삭제되지 않았는지 확인하세요.\n${detail.slice(0, 300)}`,
    );
  }

  const { access_token: token, expires_in: expiresIn } = await response.json();
  if (!token) throw new Error('토큰 응답에 access_token 이 없습니다.');

  cached = { token, expiresAt: now + (expiresIn ?? 3600) - 60 };
  return token;
}

async function accessToken() {
  if (cached && Math.floor(Date.now() / 1000) < cached.expiresAt) return cached.token;
  return fetchAccessToken();
}

/** fetch() against a Google API, with whichever credential is configured. */
export async function googleFetch(url, init = {}) {
  const mode = authMode();
  if (!mode) {
    throw new Error(
      'Google Cloud 인증 정보가 없습니다. .env 에 GOOGLE_APPLICATION_CREDENTIALS 또는 GOOGLE_TTS_API_KEY 를 설정하세요.\n' +
        '확인:  node setup_google_tts.js',
    );
  }

  if (mode === 'api-key') {
    const separator = url.includes('?') ? '&' : '?';
    return fetch(`${url}${separator}key=${encodeURIComponent(apiKey())}`, init);
  }

  return fetch(url, {
    ...init,
    headers: { ...init.headers, Authorization: `Bearer ${await accessToken()}` },
  });
}

/** Project id, used only for error messages. Never returns key material. */
export function projectHint() {
  if (authMode() !== 'service-account') return null;
  try {
    return JSON.parse(readFileSync(credentialsPath(), 'utf8')).project_id ?? null;
  } catch {
    return null;
  }
}
