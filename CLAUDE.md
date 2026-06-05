# Rect Snapshot Organiser — Claude Context

## Project Purpose

KM macro system for capturing, managing, and restoring students picture snapshots.

There are two different KM groups affected to this project: __[RECT] iina and 2) __[RECT] Rect-snapshot_organiser in Affinity. 

[RECT] iina corresponds to the goal of taking different snapshots from a zoom video recording showing the student performin different procedures of coordinated instructions. The list of snapshots is finally inserted into a corresponding Artboard in Affinity Designer

__[RECT] Rect-snapshot_organiser corresponds to the goal of taking a sequence of snapshots of students' pictures after they have been enhanced with visual elements. The series of snapshots will be inserted in separate Slides in Keynote. 

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

## Debugging Sessions

### 2025-06-05 — Macro Flow & Image Selection Fixes

**Issue 1:** After `sub_OverlayRectCoord0` rectangle adjustment, clicking OK on the confirmation prompt caused the macro to stop.
- **Cause:** `sub_New Bounds %rect_coord0%` was calling `sub_OverlayRectCoord0` via `ExecuteMacro` instead of `Execute Subroutine`
- **Fix:** Changed middle `ExecuteMacro` action to `Execute Subroutine` with proper parameter `%rect_coord0%` and result capture

**Issue 2:** After restart with letter-appended title, only second batch of snapshots was inserted into Keynote.
- **Cause:** `sub_Name Snapshots` had `%iina_imageNameModel%a` as default in Prompt for User Input, adding suffix; `Keynote insert listImage3screens` had regex filters expecting this pattern
- **Root issue:** The letter suffix was originally meant to distinguish iina vs Affinity snapshots, but these are already stored in separate folders (`imageTransit_temp` vs `imageTransit_JPG`)
- **Fix:** Removed `a` suffix from Prompt default; deleted two purple "filter list of images without a letter" Execute Shell Script actions

**Files modified:**
- `[Rect] sub_New Bounds %rect_coord0%.kmmacros` — ExecuteSubroutine fix
- `[Rect] sub_Name Snapshots.kmmacros` — removed letter suffix
- `Keynote insert listImage3screens.kmmacros` — removed regex filters

## Status

- [x] Macros exported and in `implementation/km_macros/`
- [x] 2025-06-05 debugging session documented
- [ ] Process documented in `docs/`
