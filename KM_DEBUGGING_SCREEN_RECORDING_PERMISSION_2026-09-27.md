# KM Screen Capture returned blank images — Screen Recording permission (2026-09-27)

## Problem

`[INA] QUICK SNAPSHOT (ctrl Return) ` (AA8C6A79-6B8B-4FB5-AE34-BDCD44D74842), run from
`F Firsts Snapshot` / `N Next Snapshot` (palette `__PaletteIIna`), suddenly produced a series of
identical snapshots after months of correct operation. Pasted into Affinity Designer, every image
was the same black / flat grey rectangle.

## Diagnosis

| Check | Result |
|---|---|
| Engine.log | Runs logged normally, no errors |
| Live-plist `ModificationDate` of F, N, QUICK SNAPSHOT, `[Rect] sub_OverlayRectCoord0` | None changed recently (latest 2026-08-07) |
| `rect_coordinates` after pressing F | Correct (`1873,134,812,893`) |
| Clipboard after the Screen Capture action | Black image |
| Saved JPG size for the same area | 15-19 KB blank vs ~397 KB after fix |
| `~/Library/Group Containers/group.com.apple.replayd/ScreenCaptureApprovals.plist` | KM approved 2025-11-08, next reminder 2026-12-03 — not the periodic prompt |
| Recent installs | macOS 27.0 (2026-09-20, worked afterwards), Zoom Workplace (2026-09-25) |

The macro logic was correct. macOS had stopped honouring Keyboard Maestro Engine's Screen
Recording permission while the switch still showed "on". Without it, captures return blank
window contents instead of failing, and `Write File` from clipboard saves the blank image.
The trigger is unknown.

## Fix

1. System Settings > Privacy & Security > Screen & System Audio Recording.
2. Toggle Keyboard Maestro Engine off, then on (or remove and re-add
   `/Applications/Keyboard Maestro.app/Contents/MacOS/Keyboard Maestro Engine.app`).
3. KM Editor: File > Quit Engine, then File > Launch Engine.

Result: correct screenshot, 397 KB for the same rectangle.

## Caveats

- To date when it broke, run in Terminal (not available to the sandboxed agent):
  `log show --start "2026-09-25" --predicate 'process == "tccd" AND eventMessage CONTAINS[c] "maestro"' --style compact | grep -i screen`
- Possible hardening (not implemented): after `Write File`, warn if the JPG is under ~50 KB.
- Unrelated issue noticed: `F Firsts Snapshot` cleans `/Users/tsukadjed/Library/CloudStorage/Dropbox/imageTransit_temp`
  (condition path contains a stray `"`), but snapshots now live in
  `/Users/tsukadjed/Library/Caches/imageTransit_temp`.

KB entry: `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/ProjectTemplate/docs/km_debugging_guide.md`
(2026-09-27 — Black Screen Capture with a correct area means the Engine lost Screen Recording permission)
