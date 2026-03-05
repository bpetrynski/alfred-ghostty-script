# Alfred Ghostty Integration
Low-latency AppleScript integration between [Ghostty](https://ghostty.org/) and [Alfred](https://www.alfredapp.com/help/features/terminal/).

## Usage

1. Copy the [script](https://github.com/zeitlings/alfred-ghostty-script/blob/main/GhosttyAlfred.applescript) to your clipboard
2. In Alfred Preferences, navigate to `Features > Terminal > Application → Custom`
3. Paste the script into the text box
4. Optionally configure the script properties for your workflow

## Properties

- `open_new` (default: <kbd>t</kbd>) : choose where Alfred sends the command
  * <kbd>t</kbd> open a new tab
  * <kbd>n</kbd> open a new window
  * <kbd>d</kbd> open a new split
  * <kbd>qt</kbd> use the [Quick Terminal](https://ghostty.org/docs/features#macos)
- `run_cmd` (default: `true`) : run immediately or just paste
  * `true` paste and run the command
  * `false` paste the command without running
- `reuse_tab` (default: `false`) : keep focus in current tab instead of opening one
- `timeout_seconds` (default: `1.5`) : max wait for Ghostty window/focus readiness
- `shell_load_delay` (default: `0.0`) : extra settle delay before paste on slower machines
- `switch_delay` (default: `0.0`) : legacy compatibility delay before window actions
- `poll_delay` (default: `0.01`) : adaptive wait-loop polling interval

## Performance notes

- The script avoids temporary file I/O and writes command text to clipboard in one shell call.
- Fixed delays were reduced to near-zero defaults; waiting is mostly adaptive and state-driven.
- If commands paste too early on your machine, increase `shell_load_delay` slightly (for example `0.05` or `0.1`).
