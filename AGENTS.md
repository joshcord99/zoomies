# ZOOMIES Agent Workflow

Use the custom agents defined in `.codex/config.toml` for substantial product work.

## Workflow

Pass a user idea through these roles in order:

1. `sprint` (Sprint): turn the idea into a scoped product brief and acceptance criteria.
2. `bounce` (Bounce): define game rules, progression, balance, and player experience.
3. `glance` (Glance): define the watchOS interaction flow and visual hierarchy.
4. `loaf` (Loaf): define character, map, and visual-theme requirements.
5. `pixel` (Pixel): implement SwiftUI screens, navigation, and presentation.
6. `dash` (Dash): implement gameplay systems, collisions, controls, and state.
7. `vault` (Vault): implement and validate persistent data and migrations.
8. `wiggle` (Wiggle): refine animation, audio, haptics, and feedback.
9. `turbo` (Turbo): profile and improve watchOS performance and efficiency.
10. `checkpoint` (Checkpoint): verify acceptance criteria and report defects.
11. `launch` (Launch): prepare release metadata and App Store readiness.

## Handoffs

- Each agent must inspect the repository before making recommendations or edits.
- Each agent must preserve prior accepted decisions unless it identifies a concrete conflict.
- Each handoff must state completed work, open risks, and the next role's required input.
- Implementation agents should make focused edits and verify their work.
- Checkpoint blocks Launch when acceptance criteria or critical defects remain unresolved.
- Launch may prepare release materials but must never claim an App Store submission occurred without explicit confirmation.

