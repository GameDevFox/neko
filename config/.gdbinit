set prompt \n\033[1;32m(gdb)\033[0m 

add-auto-load-safe-path /home/fox/projects

tui new-layout main {-horizontal {src 1 asm 1} 1 cmd 1} 1 status 0

define ui
  layout mine
  focus cmd
end

define cpsr
  print/t ($cpsr & 0xff000000) >> (24 + 3)
end

define ir
  info registers
end

define qemu-connect
  target remote localhost:1234
  set scheduler-locking on
end

define pc
  set $count = 16

  if $argc == 1
    set $count = $arg0
  end

  eval "x/%di $pc", $count
end

# set disassemble-next-line on
