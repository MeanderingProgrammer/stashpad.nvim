init := "tests/minit.lua"
settings := "{ minimal_init = " + quote(init) + ", sequential = true, keep_going = false }"

test:
  nvim --headless --noplugin -u {{init}} -c "PlenaryBustedDirectory tests {{settings}}"

update:
  # Updates types.lua & README.md
  python scripts/update.py
