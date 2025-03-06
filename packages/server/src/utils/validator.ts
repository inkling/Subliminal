import { TSchema } from '@sinclair/typebox';

import addFormats from 'ajv-formats';
import Ajv from 'ajv/dist/2019';

//--------------------------------------------------------------------------------------------
//
// Setup AJV validator with the following options and formats
//
//--------------------------------------------------------------------------------------------

export const validator = addFormats(new Ajv({}), [
  'date-time',
  'time',
  'date',
  'email',
  'hostname',
  'ipv4',
  'ipv6',
  'uri',
  'uri-reference',
  'uuid',
  'uri-template',
  'json-pointer',
  'relative-json-pointer',
  'regex',
])
  .addKeyword('kind')
  .addKeyword('modifier');

export function parseAndValidate<TData>(schema: TSchema, json: string | null | undefined): TData | null {
  const data = JSON.parse(json || '{}');
  const valid = validator.validate(schema, data);
  return valid ? data : null;
}

type ValidatorErrors = typeof validator.errors;
export class ValidationError extends Error {
  public readonly validationErrors: ValidatorErrors;

  constructor(message: string, errors?: ValidatorErrors) {
    super(message);

    this.validationErrors = errors;
  }

  toString(): string {
    return JSON.stringify(this);
  }
}
