# Keynote Creator Studio Automation Recovery Plan

## Problem Identified
- **Old**: Keynote (standard version)
- **New**: Keynote Creator Studio v15.2 
- **Issue**: AppleScript dictionary has changed significantly, breaking existing automation

## Critical Changes Found
1. **Application name changed**: `Keynote` → `Keynote Creator Studio`
2. **Broken properties**: `path`, `theme` no longer work on documents
3. **Working properties**: `name`, `slide count`, `modified` status
4. **Slide properties**: Some slide-level properties may have changed

## Immediate Fixes Required

### 1. Update All AppleScript References
**FIND**: `tell application "Keynote"`
**REPLACE**: `tell application "Keynote Creator Studio"`

### 2. Fix Broken Document Properties
**REMOVE/REPLACE**:
- `path of document` → Use alternative file detection methods
- `theme of document` → May need different approach or remove dependency

### 3. Update Keyboard Maestro Macros
- Any KM action that targets "Keynote" must target "Keynote Creator Studio"
- AppleScript actions need updated application references
- UI-based actions may need element re-identification

## Working AppleScript Templates

### Basic Document Listing (Working)
```applescript
tell application "Keynote Creator Studio"
    set docList to name of every document
    set docCount to count of documents
    -- Add your logic here
end tell
```

### Safe Document Operations
```applescript
tell application "Keynote Creator Studio"
    try
        set currentDoc to document 1
        set docName to name of currentDoc
        set slideCount to count of slides of currentDoc
        set isModified to modified of currentDoc
        -- Safe operations here
    on error errMsg
        -- Handle errors gracefully
    end try
end tell
```

## Next Steps
1. Inventory all existing Keynote automation scripts
2. Update application references in all scripts
3. Test and fix broken property references
4. Update KM macros with new application targeting
5. Implement alternative methods for file path detection
6. Test all automation thoroughly

## Files Created
- `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KeynoteOrganiser/test_keynote_connection.scpt`
- `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KeynoteOrganiser/list_documents_working.scpt`
- `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/KeynoteOrganiser/KEYNOTE_RECOVERY_PLAN.md`
