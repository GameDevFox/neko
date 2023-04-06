set history save on
set history remove-duplicates 1
set print pretty on
set prompt \n\033[1;32m(gdb)\033[0m

add-auto-load-safe-path /home/fox/projects

tui new-layout main {-horizontal {src 1 asm 1} 1 cmd 1} 1 status 0
tui new-layout main-plus {-horizontal {src 1 asm 1} 1 { regs 1 cmd 2 } 1 } 1 status 0

define ui
  layout main-plus
  #focus cmd
end

define ir
  info registers
end

define qemu-connect
  target remote localhost:1234
end

define pc
  set $count = 16

  if $argc == 1
    set $count = $arg0
  end

  eval "x/%di $pc", $count
end

python import os
python sys.path.insert(0, os.environ['HOME'] + "/.config/gdb/python")
python import neko

# set disassemble-next-line on
