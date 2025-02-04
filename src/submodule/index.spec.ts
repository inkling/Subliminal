import 'jest-extended';

import { submodule } from './';

describe('submodule', () => {
  describe('submoduleFunction', () => {
    it('returns 1', () => {
      expect(submodule.submoduleFunction()).toBe(1);
    });
  });
});
