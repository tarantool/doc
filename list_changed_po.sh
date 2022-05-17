#!/usr/bin/env bash

# The root directory of .po files
locale_path=locale/ru/LC_MESSAGES/

ESCAPED_REPLACE=$(printf '%s\n' "$locale_path" | sed -e 's/[\/&]/\\&/g')

unset CHANGED_POS

get_git_diff () {
  echo "$(git diff --name-only ; git ls-files . --exclude-standard --others)"
}

get_changed_po () {
  changed_po_files="$(get_git_diff | grep \\.po)"
  if [ -z "${changed_po_files}" ]; then
    echo "ERROR: changed .po files not found"
    return
  fi
  echo "$(get_git_diff | grep \\.po)"
}

get_po_base_names () {
  echo "$(get_changed_po | sed "s/.po//" | sed "s/$ESCAPED_REPLACE//")"
}

get_rst_from_diff () {
  echo $(git diff-tree --no-commit-id --name-only -r HEAD..origin/latest | grep .rst)
}

echo "* Getting changed .po files:"
changed_po="$(get_changed_po)"
echo $changed_po

echo
echo "* Getting a list of .rst files to compare with changed .po files:"
rst_from_diff=$(get_rst_from_diff)
echo $rst_from_diff

echo
echo "* Filtering corresponding .po files to the changed .rst in the closest commit:"
po_files_to_commit=$(get_po_base_names | awk -v rst="$rst_from_diff" -v locale_path=$locale_path 'rst ~ $0{ printf locale_path; print ""$0".po" }')
echo $po_files_to_commit

if [ -n "${po_files_to_commit}" ]; then
  export CHANGED_POS="$(echo $po_files_to_commit | tr "\n" " ")"
else
  echo "ERROR: could not find any matched po file to commit"
fi
