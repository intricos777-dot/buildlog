# Build Log

Durable journal of builds, audits, and fixes. Survives system rebuilds.

Format: one `## <timestamp> · <category>` section per entry.

## 2026-09-26 11:51:45 · build

started: hermes-blood: cloned via SSH, ran install.sh

## 2026-09-26 11:51:45 · fix

gtk/settings.ini: 'Great Vibes Bold' is not a real family -> fontconfig fell back to Noto Sans; changed to 'Great Vibes, 14'

## 2026-09-26 11:51:45 · fix

install.sh:75 sets Plasma icon theme to Blood but repo ships no icons/ dir -> all desktop icons would vanish; created ~/.local/share/icons/Blood inheriting BeautyLine,hicolor

## 2026-09-26 11:51:45 · ok

verified all 9 configs, valid TOML/JSON/YAML, konsole profile->colorscheme chain intact
## 2026-09-26 11:51:48 · env

```
os        : Garuda Linux
kernel    : 7.2.7-zen1-1-zen
node      : v26.10.0
python    : Python 3.14.7
opencode  : 1.18.32-1
hermes    : 0.21.5-1
```

## 2026-09-26 11:51:48 · FAIL

supercode: 4 install attempts, all failed - npm @kirmad/supercode and supercode both 404 Not Found

## 2026-09-26 11:51:48 · FAIL

void-bin: paru stuck 55min cloning all of Chromium (code.sh source redirects to chromium mirror); 0 bytes in 15s - AUR packaging bug

## 2026-09-26 11:51:48 · ok

hermes-agent 0.21.5-1 built via makepkg (126MB pkg.tar.zst) after swapping nodejs-lts-iron 20 -> nodejs 26.10.0

## 2026-09-26 11:51:48 · note

machine was rebuilt after a lockout; prior session history lost. 120 repos intact via git remote. Prime lockout suspect: Great Vibes as global KDE UI font (calligraphy, size 14, no bold/italic) reaching lock screen + dialogs

## 2026-09-26 11:57:30 · fix

fonts: bumped Great Vibes 10/12/14 -> 16pt across all 6 locations (kdeglobals font/fixed, gtk-3.0, gtk-4.0, gtkrc-2.0, Garuda.profile, alacritty). Repo sources + install.sh updated so it survives re-install. Great Vibes has only a Regular weight; added fontconfig synthetic-embolden rule at ~/.config/fontconfig/conf.d/99-greatvibes-bold.conf

## 2026-09-26 11:58:35 · fix

opencode: voidlit.json was installed but NEVER ACTIVATED - opencode.jsonc had no "theme" key, so the black/red theme was inert since first install. Fixed by adding theme:voidlit to opencode.jsonc, installing to ~/.config/opencode/theme/ as well as themes/, and adding an activation step to install.sh (string-aware comment stripper so URLs in $schema survive). Tested against 5 config shapes.

## 2026-09-26 11:58:35 · fix

fonts: Great Vibes 10/12/14 -> 16pt across all 6 locations; repo sources + install.sh updated (commit a38327d). No true bold available - font ships Regular only.
## 2026-09-26 12:55:27 · env

```
os        : Garuda Linux
kernel    : 7.2.7-zen1-1-zen
node      : v26.10.0
python    : Python 3.14.7
opencode  : 1.18.32-1
hermes    : 0.21.5-1
```

## 2026-09-26 13:03:00 · fix

install.sh: was applying Great Vibes as global KDE UI font on every re-install. buildlog:47 records a lockout with that as prime suspect (calligraphy, Regular-only weight, reaching lock screen + dialogs). Font is now opt-in via BLOOD_GLOBAL_FONT=1; icon theme still applies. Live kdeglobals font/fixed restored to Fira Sans, matching the menuFont/toolBarFont the rest of the file already used. hermes-blood 84b2707

## 2026-09-26 13:03:00 · fix

paru cache was wiped (~/.cache/paru/clone emptied, 6 repos incl. electron tarball + shallow chromium mirror). Re-cloned AUR electron34 and re-created the 1.3GB shallow chromium mirror (tag 132.0.6834.210, depth 1, refspec pinned to the single tag) so makepkg never full-clones again

## 2026-09-26 13:03:00 · note

git identity was only set in nyan-gfsf-alert; zen-hardening/hermes-blood/buildlog could not be committed at all. Set global user.name/user.email to Living_Sin <intricos777-dot@users.noreply.github.com>. buildlog auto-commit works now

## 2026-09-26 13:36:03 · fix

BDE hardlock was NOT installed, deliberately. Audit found install-hardlock.sh appended 'auth required pam_deny.so' to /etc/pam.d for login+sudo+gdm-password+sshd+su, and bde-auth exited non-zero on any exception, so a down daemon or missing socket = locked out of login/sudo/sshd. Fixed to fail open (bde-auth 359cc45): exit 2 = unavailable vs exit 1 = denied, BDE_FAILMODE defaults open, socket resolved via pwd not getuid (PAM runs as root), pam_deny.so removed, sshd opt-in, installer gains --dry-run + backups. NOT INSTALLED - needs sudo

## 2026-09-26 13:36:03 · ok

notifications already in place: shield-kitty-watch.service enabled+active, notify-send, no fullscreen takeover
