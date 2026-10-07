-- Get POSIX file paths of all open Keynote Creator Studio documents
-- Simple version - just convert document items to POSIX files

tell application "Keynote Creator Studio"
	try
		set docList to every document
		set docCount to count of docList
		set pathList to {}
		
		if docCount = 0 then
			return "No Keynote documents open"
		end if
		
		repeat with i from 1 to docCount
			set currentDoc to item i of docList
			set posixPath to POSIX file (currentDoc as string)
			set end of pathList to posixPath
		end repeat
		
		-- Return as line-break separated list for KM
		set AppleScript's text item delimiters to "
"
		set resultString to pathList as string
		set AppleScript's text item delimiters to ""
		
		return resultString
		
	on error errMsg number errNum
		return "ERROR: " & errMsg & " (Error " & errNum & ")"
	end try
end tell
