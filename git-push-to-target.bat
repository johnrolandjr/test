#!/bin/sh
#
# git-push-to-target: Push this commit to a branch specified in its
# commit description.
#
# Copyright (c) 2017 wchargin. Released under the MIT license.

set -eu

DIRECTIVE='wchargin-branch'  # any regex metacharacters should be escaped
BRANCH_PREFIX='wchargin-'

target_branch() {
    directive="$( \
        git show --pretty='%B' \
        | sed -n 's/^'"${DIRECTIVE}"': \([A-Za-z0-9_.-]\+\)$/\1/p' \
        ; )"
    if [ -z "${directive}" ]; then
        printf >&2 'error: missing "%s" directive\n' "${DIRECTIVE}"
        return 1
    fi
    if [ "$(printf '%s\n' "${directive}" | wc -l)" -gt 1 ]; then
        printf >&2 'error: multiple "%s" directives\n' "${DIRECTIVE}"
        return 1
    fi
    printf '%s%s\n' "${BRANCH_PREFIX}" "${directive}"
}

main() {
    if [ "${1:-}" = "--query" ]; then
        target_branch
        return
    fi
    remote="${1:-origin}"
    branch="$(target_branch)"
    set -x
    git push --force-with-lease "${remote}" HEAD:refs/heads/"${branch}"
}

main "$@"
