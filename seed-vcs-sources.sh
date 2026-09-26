#!/bin/bash
# seed-vcs-sources.sh — pre-seed makepkg's VCS sources as shallow mirrors.
#
# Why: makepkg's download_git() runs `git clone --origin=origin --mirror` for
# any git+ source that is not already present. For git+https://github.com/
# chromium/chromium.git that is a 37 GiB full-history mirror (29.5M objects)
# and it dies mid-transfer. For the ~164 chromium-mirror_* DEPS repos it is
# merely slow, because a full history is never needed to build a pinned tree.
#
# What: for each git+ source, create the bare repo makepkg expects, pinned to
# exactly the ref it asked for, fetched at depth 1. download_git() then sees a
# non-empty dir, verifies remote.origin.url matches, and only runs
# `git fetch --all -p` (cheap, and a failure is only a warning). extract_git()
# clones from it locally and checks out the pin.
#
# Usage:  seed-vcs-sources.sh <pkgbuild-dir>
# Idempotent: skips any source that is already seeded.

set -uo pipefail

PKGDIR="${1:?usage: seed-vcs-sources.sh <pkgbuild-dir>}"
PKGBUILD="$PKGDIR/PKGBUILD"
[ -f "$PKGBUILD" ] || { echo "no PKGBUILD at $PKGBUILD" >&2; exit 1; }

TAG=$(grep -m1 -oE 'chromium-mirror::git\+[^#]+#tag=[0-9.]+' "$PKGBUILD" | sed 's/.*#tag=//')
echo "chromium tag: ${TAG:-<none>}"

seed_one() {
    local name="$1" url="$2" frag="$3"
    local dest="$PKGDIR/$name"

    # Already seeded and non-empty -> nothing to do.
    if [ -d "$dest" ] && [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
        echo "  skip   $name (already present)"
        return 0
    fi

    local ref
    case "$frag" in
        tag=*)     ref="refs/tags/${frag#tag=}" ;;
        branch=*)  ref="refs/heads/${frag#branch=}" ;;
        commit=*)  ref="" ;;   # handled below
        *)         ref="refs/heads/HEAD" ;;
    esac

    rm -rf "$dest"
    git init --bare --quiet "$dest" 2>/dev/null || { echo "  FAIL   $name (init)"; return 1; }
    git -C "$dest" remote add origin "$url" 2>/dev/null
    git -C "$dest" config remote.origin.tagOpt --no-tags

    if [ -n "$ref" ]; then
        git -C "$dest" config remote.origin.fetch "+${ref}:${ref}"
        if git -C "$dest" fetch --depth 1 --no-tags origin "${ref}:${ref}" >/dev/null 2>&1; then
            echo "  ok     $name ($frag)"
            return 0
        fi
    fi

    # commit= pin: most hosts refuse a bare-SHA fetch unless we ask for the
    # ref that contains it. Try the pin directly (googlesource allows this),
    # then fall back to the default branch at depth 1 and search the history.
    if [ "${frag#commit=}" != "$frag" ]; then
        local sha="${frag#commit=}"
        if git -C "$dest" fetch --depth 1 --no-tags origin "$sha" >/dev/null 2>&1; then
            git -C "$dest" config remote.origin.fetch "+refs/heads/*:refs/heads/*"
            echo "  ok     $name (direct sha)"
            return 0
        fi
    fi

    # Last resort: shallow default branch. makepkg will fetch the rest.
    rm -rf "$dest"
    git init --bare --quiet "$dest" 2>/dev/null
    git -C "$dest" remote add origin "$url" 2>/dev/null
    if git -C "$dest" fetch --depth 50 --no-tags origin '+refs/heads/*:refs/heads/*' >/dev/null 2>&1; then
        echo "  warn   $name (shallow branch, pin may need a fetch)"
        return 0
    fi

    echo "  FAIL   $name ($url)"
    return 1
}

# chromium itself first — it is the one that actually dies.
if [ -n "$TAG" ]; then
    echo "== chromium (37 GiB if done wrong) =="
    seed_one "chromium-mirror" "https://github.com/chromium/chromium.git" "tag=$TAG"
fi

echo
echo "== DEPS repos =="
# shellcheck disable=SC2013
sed -n '/^source=(/,/^)/p' "$PKGBUILD" \
  | grep -oE '[A-Za-z0-9_.-]+::git\+https?://[^#]+' \
  | while IFS= read -r entry; do
        name="${entry%%::*}"
        rest="${entry#*::git+}"
        url="${rest%%#*}"
        frag=""
        case "$rest" in
            *"#"*) frag="${rest#*#}" ;;
        esac
        url="${url%.git}"
        [ "$name" = "chromium-mirror" ] && continue
        seed_one "$name" "$url" "$frag"
    done

echo
echo "done. verify with: du -sh $PKGDIR"
