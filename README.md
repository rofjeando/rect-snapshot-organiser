# Rect Snapshot Organiser

KM macro system for capturing, managing, and restoring window layout snapshots using Rectangle (or equivalent).

## Project Structure

```
rect-snapshot_organiser/
├── docs/                   # General project documentation
├── guides/                 # How-to guides and references
│   ├── km_macros/          # KM macro guides
│   ├── shell_scripts/      # Shell script guides
│   └── applescript/        # AppleScript guides
├── implementation/         # Working files
│   ├── km_macros/          # .kmmacros files
│   │   ├── km_icons/       # Custom macro icons
│   │   └── xmlTransit_output/  # AI ↔ KM XML transit folder
│   ├── shell_scripts/      # .sh files
│   ├── applescripts/       # .scpt / .applescript files
│   └── html_prompts/       # KM Custom HTML Prompts
├── miscellaneous/          # Uncategorized utilities
└── project-specific/       # Sub-projects
```

## KMET XML Workflow

- Copy XML from KM: **⌃⌥K** (Copy Selected Objects as XML Text)
- AI modifies XML → saves to `implementation/km_macros/xmlTransit_output/`
- Paste into KM: **⌃⌥K** (Paste Objects into KM)

## Key Paths

| Thing | Path |
|---|---|
| Project root | `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/rect-snapshot_organiser/` |
| KM macros | `implementation/km_macros/` |
| Shell scripts | `implementation/shell_scripts/` |
| XML transit | `implementation/km_macros/xmlTransit_output/` |
