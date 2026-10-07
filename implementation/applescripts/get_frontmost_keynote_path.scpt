-- Get file path of the frontmost Keynote Creator Studio document
-- Uses the same simple file property method

tell application "Keynote Creator Studio"
	try
		set frontDoc to front document
		
		try
			set docFile to file of frontDoc
			set posixPath to POSIX path of docFile
			return posixPath
		on error
			-- If file property fails, use document name
			set docName to name of frontDoc
			return "[No file path] " & docName
		end try
		
	on error errMsg number errNum
		return "ERROR: " & errMsg & " (Error " & errNum & ")"
	end try
end tell
