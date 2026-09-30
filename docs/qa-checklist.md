# Clickety device checklist

## 1.0.0 RC

Walk this on an iPhone and an iPad. Tick each line. Headless tests are already required to pass on the computer.

## Counting

- [ ] First launch opens the counter at 0, with no dialogs.
- [ ] Tapping the middle adds one. Thirty quick taps add thirty. −1 stops at 0. Undo reverts the last action, including −1.
- [ ] Force-quit and reopen: the count is the same.
- [ ] Tap lock ignores taps. Holding the padlock unlocks. The locked state shows the padlock and “Locked — hold the padlock to unlock”.
- [ ] The screen stays awake on the counter. A haptic tick happens on each tap. With Tap sound on, a podcast keeps playing.
- [ ] Huge text at phone size, 640-wide, and iPad size: nothing is clipped, chips wrap instead of shrinking, and buttons are easy to hit.
- [ ] iPad: the column stays narrow and centered, the background fills the screen, and taps in the side margins still count. Portrait only.

## Projects

- [ ] Rename, set Crochet, set a target, and add notes with line breaks. The counter shows “of N” and a progress bar. Relaunch keeps all of it. Empty notes read “No notes yet”.
- [ ] A second project is locked until unlock. After unlock, each project keeps its own count and undo.
- [ ] History groups today’s taps. Deleting a project removes it from the list.
- [ ] Sample data (debug) still opens and counts, and a new project stays locked while pretend is off.

## Linked counters

- [ ] Repeat every 8: 16 taps → row 16, pattern 1/8, repeats 2. One more tap → row 17, pattern 2/8, repeats 2. Undo after a wrap restores all of them.
- [ ] An independent counter counts only while it is focused.
- [ ] A loop cannot be saved. A locked “add counter” shows a padlock and the word Unlock.

## Unlock

- [ ] The price comes from the App Store, not from a number typed into the app.
- [ ] Buying unlocks. Relaunch stays unlocked. Restore after reinstall unlocks again. Airplane mode after that stays unlocked.
- [ ] Cancelling a purchase leaves the app locked and shows no error.

## Settings and About

- [ ] Keep awake, haptics, tap sound, theme, text size, reduce motion, and swap hands change immediately and survive relaunch.
- [ ] High contrast is black, white, and yellow, and the text stays readable.
- [ ] About shows the app icon, the name Clickety, and the version.
- [ ] Restore purchases is on the settings screen.

## Widget

- [ ] Home Screen and Lock Screen widgets follow the count within a few seconds, and follow a project switch.
- [ ] A fresh install says “Unlock in Clickety” until the app is unlocked.
- [ ] On iOS 17, five + taps with the app killed show +5 on the widget. Opening the app adds those taps, advances repeats, and undo works one tap at a time.
- [ ] After a reboot, the widget still shows the last value.

## Alerts and reminder

- [ ] An every-6 alert banners at 6 and 12. An at-40 alert banners once.
- [ ] The daily reminder asks permission only when turned on. After allowing, the toggle stays on across relaunch.
- [ ] A reminder set a couple of minutes ahead still arrives after the app is force-quit.
- [ ] If permission is denied, the toggle stays off and the settings line says notifications are off for Clickety.

## Backup

- [ ] Save a backup. It appears in Files → On My iPhone → Clickety → Exports.
- [ ] Delete a project, then add it back from that file.
- [ ] After reinstall, copy the file back, restore, then Restore purchases.

## Review prompt

- [ ] No rating dialog of our own appears.
- [ ] On a normal new install, counting does not ask for a review during the first 3 days.
- [ ] Debug builds can press Settings → Ask for a review to exercise the StoreKit call. A release build does not show that row.
