init := "tests/minimal_init.lua"
settings := "{ minimal_init = " + quote(init) + ", sequential = true, keep_going = false }"

default: update test

update:
  # keep documentation in sync with code
  python scripts/update.py
  # https://github.com/kdheepak/panvimdoc
  ../../tools/panvimdoc/panvimdoc.sh \
    --project-name stashpad \
    --input-file README.md

test:
  nvim --headless --noplugin -u {{init}} -c "PlenaryBustedDirectory tests {{settings}}"
