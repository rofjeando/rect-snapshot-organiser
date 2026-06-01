# Rect Snapshot Organiser — Claude Context

## Project Purpose

KM macro system for capturing, managing, and restoring window layout snapshots.

## Key Paths

| Thing | Path |
|---|---|
| Project root | `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/rect-snapshot_organiser/` |
| KM macros | `implementation/km_macros/` |
| Shell scripts | `implementation/shell_scripts/` |
| Applescripts | `implementation/applescripts/` |
| HTML prompts | `implementation/html_prompts/` |
| XML transit folder | `implementation/km_macros/xmlTransit_output/` |
| Docs | `docs/` |

## KMET XML Workflow (AI ↔ KM)

See `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KM_organiser/CLAUDE.md` for full KMET reference.

Short version:
1. Copy XML from KM: ⌃⌥K
2. AI modifies/generates XML → `xmlTransit_output/`
3. Paste into KM: ⌃⌥K

**Always use `<array>` as plist root for KMET clipboard XML.**

## macOS 26 Import Restriction

Import `.kmmacros` from local `~/Documents/` path, not directly from Dropbox CloudStorage path.

## Status

- [ ] Macros exported and in `implementation/km_macros/`
- [ ] Process documented in `docs/`
