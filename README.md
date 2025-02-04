## Inkling TypeScript Library/Package Template

Standardized template for building modern TypeScript libraries at Inkling. Has the following features out of the box:

- Dual mode build (CJS and ESM)
- ESLint, Prettier and EditorConfig support
  - CLI: `yarn format`
  - VSCode: Default `On Save` settings included + EditorConfig
  - Other Editors: EditorConfig
- Testing (`jest` + `ts-jest`)
- Modern TypeScript configuration
- Example of proper export styling
  - Root exports
  - Submodules
- Source maps and typings in the library package
- GitHub Actions
  - Run ling/build/test checks on PR
  - Publish to JFrog @echo360 scope when creating a GitHub Release
