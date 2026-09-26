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
