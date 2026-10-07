--/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/rect-snapshot_organiser/implementation/applescripts/resizeImages&insertInKeynoteFront_WORKING.scpt
-- WORKING version for Keynote Creator Studio compatibility
-- This version creates slides with default layout and inserts images

set kmInst to system attribute "KMINSTANCE"
tell application "Keyboard Maestro Engine"
	set thisList to getvariable "snagit_imageList" instance kmInst
end tell

set theseImageFiles to paragraphs of thisList

-- remove Empty lines in theseImageFiles
if last item of theseImageFiles is "" then
	set theseImageFiles to items 1 thru -2 of theseImageFiles
end if

-- resize images to y:600
-- the resized images are stored in: /Users/tsukadjed/Dropbox/imageTransit_Keynote
repeat with i from 1 to (count theseImageFiles)
	set fileName to name of (info for (item i of theseImageFiles))
	set newFile to "/Users/tsukadjed/Dropbox/imageTransit_Keynote" & "/" & fileName
	
	-- use full path to sips to avoid PATH issues
	do shell script ("/usr/bin/sips --resampleHeight 600 " & ¬
		quoted form of (item i of theseImageFiles) & " --out " & ¬
		quoted form of newFile)
	
	set item i of theseImageFiles to newFile -- Keep as POSIX path string
end repeat

tell application "Keynote Creator Studio"
	activate
	set frontDoc to front document
	
	repeat with i from 1 to the count of theseImageFiles
		set thisImageFile to item i of theseImageFiles
		
		-- Create a new slide with default layout
		set newSlide to make new slide at frontDoc
		
		-- Insert image into the new slide
		try
			set imageFile to POSIX file thisImageFile
			tell newSlide
				set newImage to make new image with properties {file:imageFile}
			end tell
		on error imgErr
			log "Failed to insert image " & thisImageFile & ": " & imgErr
		end try
	end repeat
end tell

return "Inserted " & (count of theseImageFiles) & " images into Keynote"
