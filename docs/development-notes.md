# Development Notes

## Recommended Local Workflow

Use `bin/dev` for the standard local workflow:

```bash
bundle install
npm install
bin/rails db:prepare db:seed
bin/dev
```

That starts:

- Rails
- the client dev server
- the server bundle watcher
- the Node renderer
- the RSC bundle watcher

## Other Dev Modes

### Static Assets On Disk

Use this when you want stable file-on-disk assets instead of HMR:

```bash
bin/dev static
```

### Production-Style Assets

Use this when you want to run Rails against production-built assets in development:

```bash
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/shakapacker
bin/dev prod
```

## Important HMR Caveat

In HMR mode, wait for the dev server to finish compiling before you hit `/` for the first time.

If the first request lands before `react-client-manifest.json` is available, the Node renderer can cache the bundle
without the client manifest. When that happens, the streamed RSC surface falls back to client rendering until the
renderer cache is reset.

Recovery:

```bash
rm -rf .node-renderer-bundles
```

Then restart the Node renderer or restart `bin/dev`.

## Fast Sanity Checks

Confirm the client manifest is available:

```bash
curl http://localhost:3035/packs/react-client-manifest.json
```

Confirm the root page streams cleanly:

```bash
curl -sS -D - http://127.0.0.1:3000/
```

## Runtime Notes

- This repo expects Node `24.8.0` locally.
- On this machine, the Node `22.x` `npm` shim is broken, so explicit Node `24.8.0` usage is safer for manual npm commands.
- The Node renderer license warning is expected in local bootstrap mode unless a React on Rails Pro license is configured.
- The dashboard assumes the demo seed data exists. If the home route looks empty or counts are zero, rerun `bin/rails db:prepare db:seed`.

## Adding New RSC Entry Points

When you add a new top-level component under `app/javascript/src/atomic_crm/ror_components`, regenerate the pack
registration files:

```bash
bundle exec rake react_on_rails:generate_packs
PATH="/Users/justin/.local/share/mise/installs/node/24.8.0/bin:$PATH" bin/shakapacker
```

Two process restarts matter after that:

- If server rendering says a component is not registered, the node renderer is likely using an old server bundle.
  Clear `.node-renderer-bundles/` and restart `client/node-renderer.js`.
- If the browser console shows `404` for `/packs/js/generated/...`, the Shakapacker dev server is still serving the
  old entrypoint graph. Restart `bin/shakapacker-dev-server`.
