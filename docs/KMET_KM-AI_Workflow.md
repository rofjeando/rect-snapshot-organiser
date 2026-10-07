# KMET Workflow Documentation

## Overview

This document describes the **operational two-way workflow** enabling AI assistants to generate and modify Keyboard Maestro macros and actions.

**Status: WORKING** ✅

> **⚠️ UPDATE (July 2026):** Direct `.kmmacros` file generation by AI is now **SOLVED**.
> The current primary workflow is the **`[EXM]` / `[IMP]` system** documented in
> **`km_xml_import_guide.md`** (same folder). Use that guide for creating/modifying whole macros.
> This KMET document remains valid as a **fallback for pasting individual actions** into the KM Editor.

---

## The Core Problem (Solved — twice)

AI assistants historically **could not generate valid `.kmmacros` files** that Keyboard Maestro would import directly. Multiple attempts using `plistlib`, `xml.etree.ElementTree`, and various format adjustments all resulted in "Cannot Import Macro File - unknown format" errors.

**Resolution (July 2026):** the format rules were cracked — see `km_xml_import_guide.md`. Two import paths now exist:

| Import path | Root element | When to use |
|-------------|-------------|-------------|
| **`[IMP]` macro** (current system) | `<dict>` (single-macro) + `IMP_META` first action | Creating/modifying whole macros — **preferred** |
| **Double-click import** | `<array>` (group-wrapper) | Manual import without `[IMP]` |

---

## The KMET XML Paste Workflow (action-level fallback)

Dan Thomas's **KMET** (Keyboard Maestro Edit as Text) system remains useful for **pasting individual actions or action sequences directly into an open macro** in the KM Editor. For whole-macro round-trips, prefer the `[EXM]`/`[IMP]` workflow in `km_xml_import_guide.md`.

### What Works

| Capability | Status |
|-----------|--------|
| AI modifies existing macros (rename, new UID) | ✅ Working |
| AI adds new actions to macros | ✅ Working |
| AI generates individual actions for insertion | ✅ Working |
| AI creates complex multi-action sequences | ✅ Working |
| Direct `.kmmacros` file generation | ✅ **Working since July 2026** — see `km_xml_import_guide.md` |

---

## Required KMET Macros

### 1. `[µKMET Sub-Macro] Set Clipboard to Objects Text` (Modified)

**CRITICAL FIX:** The JavaScript in this macro must be modified to set **both** the KM-specific clipboard type AND plain text:

```javascript
setClipboardToKMPlistXml: function (xml) {
    var objectType = _getKMPlistXmlObjectType(xml);
    var clipboardStringType = _getKMClipboardStringTypeForObjectType(objectType);
    
    // Set both types without clearing between - FIX for clipboard corruption
    var clipboard = $.NSPasteboard.generalPasteboard;
    clipboard.clearContents;
    clipboard.setStringForType($(xml), $(clipboardStringType));
    clipboard.setStringForType($(xml), $.NSPasteboardTypeString.js);
    
    return objectType;
}
```

### 2. `[KMET] Paste Objects into KM` (Dan Thomas's Original)

Use the original macro from Dan Thomas's KMET system. Ensure it reads from clipboard and pastes into KM Editor.

---

## Workflow Steps

### Extract (You → AI)

1. Select macro or action in KM Editor
2. Press **⌃⌥K** (Copy Selected Objects as XML Text)
3. XML is copied to clipboard
4. Paste XML in chat or save to file for AI

### Modify (AI)

1. AI receives XML via chat or file path
2. AI modifies structure (add/remove actions, change parameters, rename)
3. AI generates new UID, updates ActionUIDs, increments version suffix
4. AI returns modified XML

### Import (AI → You → KM)

1. Copy AI-modified XML to clipboard
2. Press **⌃⌥K** (Paste Objects into KM)
3. Modified macro/action appears in KM Editor

---

## Hotkey Convention

**⌃⌥K** (Control-Option-K) for all KMET-related macros:
- `[µKMET Sub-Macro] Set Clipboard to Objects Text`
- `[KMET] Paste Objects into KM`

---

## Project Setup

### Required Folder Structure

For each project using this workflow:

```
Project/
└── implementation/
    └── km_macros/
        └── xmlTransit_output/     # AI saves modified XML here
```

### Example

```
/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KM_organiser/
└── implementation/
    └── km_macros/
        └── xmlTransit_output/
```

**Folder Purpose:** Dedicated location for scripts, HTML, XML under `implementation/` with standardized subfolders.

---

## XML Format Requirements

### Actions

Actions must use correct KM action types and include required fields:

**Comment Action:**
```xml
<dict>
    <key>ActionColor</key>
    <string>Teal</string>
    <key>ActionUID</key>
    <integer>88888801</integer>
    <key>MacroActionType</key>
    <string>Comment</string>
    <key>StyledText</key>
    <data>Q29tbWVudCB0ZXh0</data>
    <key>Title</key>
    <string>Comment Title</string>
</dict>
```

**Display Text Action:**
```xml
<dict>
    <key>Action</key>
    <string>DisplayWindow</string>
    <key>ActionName</key>
    <string>Display Text</string>
    <key>ActionUID</key>
    <integer>88888802</integer>
    <key>MacroActionType</key>
    <string>InsertText</string>
    <key>StyledText</key>
    <data>...</data>
    <key>Text</key>
    <string>Text to display</string>
</dict>
```

