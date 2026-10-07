# Generating Valid KM Macro XML Files for Import

How to create `.kmmacros` files that Keyboard Maestro will accept on double-click.  
Discovered through iterative testing — July 2026.

---

## The Two Formats (and Which One Works for Import)

KM uses two distinct XML formats:

| Format | Structure | Used for |
|--------|-----------|----------|
| **Single-macro** | `<plist><dict>…</dict></plist>` | KM internal export / version control only |
| **Group-wrapper** | `<plist><array><dict>Macros…</dict></array></plist>` | Double-click import ✅ |

**Always use the group-wrapper format for importable files.** The single-macro format gives "The Macro File you selected is of an unknown format."

---

## Group-Wrapper Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <!-- GROUP properties -->
        <key>Activate</key>
        <string>Normal</string>
        <key>CreationDate</key>
        <real>801838902.04469204</real>   <!-- Core Data timestamp (seconds since 2001-01-01) -->
        <key>Macros</key>
        <array>
            <dict>
                <!-- MACRO properties (see below) -->
            </dict>
        </array>
        <key>Name</key>
        <string>Group Name Here</string>
        <key>UID</key>
        <string>XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX</string>
    </dict>
</array>
</plist>
```

### Import behaviour based on group UID

- **Unknown UID** → KM creates a **new group** with the given name
- **Matching UID** → KM **merges** the macro into the existing group (existing macros are untouched)

Use a matching UID to inject a macro into a specific existing group.

> ⚠️ **Known exception — `__Palette Zoom`**: the UID `EFF5488F-6CD0-4713-8A6D-F1D617105572`
> does **not** trigger a merge. KM creates a duplicate group with the same name instead.
> Workaround: after import, manually drag the macro into the real `__Palette Zoom` group
> and delete the duplicate. The `_[ZOOM]  Zoom App ` group (`035585B5-…`) merges correctly.

---

## Macro Structure

```xml
<dict>
    <key>Actions</key>
    <array>
        <!-- one <dict> per action -->
    </array>
    <key>CreationDate</key>
    <real>805700000.0</real>
    <key>ModificationDate</key>
    <real>805700000.0</real>
    <key>Name</key>
    <string>My Macro Name</string>
    <key>Triggers</key>
    <array/>   <!-- empty = no trigger assigned -->
    <key>UID</key>
    <string>XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX</string>
</dict>
```

**Imported macros always arrive disabled** — enable them manually in KM after verifying they look correct.

---

## UID Rules

UIDs must be valid UUIDs: format `8-4-4-4-12` hex characters.  
Valid hex: `0–9` and `A–F` (uppercase). **No G, H, or other letters.**

```
✅  C9E2F5B3-4D6A-8091-BF23-A47986C5D172
❌  C9E2F5B3-4D6A-8091-BF23-G47986C5D172   ← G is not hex
```

Each macro and each action must have a **unique ActionUID** (integer). Use a range like `300xxxxxx` for AI-generated macros to avoid collisions with KM's own ActionUIDs.

---

## Finding an Existing Group's UID

To import into a specific group (rather than creating a new one), find its UID from KM's database:

```bash
# Step 1 — convert KM's binary plist to readable XML
plutil -convert xml1 \
  ~/Library/Application\ Support/Keyboard\ Maestro/Keyboard\ Maestro\ Macros.plist \
  -o /tmp/km_macros.xml

# Step 2 — find your group
python3 -c "
import xml.etree.ElementTree as ET
tree = ET.parse('/tmp/km_macros.xml')
root = tree.getroot()
top_dict = root.find('dict')
children = list(top_dict)
for i in range(0, len(children)-1, 2):
    k, v = children[i], children[i+1]
    if k.tag == 'key' and k.text == 'MacroGroups':
        for group in v:
            gc = list(group)
            gdata = {}
            for j in range(0, len(gc)-1, 2):
                gdata[gc[j].text] = gc[j+1].text or ''
            name = gdata.get('Name', '')
            uid  = gdata.get('UID', '')
            if 'YOUR_GROUP_NAME' in name:   # ← change this
                print(f'Group: {name}')
                print(f'UID:   {uid}')
