const FALLBACK_API_URL = 'http://localhost:5000';

function normalizeBaseUrl(value) {
  return (value || FALLBACK_API_URL).replace(/\/+$/, '');
}

const publicApiBaseUrl = normalizeBaseUrl(process.env.NEXT_PUBLIC_API_URL);
const internalApiBaseUrl = normalizeBaseUrl(process.env.INTERNAL_API_URL || publicApiBaseUrl);
const publicSocketBaseUrl = normalizeBaseUrl(process.env.NEXT_PUBLIC_SOCKET_URL || publicApiBaseUrl);

export function apiUrl(path) {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  const baseUrl = typeof window === 'undefined' ? internalApiBaseUrl : publicApiBaseUrl;

  return `${baseUrl}${normalizedPath}`;
}

export const socketUrl = publicSocketBaseUrl;
