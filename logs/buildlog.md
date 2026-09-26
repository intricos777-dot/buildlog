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

## 2026-09-26 13:45:33 · fix

faillock admin exemption PREPARED, NOT deployed (needs sudo). deploy-faillock-admin.sh orders it safely: backup -> create shield-admin -> enrol livings -> READ GROUP DB BACK -> only then install config naming admin_group, then write enroll.lock. Aborts if livings is not verifiably a member, because pam_faillock would otherwise lock the admin out like everyone else. Run: sudo ~/Projects/zen-hardening/deploy-faillock-admin.sh --check | deploy | --revert

## 2026-09-26 13:45:33 · fix

faillock: fixed 'audit = silent' (audit/silent are BARE FLAGS not key=value) and fixed group parsing that split on ',' instead of cutting field 4 from 'name:x:gid:mem1,mem2' -- old check passed unconditionally. unlock_time stays 30s, permanent lockout (0) NOT enabled: no other login users exist on this box anyway, and it is unrecoverable if the exemption breaks

## 2026-09-26 13:45:41 · note

pam_faillock facts confirmed from local man pages: (1) unlock_time=0 means NEVER - needs 'faillock --user X --reset' as root, and man page warns it is an easy DoS target; (2) default dir /var/run/faillock is tmpfs so tallies AND any permanent lock vanish on reboot - real permanence needs dir= off tmpfs; (3) admin_group members are handled like root, so setting even_deny_root would defeat the exemption entirely. Live /etc/security/faillock.conf had NO admin_group, so livings was lockable; recover with 'sudo faillock --user livings --reset'

## 2026-09-26 13:50:14 · note

1-day fail2ban lockout was ALREADY live: bantime=86400 on sshd + recidive jails in /etc/fail2ban/jail.d/shield-kitty.conf, matches repo. firewalld is now active with the workstation zone, so firewallcmd-rich-rules bans ARE enforceable. Fixed stale docs in unban-self.sh + fail2ban-coverage.md that wrongly claimed bantime=-1 permanent (89506fc)

## 2026-09-26 13:50:14 · note

SYSTEM SPOOFING IS ENTIRELY UNCOVERED: no arpwatch, no suricata, no zeek, no tcpdump, no tpm2-tools installed, and zero spoofing logic in any repo. fail2ban structurally CANNOT do this -- it parses auth logs for repeated failures and has no notion of ARP/DHCP/hostname/MAC spoofing or rogue-device impersonation. This needs different tooling, and installing it needs root

## 2026-09-26 13:50:18 · note

THREE REAL GAPS found auditing 'ban remote access for 1 day': (1) ignoreip includes 10.0.0.0/8 and this machine IS 10.197.250.246/8, so 16,777,216 addresses on the local network are permanently EXEMPT from banning -- fail2ban cannot ban 'another system' on this network at all. (2) sshd jail is INERT: sshd inactive, nothing listens on 22. (3) kdeconnectd is LAN-exposed on *:1716 tcp+udp with NO jail -- the only real remote surface, unmonitored

## 2026-09-26 13:53:39 · note

repo updated to match live: shield-kitty-fail2ban.local recidive enabled=true (c897508), confirmed deliberate by user, not drift. Repo and live now byte-identical on all functional lines. Preconditions verified before endorsing it: /var/log/fail2ban.log present (root:root 0600, 34K), loglevel=INFO in fail2ban.conf (below WARNING recidive silently never counts bans), backend=polling+logpath since the journal lacks fail2ban's own log. fail2ban-client -t passes with recidive on

## 2026-09-26 13:59:40 · ok

built ARP spoof detection (arpwatch 3.9-1 from extra, was entirely absent): arpwatch-spoof-alert.sh exec hook + arpwatch-spoof.service + install-arpwatch-spoof.sh, commit 3a65f5e. Alerts ONLY on flip-flop (one IP, two MACs); new hosts logged not alerted. NO auto-ban by design -- MAC randomisation makes flip-flops routine on a /8 with 16.7M other addresses, so a 24h ban would cut off colleagues; the 1-day ban stays with fail2ban where it keys on real auth attempts. 7/7 classification tests pass + live notify-send delivery verified. NOT INSTALLED, needs root

## 2026-09-26 13:59:40 · fix

corrected an earlier claim of mine: kdeconnectd is NOT LAN-exposed. systemctl says inactive/not-found because it is a KDE session autostart app (app-org.kde.kdeconnect.daemon@autostart.service), and the workstation zone bound to wlo1 returns no for 1716/tcp, 1716/udp and 5353/udp -- firewalld drops it. No jail needed and none is possible (the daemon writes no journal entries, so a jail would match nothing, same as the inert sshd jail)

## 2026-09-26 14:02:04 · fix

arpwatch installer aborted under sudo: 'hook not executable: /root/Projects/...'. sudo resets HOME to /root, so $HOME/Projects resolved into /root. Fixed by resolving the real home from SUDO_USER via getent and rewriting the unit path + Environment=HOME at install time. Also found a SECOND silent bug the same way: the hook is arpwatch's child, and arpwatch starts as root then drops privs with -u, which changes uid but NOT the environment -- so the hook had no DISPLAY/DBUS and every spoof notification failed while the log line still appeared. Fixed by reconstructing the session from /run/user/UID/bus. Verified: notify-send with only the bootstrapped vars exits 0, bare env fails 'Cannot autolaunch D-Bus'. commit b39490a

## 2026-09-26 14:15:15 · fix

arpwatch-spoof.service exited 1 in a restart loop: I used original-LBL-arpwatch flags, but the extra-repo 3.9 build has NO -a exec hook, no -u, no -c, and wants -i INTERFACE not positional. Rewrote detection to poll the datafile via arpwatch-spoof-scan.sh on a 2min timer, unit now uses -F -i wlo1 -f arp.dat -s -q -N -z (-N matters, this is a /8 so most traffic looks like a bogon). Found+fixed 3 bugs: comma-based MAC counting false-alarmed on same MAC with different case; stale state file swallowed a returning spoof; installer/scanner/unit disagreed on the datafile name. 12/12 tests pass incl. dedup lifecycle and 5000-row scale. commit 7dc7a07
