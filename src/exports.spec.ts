import 'jest-extended';

import { rootExportFunction } from './exports';

describe('rootExportFunction', () => {
  it('returns true', () => {
    expect(rootExportFunction()).toBeTrue();
  });
});
