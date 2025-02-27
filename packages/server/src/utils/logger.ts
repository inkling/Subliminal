import configureLogger from '@inkling/utils-logger';

const logger = configureLogger({
  development: process.env.NODE_ENV === 'development',
  env: process.env.NODE_ENV || 'development',
  version: process.env.VERSION || '0.0.0',
  sentryUrl: process.env.SENTRY_URL,
  logLevel: process.env.LOG_LEVEL || 'debug',
});

export default logger;
