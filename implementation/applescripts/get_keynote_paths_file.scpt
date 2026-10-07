-- Get file paths of all open Keynote Creator Studio documents
-- Use file property instead of document conversion

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
			try
				set docFile to file of currentDoc
				set posixPath to POSIX path of docFile
				set end of pathList to posixPath
			on error
				-- If file property fails, use document name
				set docName to name of currentDoc
				set end of pathList to "[No file path] " & docName
			end try
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
