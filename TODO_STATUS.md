# mcp-google-sheets Todo Status

Last refreshed: 2026-11-11
Source: `gh` authenticated as `xing5`, repo `xing5/mcp-google-sheets`.

## Snapshot

- Open issues: 17
- Open pull requests: 7
- Latest release: `v0.6.3` published from `2869443`.
- Current `main` already includes: Docker/SSE support, `CREDENTIALS_CONFIG`, folder targeting and `list_folders`, `search_spreadsheets`, `find_in_spreadsheet`, arbitrary `batch_update`, chart creation, tool filtering, ADC, `include_grid_data`, and the MCP Python SDK 2.x (`MCPServer`).
- Current quality gates: required PR unit checks for Python 3.10 and 3.12; release publishing gated on live Google integration tests covering every current MCP tool.
- Latest verification: `uv check` clean (0 diagnostics), the credential-free suite passed (22 tests; the live class skips without `RUN_GOOGLE_INTEGRATION=1`), and the live Google suite passed with OAuth 2.0 on 2026-11-11; last release verification was the `v0.6.3` `Publishing` workflow (build, live Google integration tests, PyPI upload).

## P0/P1: Do Next

- `done` Establish release and PR test gates. Unit tests are required on PRs; release publishing requires live Google integration tests.
- `done` Resolve stdout logging risk: PR #80 replaced diagnostic `print()` calls with stderr logging, added `cache_discovery=False`, and added stdout-safety regression tests.
- `done` Migrate to the MCP Python SDK 2.x (`MCPServer`), fix the resource's removed `get_lifespan_context()` call, and bring `uv check` to zero diagnostics.
- `todo` Release the MCP SDK 2.x migration as a breaking change: bump the version, document the `mcp>=2.3,<3` requirement, note that the Docker image now defaults to the Streamable HTTP transport (`/mcp` instead of `/sse`), and pass the live Google integration gate before publishing.
- `todo` Confirm the Python 3.10 and 3.12 CI unit jobs pass with the mcp 2.3 lock (`uv sync --frozen`).
- `done` Run the live Google integration suite after the migration, including the `spreadsheet://{id}/info` resource path: passed locally on 2026-11-11 with OAuth 2.0 (2 tests, ~15 s, no leftover files).
- `done` Fix the README tool count: it said "19 tools" but the server exposes 20.
- `done` Extract `get_credentials(interactive=...)` from the lifespan and let the live suite reuse it, so OAuth 2.0, service account, and ADC all work for tests without a browser prompt.
- `done` Add OAuth 2.0 support to the live-test workflow through the optional `GOOGLE_OAUTH_TOKEN_JSON` secret.
- `done` Align the Docker image with the MCP SDK 2.x codebase: pin the Alpine base, install from `uv.lock` (`--locked --no-editable`), copy the resolved venv into the runner instead of re-resolving from PyPI, and declare `HOST`/`PORT`/`EXPOSE 8000`.
- `done` Switch the container default transport from SSE to Streamable HTTP (`/mcp`); SSE stays available as an explicit opt-in. No known Docker clients depend on `/sse`, so no migration path was needed.
- `todo` Review PR #65 against current tests. If a signature-preservation bug still exists, reproduce it with a failing unit test first; otherwise close as obsolete.
- `closeable` Close issue #53. Reporter retested, cannot reproduce, and explicitly asked to close.
- `done` Add docs for service-account Drive quota behavior. README now documents the zero-quota limitation, the Shared Drive workaround, and OAuth as the alternative for creating files (issues #40/#75).
- `todo` Update Claude example prompts from issue #74 so examples explicitly use the Google Sheets MCP connector rather than encouraging local XLSX creation.

## PR Review Queue

- `closed` #79 "Improve logging, add observability": closed as superseded by #80 for the stdio fix. Timing/observability can return as a separate PR.
- `closed` #73 "fix: use stdlib logging instead of print (stderr)": closed as superseded by #80.
- `review` #68 "feat: add batching support and structured logging": large, overlaps completed logging work. Split batching from logging/docs before merge consideration.
- `review` #67 "feat: add R1C1 formula format support": behind `main`, large. Needs focused formula tests and live/fixture expectations.
- `review` #66 "chore: improve code quality with Gourmand AI standards": merge status unknown, broad refactor. Lower priority unless it reduces real maintenance risk.
- `review` #65 "fix: use functools.wraps to preserve function signatures in tool decorator": verify with a failing signature/introspection unit test before accepting.
- `review` #63 "Add comment management tools": conflicting. Rebase or replace before functional review.
- `review` #45 "feat: add format_cells tool": conflicting and requested by issue #25. Worth reviving because formatting demand is clear.
- `closeable` #39 "fix(server): change main to async def": confirmed obsolete after the MCP SDK 2.x migration; `MCPServer.run()` remains synchronous. Close with a version note.

## Issues: Close, Answer, or Narrow

- `closeable` #53 list_sheets only returns one sheet: user says fixed and asks to close.
- `closeable` #49 Docker/SSE mode: PR #50 merged. Leave a short note and close if current Docker instructions are sufficient.
- `done` #19 main transport parameters: `main()` now explicitly supports `stdio`, `sse`, and `streamable-http`, with host/port passed to `run()` for HTTP transports and a clear error for unknown values. Close with a version note.
- `closeable` #13 arbitrary batchUpdate: current `batch_update` exists and live integration coverage now exercises it. Close after checking docs mention Google request specs.
- `closeable or narrow` #76 cannot find sheet by name: `search_spreadsheets` exists on `main` and live integration coverage exercises it. Update docs/examples, then close or ask reporter to retry latest.
- `answer` #56 Antigravity initialize EOF: ask for logs, transport, config, and version. The stdout logging fix shipped in `v0.6.3`, so ask the reporter to retry latest before deeper debugging.
- `todo` #44 Windows + WSL setup docs: add a Claude Desktop WSL config section and ensure logs go to stderr before recommending the setup broadly.
- `answer` #38 shifted column data: ask for version, exact tool call, and minimal reproduction. Could be model prompting or range construction, not yet actionable.
- `answer` #71 mctx hosting: business decision, not engineering work.
- `todo` #64 Docker MCP Toolkit: registry submission task.

## Feature Backlog

- `todo` #78 Canvas tools: research whether Google Sheets API exposes Canvas creation/update. If API coverage is absent, answer with limitation.
- `todo` #42 Tables API: design table create/read/update tools around Google Sheets tables API.
- `todo` #41 Cell notes: can be implemented through `batch_update`/`updateCells` notes; either document a recipe or add a dedicated helper.
- `todo` #25 Formatting: revive or replace PR #45; consider formatting, borders, number formats, alignment, and colors. Any implementation must add unit coverage and extend the live all-tools integration path.

## Maintenance Notes

- Test policy: no new feature implementation should proceed without a written test plan and local unit tests. Live Google tests are opt-in through the `Google Integration Tests` workflow and mandatory in the release workflow.
- Release policy: PyPI publishing is gated on the live Google integration test job in the `Publishing` workflow. The live suite covers every current MCP tool function and fails if new tools are added without integration coverage.
- Useful live-test setup: add GitHub secrets `GOOGLE_DRIVE_FOLDER_ID` and one of `GOOGLE_SERVICE_ACCOUNT_JSON`, `GOOGLE_CREDENTIALS_CONFIG`, or `GOOGLE_OAUTH_TOKEN_JSON`. The folder must be disposable because tests create and delete spreadsheets. A service account needs a Shared Drive; a personal Gmail folder requires OAuth.
- Branch protection requires `Unit tests (3.10)` and `Unit tests (3.12)` on PRs targeting `main`.
- Many open issues are solved by current `main` but remain open because docs/comments were not updated.
- Prefer closing stale solved issues with a release/version note rather than leaving them as active backlog.