**CRITICAL: Execute Shell Script Action:**

⚠️ **NEVER use inline scripts in KMET XML** - character escaping issues persist and scripts will fail to paste.

✅ **ALWAYS reference external script files:**

```xml
<dict>
    <key>ActionUID</key>
    <integer>88888803</integer>
    <key>DisplayKind</key>
    <string>None</string>
    <key>MacroActionType</key>
    <string>ExecuteShellScript</string>
    <key>Path</key>
    <string>/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/Project/implementation/shell_scripts/script_name.sh</string>
    <key>Source</key>
    <string>Nothing</string>
    <key>Text</key>
    <string></string>
    <key>TimeOutAbortsMacro</key>
    <true/>
    <key>TrimResults</key>
    <true/>
    <key>UseText</key>
    <false/>
</dict>
```

**Required Folder Structure for Scripts:**
```
Project/
└── implementation/
    └── shell_scripts/          # Store all shell scripts here
        ├── start_api_server.sh
        └── other_scripts.sh
```

**Example Script:**
```bash
#!/bin/zsh
# Launch API server if not running
if ! lsof -i :8081 > /dev/null 2>&1; then
    cd "/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KM_organiser/implementation/python_scripts"
    nohup python3 api_server.py > /tmp/km_api_server.log 2>&1 &
    sleep 1
fi
```

**Trigger by Name Action:**
```xml
<dict>
    <key>ActionUID</key>
    <integer>20152022</integer>
    <key>MacroActionType</key>
    <string>TriggerByName</string>
    <key>TimeOutAbortsMacro</key>
    <true/>
</dict>
```

### Full Macro Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>Actions</key>
        <array>
            <!-- Action dictionaries here -->
        </array>
        <key>CreationDate</key>
        <real>784129148.71166301</real>
        <key>ModificationDate</key>
        <real>796642422.57450998</real>
        <key>Name</key>
        <string>Macro Name_v2</string>
        <key>Triggers</key>
        <array>
            <!-- Trigger dictionaries -->
        </array>
        <key>UID</key>
        <string>XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX</string>
    </dict>
</array>
</plist>
```

---

## Critical Requirements

1. **Unique ActionUIDs:** Each action must have a unique integer UID
2. **Unique Macro UID:** Each macro needs a unique UUID (change when creating variants)
3. **Version Suffix:** Rename macros with `_v2`, `_v3`, etc. to distinguish from originals
4. **Valid XML Structure:** Maintain proper plist/XML syntax
5. **Correct Action Types:** Use KM's exact action type names and required fields

---

## Action Array Format (No Macro Wrapper)

For inserting individual actions into existing macros:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <!-- Individual action dictionaries -->
</array>
</plist>
```

---

## XML vs JSON

**Current Status:** XML is working reliably.

**JSON Consideration:** KMET supports both XML and JSON, but XML is the native format Keyboard Maestro uses internally. JSON conversion adds a conversion step that may introduce edge cases.

**Recommendation:** Stick with XML for now. It's working, it's what KM natively produces, and the KMET JavaScript handles it correctly. JSON can be explored later if needed for specific debugging scenarios.

---

## Troubleshooting

### Clipboard Shows "non-text clipboard"

**Cause:** JavaScript not setting plain text type
**Fix:** Update `setClipboardToKMPlistXml` function to set both KM type and plain text (see Required Macros section)

### Actions Don't Appear After Paste

**Cause:** Invalid action type or missing required fields
**Fix:** Verify action uses correct `MacroActionType` and includes all required keys

### Import Fails Silently

**Cause:** Corrupted XML structure or invalid UID format
**Fix:** Check XML validity, ensure UIDs are unique integers for actions, UUIDs for macros

---

## Summary

**The workflow is operational.** AI can now:

1. ✅ Receive macro/action XML via chat or file
2. ✅ Modify existing macros (add/remove actions, change metadata)
3. ✅ Generate new individual actions for insertion
4. ✅ Create complex multi-action sequences
5. ✅ Return valid XML for KMET import

**The barrier (direct `.kmmacros` generation) was solved in July 2026** — see `km_xml_import_guide.md` for the `[EXM]`/`[IMP]` whole-macro workflow. KMET remains the action-level paste fallback.

**Next Steps:** Copy this file and `km_xml_import_guide.md` to each project folder that uses KM workflows, create the `xmlTransit_output/` subfolder, and start modifying macros via AI assistance.

---

## KM Icon Workflow

For bright, visible custom icons in Keyboard Maestro macros:

### Specifications
- **Size:** 128×128 pixels
- **Format:** PNG with transparency
- **Design:** High contrast colors, simple shapes

### Workflow
1. Open: `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/Project/implementation/km_icons/Project_icons.afdesign`
2. Design new icon in Affinity Designer
3. Export as PNG to: `implementation/km_icons/`
4. Open the PNG in Preview
5. Select all (⌘A) → Copy (⌘C) the image
6. In KM: Select macro → Edit → Set Macro Icon → Paste (⌘V) into placeholder

The Preview copy method embeds the actual image data, which KM uses as the macro icon.
