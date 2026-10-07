# KM: snapshots inserted into the wrong Keynote deck (2026-10-07)

## Problem
`[Rect] sub_Keynote Export` (E52E0414-054C-42B6-A9F9-0FE2BEF9A15E) imported Affinity snapshots into a Keynote deck that did not carry the student's name and sat in AeroSpace workspace U, instead of the student's deck in workspace K.

## Why
`Keynote insert listImage3screens` ran the focus script, then an unconditional **Open File `%keyn_studentKeynote%`**. That global is written by other macros and held another student's deck (Kevin-DMackay1_Student.key, in U). Opening it re-raised that deck; the AppleScript then inserted into Keynote's `front document`. `Keynote insert listImage MbPro` had no focus step at all.

## Fix
- `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/rect-snapshot_organiser/implementation/shell_scripts/rect_focus_keynote_student.sh` rewritten: matches the full FirstLast base from `snag_imageName` (longest base, then highest ordinal; hyphens and apostrophes kept), opens the newest deck if no window exists, moves it to K, focuses it, stores the window title in KM variable `rect_targetDeck`.
- Both macros: Open File step removed (3screens), focus group added (MbPro), and the insert AppleScript now errors out if the front document's name does not contain `rect_targetDeck`.
- Shell/AppleScript actions set to discard results (no leftover result windows).
- Tested 2026-10-07: Kevin-DMackay1 forced to front, macro run, 2 slides landed in AlexiKaruna1_Student.key (in K), Kevin's deck unchanged; test slides removed afterwards.

## Macros and UIDs after the import cycle
| Macro | UID now | Note |
|---|---|---|
| Keynote insert listImage3screens | 76C22AAE-3F66-40F8-9CF9-4F13980FFEC5 | old 408EA603-... deleted |
| Keynote insert listImage MbPro | 2394B140-7ADF-465D-B289-682EF8849BC3 | old 48F24D80-... deleted |
| [Rect] sub_Keynote Export | E52E0414-054C-42B6-A9F9-0FE2BEF9A15E | ExecuteMacro actions repointed to the two new UIDs |

All three live in the groups `__PaletteAffinityDesigner    ⌃ ⌥ P` (4846D329-A105-4BDC-90E5-F317B45442CE) and `__[RECT] Rect-snapshot_organiser in Affinity`.

## Caveats
- The MbPro macro (used with fewer than 3 screens) was not run end to end.
- The guard's refusal path (wrong front document) was not triggered in the test.
- `ssp_reloadMonthlyFile` (SSP) was disabled the same day; a disabled macro cannot be run by `do script`, by name or UID (verified).
