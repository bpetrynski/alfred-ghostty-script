-- AlfredGhostty Script v1.4.0
-- Latest version: https://github.com/zeitlings/alfred-ghostty-script

-- open_new : t(tab) | n(window) | d(split) | qt(quick terminal)
property open_new : "t"
property run_cmd : true -- false = paste only, do not press Return
property reuse_tab : false -- true = reuse active tab when possible
property timeout_seconds : 1.5 -- Max seconds to wait for window/focus readiness
property shell_load_delay : 0.0 -- Increase to 0.05-0.1 on slower machines
property switch_delay : 0.0 -- Legacy compatibility delay before window action
property poll_delay : 0.01 -- Adaptive wait-loop polling interval

on isRunning()
	application "Ghostty" is running
end isRunning

on summon()
	tell application "Ghostty" to activate
end summon

on hasWindows()
	if not isRunning() then return false
	tell application "System Events"
		if not (exists process "Ghostty") then return false
		return exists window 1 of process "Ghostty"
	end tell
end hasWindows

on isFrontmost()
	tell application "System Events"
		if not (exists process "Ghostty") then return false
		return frontmost of process "Ghostty"
	end tell
end isFrontmost

on waitForWindow(timeout_s)
	if hasWindows() then return true
	set end_time to (current date) + timeout_s
	repeat until ((current date) > end_time)
		if hasWindows() then return true
		delay poll_delay
	end repeat
	return hasWindows()
end waitForWindow

on waitForFrontmost(timeout_s)
	if isFrontmost() then return true
	set end_time to (current date) + timeout_s
	repeat until ((current date) > end_time)
		if isFrontmost() then return true
		delay poll_delay
	end repeat
	return isFrontmost()
end waitForFrontmost

on handleWindow(just_activated, had_windows)
	if just_activated then
		return false
	end if

	tell application "System Events"
		if not had_windows then
			keystroke "n" using command down -- New window
			return true
		end if

		if reuse_tab then
			return false
		end if

		if open_new is "d" then
			keystroke "d" using command down -- New split right
		else if open_new is "n" then
			keystroke "n" using command down -- New window
		else
			keystroke "t" using command down -- New tab
		end if
	end tell

	return true
end handleWindow

on copyCommandToClipboard(a_command)
	do shell script "printf %s " & quoted form of a_command & " | tr -d '\\n' | pbcopy"
end copyCommandToClipboard

on pasteCommand()
	tell application "System Events"
		tell process "Ghostty"
			keystroke "v" using command down
			if run_cmd then
				keystroke return
			end if
		end tell
	end tell
end pasteCommand

on sendByClipboard(a_command)
	set backup_ok to false
	set backup to missing value

	try
		set backup to the clipboard
		set backup_ok to true
	on error
		-- Ignore and sacrifice the clipboard contents
	end try

	copyCommandToClipboard(a_command)
	pasteCommand()

	if backup_ok then
		try
			set the clipboard to backup
		on error
			-- Ignore failed clipboard restore
		end try
	end if
end sendByClipboard

on send(a_command, just_activated)
	if switch_delay > 0 then delay switch_delay

	set had_windows to hasWindows()
	set created_surface to handleWindow(just_activated, had_windows)

	if just_activated or (not had_windows) then
		if not waitForWindow(timeout_seconds) then -- Additional fail-safe
			display dialog "Failed to verify window exists"
			return
		end if
	end if

	if just_activated or created_surface then
		if shell_load_delay > 0 then delay shell_load_delay
	end if

	if not waitForFrontmost(timeout_seconds) then
		display dialog "Ghostty did not become active"
		return
	end if

	sendByClipboard(a_command)
end send

on send_quick_terminal(a_command, needs_wakeup)
	if needs_wakeup then
		summon()
	end if

	if not waitForFrontmost(timeout_seconds) then
		display dialog "Ghostty did not become active"
		return
	end if
	
	tell application "System Events"
		tell process "Ghostty"
			set viewMenu to menu 1 of menu bar item "View" of menu bar 1
			set quickTermItem to menu item "Quick Terminal" of viewMenu
			click quickTermItem
		end tell
	end tell

	if shell_load_delay > 0 then delay shell_load_delay
	sendByClipboard(a_command)
end send_quick_terminal

on alfred_script(query)
	
	if open_new is "qt" then
		send_quick_terminal(query, not isRunning())
	else
		set just_activated to not isRunning()
		summon()
		if just_activated then
			if not waitForWindow(timeout_seconds) then
				display dialog "Failed to create initial window"
				return
			end if
		end if
		send(query, just_activated)
	end if
end alfred_script
