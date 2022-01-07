import importlib
import gdb
import sys

mode_names = {
  0b10000: "user",
  0b10001: "fiq",
  0b10010: "irq",
  0b10011: "supervisor",
  0b10110: "monitor",
  0b10111: "abort",
  0b11010: "hyp",
  0b11011: "undefined",
  0b11111: "system",
}

def get_bits(value, low_bit, high_bit):
  shifted = value >> low_bit
  mask_size = high_bit - low_bit + 1
  mask = (1 << mask_size) - 1
  return shifted & mask

def split_bits(value, *parts):
  result = []

  low_bit = parts[0];
  for i in range(1, len(parts)):
    high_bit = parts[i] - 1
    segment = get_bits(value, low_bit, high_bit)
    result.append(segment)
    low_bit = high_bit + 1

  return result

def enabled_str(value):
  return "enabled" if value else "disabled"

class CPSRCmd(gdb.Command):
  def __init__(self):
    super(CPSRCmd, self).__init__(
      "cpsr", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    cpsr = int(gdb.selected_frame().read_register("cpsr"))
    print(hex(cpsr))

    n = cpsr & 1 << 31
    z = cpsr & 1 << 30
    c = cpsr & 1 << 29
    v = cpsr & 1 << 28
    q = cpsr & 1 << 27

    e = cpsr & 1 << 9
    a = cpsr & 1 << 8
    i = cpsr & 1 << 7
    f = cpsr & 1 << 6
    t = cpsr & 1 << 5

    mode = cpsr & (1 << 5) - 1
    mode_name = str(mode_names.get(mode))

    gdb.write('N' if n else 'n')
    gdb.write('Z' if z else 'z')
    gdb.write('C' if c else 'c')
    gdb.write('V' if v else 'v')
    gdb.write('Q' if q else 'q')
    gdb.write(' ')

    gdb.write('BE' if e else 'le')
    gdb.write(' ')

    gdb.write('A' if a else 'a')
    gdb.write('I' if i else 'i')
    gdb.write('F' if f else 'f')
    gdb.write(' ')

    gdb.write('T' if t else 't')
    gdb.write(f" {mode_name} ({hex(mode)})\n")

CPSRCmd()

class MIDRCmd(gdb.Command):
  def __init__(self):
    super(MIDRCmd, self).__init__(
      "midr", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    midr = int(gdb.selected_frame().read_register("MIDR"))
    print(hex(midr))
   
    parts = split_bits(midr, 0, 4, 16, 20, 24, 32)
    revision, primary_part_number, arch, variant, implementer = parts

    print(f"{chr(implementer)} {hex(variant)}")
    print(f"architecture: {hex(arch)}")
    print(f"primary part number: {hex(primary_part_number)}")
    print(f"revision: {hex(revision)}")

MIDRCmd()

class SCTLRCmd(gdb.Command):
  def __init__(self):
    super(SCTLRCmd, self).__init__(
      "sctlr", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    secure = len(args)
    reg_name = "SCTLR_S" if secure else "SCTLR"
    sctlr = int(gdb.selected_frame().read_register(reg_name))
    print(hex(sctlr))

    parts = split_bits(sctlr, 0, 1, 2, 3, 10, 11, 12, 13, 14, 24, 25, 27, 28)
    m, a, c, _, sw, z, i, v, _, ve, _, nmfi = parts

    print(f"{nmfi} {ve} {v} {i} {z} {sw}")
    print(f"Cache: {enabled_str(c)}")
    print(f"Alignment check: {enabled_str(a)}")
    print(f"MMU: {enabled_str(m)}")

SCTLRCmd()

class SCRCmd(gdb.Command):
  def __init__(self):
    super(SCRCmd, self).__init__(
      "scr", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    scr = int(gdb.selected_frame().read_register("SCR"))
    print(hex(scr))

    ns, irq, fiq_ = split_bits(scr, 0, 1, 2, 3)

    mode = "Non-Secure" if ns else "Secure"
    print(f"Mode: {mode}")

SCRCmd()

class TTBCRCmd(gdb.Command):
  def __init__(self):
    super(TTBCRCmd, self).__init__(
      "ttbcr", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    ttbcr = int(gdb.selected_frame().read_register("TTBCR"))
    print(hex(ttbcr))

    n, _, eae = split_bits(ttbcr, 0, 3, 31, 32)

    print(f"{eae} {n}")

TTBCRCmd()

class ReloadCmd(gdb.Command):
  def __init__(self):
    super(ReloadCmd, self).__init__(
      "reload", gdb.COMMAND_USER
    )

  def invoke(self, args, from_tty):
    importlib.reload(sys.modules['neko'])

ReloadCmd()

class Greet(gdb.Function):
    "It's party time"

    def __init__(self):
        super(Greet, self).__init__("greet_it")

    def invoke(seld, name):
        return "How you doing, %s!" % name.string()

Greet()