"
```

Replace `YOUR_GROUP_NAME` with a substring of the group name you want.

---

## Common Action Types

### Execute Shell Script (external file)
```xml
<dict>
    <key>ActionUID</key>
    <integer>300000001</integer>
    <key>DisplayKind</key>
    <string>None</string>
    <key>HonourFailureSettings</key>
    <true/>
    <key>IncludeStdErr</key>
    <false/>
    <key>IncludedVariables</key>
    <array><string>9999</string></array>
    <key>MacroActionType</key>
    <string>ExecuteShellScript</string>
    <key>Path</key>
    <string>/path/to/script.sh</string>
    <key>Source</key>
    <string>Nothing</string>
    <key>Text</key>
    <string></string>
    <key>TimeOutAbortsMacro</key>
    <true/>
    <key>TrimResults</key>
    <true/>
    <key>TrimResultsNew</key>
    <true/>
    <key>UseText</key>
    <false/>
</dict>
```

### Pause
```xml
<dict>
    <key>ActionUID</key>
    <integer>300000002</integer>
    <key>MacroActionType</key>
    <string>Pause</string>
    <key>Time</key>
    <string>.5</string>
    <key>TimeOutAbortsMacro</key>
    <true/>
</dict>
```

### Activate Application
```xml
<dict>
    <key>ActionUID</key>
    <integer>300000003</integer>
    <key>AllWindows</key>
    <true/>
    <key>AlreadyActivatedActionType</key>
    <string>Normal</string>
    <key>Application</key>
    <dict>
        <key>BundleIdentifier</key>
        <string>com.apple.finder</string>
        <key>Name</key>
        <string>Finder</string>
        <key>NewFile</key>
        <string>/System/Library/CoreServices/Finder.app</string>
    </dict>
    <key>MacroActionType</key>
    <string>ActivateApplication</string>
    <key>ReopenWindows</key>
    <false/>
    <key>TimeOutAbortsMacro</key>
    <true/>
</dict>
```

### Set Variable to Text
```xml
<dict>
    <key>ActionUID</key>
    <integer>300000004</integer>
    <key>MacroActionType</key>
    <string>SetVariableToText</string>
    <key>Text</key>
    <string>value here</string>
    <key>Variable</key>
    <string>myVariableName</string>
</dict>
```

### If / Then / Else
```xml
<dict>
    <key>ActionUID</key>
    <integer>300000005</integer>
    <key>Conditions</key>
    <dict>
        <key>ConditionList</key>
        <array>
            <dict>
                <key>ConditionType</key>
                <string>Variable</string>
                <key>Variable</key>
                <string>myVar</string>
                <key>VariableConditionType</key>
                <string>Is</string>
                <key>VariableValue</key>
                <string>yes</string>
            </dict>
        </array>
        <key>ConditionListMatch</key>
        <string>All</string>
    </dict>
    <key>ElseActions</key>
    <array/>
    <key>MacroActionType</key>
    <string>IfThenElse</string>
    <key>ThenActions</key>
    <array>
        <!-- actions go here -->
    </array>
    <key>TimeOutAbortsMacro</key>
    <true/>
