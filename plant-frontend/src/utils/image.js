const defaultPlantSvg = `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#e9f7ef"/>
      <stop offset="100%" stop-color="#c7ead3"/>
    </linearGradient>
    <linearGradient id="leaf" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#5aa469"/>
      <stop offset="100%" stop-color="#2f6f4f"/>
    </linearGradient>
  </defs>
  <rect width="640" height="640" rx="48" fill="url(#bg)"/>
  <circle cx="520" cy="120" r="72" fill="#ffffff" fill-opacity="0.45"/>
  <circle cx="140" cy="520" r="96" fill="#ffffff" fill-opacity="0.25"/>
  <path d="M310 416c-18-58-10-119 23-176 18-31 46-62 84-90 12-9 29-2 31 13 11 78-11 136-53 177-24 23-53 41-85 53z" fill="url(#leaf)"/>
  <path d="M266 416c12-52 0-107-34-156-21-31-52-59-92-80-13-7-29 2-30 17-6 70 17 123 58 160 25 22 57 41 98 59z" fill="url(#leaf)"/>
  <path d="M287 262c6 34 8 68 7 102-1 43-5 82-11 116" fill="none" stroke="#2b5f44" stroke-width="14" stroke-linecap="round"/>
  <path d="M206 442h228l-20 92H226z" fill="#c88c52"/>
  <path d="M190 426h260c10 0 18 8 18 18s-8 18-18 18H190c-10 0-18-8-18-18s8-18 18-18z" fill="#b97845"/>
</svg>
`.trim()

export const DEFAULT_PLANT_IMAGE = `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(defaultPlantSvg)}`

const PLACEHOLDER_HOSTS = new Set(['example.com', 'www.example.com'])

export function isPlaceholderImageUrl(value) {
  if (!value || typeof value !== 'string') return false

  try {
    const url = new URL(value)
    return PLACEHOLDER_HOSTS.has(url.hostname.toLowerCase())
  } catch {
    return false
  }
}

export function normalizeImageUrl(value, fallback = DEFAULT_PLANT_IMAGE) {
  if (!value || typeof value !== 'string') return fallback

  const url = value.trim()
  if (!url || isPlaceholderImageUrl(url)) {
    return fallback
  }

  return url
}
