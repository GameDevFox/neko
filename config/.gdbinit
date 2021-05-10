print "From home directory"

add-auto-load-safe-path /home/fox/projects/raspberrypi-linux
add-auto-load-safe-path /home/fox/aur/arm-linux-gnueabihf-binutils/pkg/arm-linux-gnueabihf-binutils-debug

tui new-layout mine regs 1 asm 1 status 0 cmd 1
tui new-layout yours {-horizontal regs 1 asm 1 } 2 status 0 cmd 1

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

define ir
  info registers
end

define cpsr
  print/t ($cpsr & 0xff000000) >> (24 + 3)
end

# set scheduler-locking on
# set disassemble-next-line on