</dict>
```

---

## Workflow: AI Creates or Modifies a Macro (2026-07 system)

The current system uses `[EXM]` (export) and `[IMP]` (import) macros in `__[KMo] kmOrganiser` to automate group placement. Claude never needs to be told which group to use — it reads the groupUUID from the export log.

### Step-by-step

1. **Export** the original macro using `exm,,` → file saved to `implementation/km_macros/`, export log written and opened in BBEdit.  
   The log line includes:  
   ```
   MacroName. |. macroUUID  | groupUUID: GROUP-UUID
   groupName: GROUP-NAME |.
   ```
2. **Paste** the export log + macro XML to Claude.
3. **Claude** modifies the XML and writes it to `implementation/km_macros/` as `MacroName [Claude Import Test].kmmacros`.  
   Claude **always** embeds an `IMP_META` Comment as the **first action** (see below).
4. **Import** using `imp,,` → `[IMP]` reads `IMP_META` from the file, selects the correct group in KM Editor, imports the macro. No manual group selection needed.
5. **Verify** in KM (macro arrives disabled). Enable and test.
6. **Export** the final version with `exm,,` and commit to git.

---

## IMP_META — group info embedded in the file

Claude adds this as the **first action** in every `.kmmacros` it creates or modifies:

```xml
<dict>
    <key>ActionColor</key>
    <string>Blue</string>
    <key>ActionName</key>
    <string>IMP_META</string>
    <key>ActionUID</key>
    <integer>300000001</integer>
    <key>IsActive</key>
    <false/>
    <key>MacroActionType</key>
    <string>Comment</string>
    <key>Title</key>
    <string>groupUUID: [GROUP-UUID from export log]
groupName: [GROUP-NAME from export log]</string>
</dict>
```

**Why file-embedded, not a KM variable:** `exm_GroupData` (the KM variable set by `[EXM]`) can be overwritten by any subsequent `[EXM]` run between export and import. The `IMP_META` comment travels with the file, making the round-trip reliable even days or weeks later.

**`[IMP]` extracts it with:**
```python
import plistlib
with open(filePath, 'rb') as f:
    data = plistlib.load(f)
for action in data.get('Actions', []):
    if action.get('ActionName') == 'IMP_META':
        title = action.get('Title', '')  # contains groupUUID + groupName
        break
```

---

## File format for [IMP]-based imports

Use the **standalone single-macro format**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist ...>
<plist version="1.0">
<dict>          ← NOT <array>
    <key>Actions</key>
    <array>
        <!-- IMP_META first, then real actions -->
    </array>
    <key>Name</key>
    <string>My Macro [Claude Import Test]</string>
    <key>UID</key>
    <string>NEW-UNIQUE-UUID</string>
    ...
</dict>
</plist>
```

`[IMP]` selects the group via AppleScript before importing, so the group-wrapper format is not needed and should be avoided (it causes duplicate groups for some group UIDs).

---

## Getting the group UID (without [EXM])

If `[EXM]` was not used, find the group UID from KM's database:

```bash
plutil -convert xml1 \
  ~/Library/Application\ Support/Keyboard\ Maestro/Keyboard\ Maestro\ Macros.plist \
  -o /tmp/km_macros.xml

python3 -c "
import xml.etree.ElementTree as ET
tree = ET.parse('/tmp/km_macros.xml')
root = tree.getroot()
top_dict = root.find('dict')
children = list(top_dict)
for i in range(0, len(children)-1, 2):
    k, v = children[i], children[i+1]
    if k.tag == 'key' and k.text == 'MacroGroups':
        for group in v:
            gc = list(group)
            gdata = {}
            for j in range(0, len(gc)-1, 2):
                gdata[gc[j].text] = gc[j+1].text or ''
            name = gdata.get('Name', '')
            uid  = gdata.get('UID', '')
            if 'YOUR_GROUP_NAME' in name:
                print(f'Group: {name}')
                print(f'UID:   {uid}')
"
```

---

## Checklist Before Importing via [IMP]

- [ ] `IMP_META` is the **first** action in the `Actions` array
- [ ] `groupUUID` in `IMP_META` matches the intended KM group
- [ ] Root element is `<dict>` (standalone format, not `<array>`)
- [ ] All UIDs are valid hex (0–9, A–F only), format `8-4-4-4-12`
- [ ] Macro UID is different from the original (if creating a test copy)
- [ ] All `ActionUID` integers are unique within the macro and in the `300xxxxx` range
- [ ] File is saved as `.kmmacros`
