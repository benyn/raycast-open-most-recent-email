#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Show Mailbox
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ✉️
# @raycast.packageName Mail
# @raycast.argument1 { "type": "text", "placeholder": "Mailbox name" }

# Documentation:
# @raycast.description Show the mailbox whose name matches the given text in Mail.app
# @raycast.author Ben Yoon
# @raycast.authorURL https://github.com/benyn

on run argv
  set mailboxName to item 1 of argv
  set capitalizedMailboxName to capitalizeFirstCharacter(mailboxName)
  set reversedPathElements to reverse of parseMailboxPath(mailboxName)
  tell application "Mail"
    set theMailbox to missing value
    -- first, try to get exact name matches
    repeat with theAccount in accounts
      if mailbox mailboxName of theAccount exists then
        set theMailbox to mailbox mailboxName of theAccount
        exit repeat
      end if
      if mailbox capitalizedMailboxName of theAccount exists then
        set theMailbox to mailbox capitalizedMailboxName of theAccount
        exit repeat
      end if
    end repeat
    -- if not found, iterate over all mailboxes in each account
    if theMailbox is missing value then
      repeat with theAccount in accounts
        repeat with mb in mailboxes of theAccount
          if length of reversedPathElements is 1 then
            if name of mb contains mailboxName then
              set theMailbox to mb
              exit repeat
            end if
          else
            set currentMailbox to mb
            set allPathElementsMatch to true
            repeat with i from 1 to length of reversedPathElements
              if (name of currentMailbox) contains item i of reversedPathElements then
                set currentMailbox to container of mb
              else
                set allPathElementsMatch to false
                exit repeat
              end if
            end repeat
            if allPathElementsMatch then
              set theMailbox to mb
              exit repeat
            end if
          end if
        end repeat
        if theMailbox is not missing value then
          exit repeat
        end if
      end repeat
    end if
    if theMailbox is not missing value then
      if not (front message viewer exists) then make new message viewer
      set selected mailboxes of front message viewer to theMailbox
      activate
    else
      log "Mailbox \"" & mailboxName & "\" not found"
    end if
  end tell
end run

on capitalizeFirstCharacter(theString)
  if length of theString is 0 then
    return theString
  end if
  set firstChar to character 1 of theString
  set charID to id of firstChar
  if 97 ≤ charID and charID ≤ 122 then
    set uppercaseChar to character id (charID - 32)
    if length of theString > 1 then
      return uppercaseChar & characters 2 thru -1 of theString
    else
      return uppercaseChar
    end if
  else
    return theString
  end if
end capitalizeFirstCharacter

on parseMailboxPath(thePath)
  -- save delimiters to restore old settings
  set oldDelimiters to AppleScript's text item delimiters
  -- set delimiters to delimiter to be used
  set AppleScript's text item delimiters to "/"
  -- create the array
  set theArray to every text item of thePath
  -- restore the old setting
  set AppleScript's text item delimiters to oldDelimiters
  -- return the result
  return theArray
end parseMailboxPath
