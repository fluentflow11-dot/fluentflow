# fluentflow_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment & Secrets (Task 21.9)

- CLI usage: create a `.env` file at repo root (same directory as `package.json`) based on `.env.example` and add provider keys you use (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.). The CLI reads `.env` for AI tools (Taskmaster).
- Cursor/MCP usage: set the same keys in `.cursor/mcp.json` under `env` so integrated tools can access them.
- Firebase App Check (dev): we activate the debug provider in code. To remove the 403 warnings, enable the `Firebase App Check API` in Google Cloud for your project and wait a few minutes.
- Storage rules (dev): use authenticated-only access. Remember to harden before release.