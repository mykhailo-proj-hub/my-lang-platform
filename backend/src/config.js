const DEFAULT_FRONTEND_ORIGIN = 'http://localhost:3000';

function parseAllowedOrigins() {
  const rawOrigins = process.env.FRONTEND_ORIGIN || DEFAULT_FRONTEND_ORIGIN;

  return rawOrigins
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function isOriginAllowed(origin) {
  if (!origin) {
    return true;
  }

  return parseAllowedOrigins().includes(origin);
}

const corsOptions = {
  origin(origin, callback) {
    if (isOriginAllowed(origin)) {
      return callback(null, true);
    }

    return callback(new Error(`Origin ${origin} is not allowed by CORS`));
  },
  credentials: true,
};

module.exports = {
  corsOptions,
  parseAllowedOrigins,
};
