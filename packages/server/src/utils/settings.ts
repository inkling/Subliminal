import path from 'path';

import { Static, Type } from '@sinclair/typebox';

import SettingsManager from '@inkling/utils-settings';
import { ValidationError, validator } from './validator';

export const Settings = Type.Object({
  development: Type.Boolean(),
  environment: Type.String(),
  logLevel: Type.Optional(Type.String()),
  //   secrets: SecretsSettings,
  sentry: Type.Union([
    Type.Object({
      enabled: Type.Literal(false),
      protocol: Type.Optional(Type.String()),
      host: Type.Optional(Type.String()),
      appId: Type.Optional(Type.String()),
      privateKey: Type.Optional(Type.String()),
      publicKey: Type.Optional(Type.String()),
    }),
    Type.Object({
      enabled: Type.Literal(true),
      protocol: Type.String(),
      host: Type.String(),
      appId: Type.String(),
      privateKey: Type.String(),
      publicKey: Type.String(),
    }),
  ]),
  magicbell: Type.Object({
    apiKey: Type.String(),
    apiSecret: Type.String(),
  }),
});
export type Settings = Static<typeof Settings>;

function loadAndValidateSettings(): Settings {
  try {
    const manager = new SettingsManager(path.join(__dirname, '../config'));
    const rawSettings = manager.getSettings();

    if (!validator.validate(Settings, rawSettings)) {
      throw new ValidationError('invalid settings file', validator?.errors);
    }

    return rawSettings as Settings;
  } catch (err) {
    // Must use console because logger isn't available yet
    console.error('could not load settings', { reason: err?.toString() });
    throw err;
  }
}

export const settings = loadAndValidateSettings();
