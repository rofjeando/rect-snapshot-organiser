tell application "Keynote Creator Studio"
	try
		-- Get list of open documents (this works)
		set docList to name of every document
		set docCount to count of documents
		
		-- Prepare result list
		set resultText to "Keynote Creator Studio - Open Documents (" & docCount & "):" & return
		
		repeat with i from 1 to docCount
			set currentDoc to document i
			set docName to name of currentDoc
			
			-- Get slide count (this works)
			set slideCount to count of slides of currentDoc
			
			-- Check if modified (this works)
			set isModified to modified of currentDoc
			
			-- Try to get first slide title if slides exist
			set firstSlideTitle to "N/A"
			if slideCount > 0 then
				try
					set firstSlideTitle to title of slide 1 of currentDoc
				on error
					set firstSlideTitle to "Error getting title"
				end try
			end if
			
			set resultText to resultText & return & i & ". " & docName & " (" & slideCount & " slides, Modified: " & isModified & ", First slide: " & firstSlideTitle & ")"
		end repeat
		
		return resultText
		
	on error errMsg number errNum
		return "ERROR: " & errMsg & " (Error " & errNum & ")"
	end try
end tell
