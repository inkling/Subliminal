# Inkling MagicBell

## Development

- Install dependencies: `yarn` (run at root)

## Client package

- Contains Habitat notification bell UI
- Go to directory: `cd packages/client`
- Start React playground: `yarn start`
- Build: `yarn build`
- Publish: `yarn publish`

## Client package - Publisher

Publisher is in Backbone, therefore doesn't work with `@magicbell/react` library v11. We diverged a `publisher-branch` with the same components but with `@magicbell/react` v8.

Consider porting future changes to `publisher-branch` and always publish to `v0.2.x` so it doesn't conflict with new minor/major versions.

## Server package

- Contains Magicbell server methods for broadcasting notification to users
- Go to directory: `cd packages/server`
- Test functions: `npx tsx test.ts`
