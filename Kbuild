# SPDX-License-Identifier: GPL-2.0
#
# Kbuild for top-level directory of the kernel
# This file takes care of the following:
# 1) Generate bounds.h
# 2) Generate timeconst.h
# 3) Generate asm-offsets.h (may need bounds.h and timeconst.h)
# 4) Check for missing system calls
# 5) Generate constants.py (may need bounds.h)

#####
# 1) Generate bounds.h

bounds-file := include/generated/bounds.h

always  := $(bounds-file)
targets := kernel/bounds.s

$(bounds-file): kernel/bounds.s FORCE
	$(call filechk,offsets,__LINUX_BOUNDS_H__)

#####
# 2) Generate timeconst.h

timeconst-file := include/generated/timeconst.h

targets += $(timeconst-file)

filechk_gentimeconst = echo $(CONFIG_HZ) | bc -q $<

$(timeconst-file): kernel/time/timeconst.bc FORCE
	$(call filechk,gentimeconst)

#####
# 3) Generate asm-offsets.h
#

offsets-file := include/generated/asm-offsets.h

always  += $(offsets-file)
targets += arch/$(SRCARCH)/kernel/asm-offsets.s

arch/$(SRCARCH)/kernel/asm-offsets.s: $(timeconst-file) $(bounds-file)

$(offsets-file): arch/$(SRCARCH)/kernel/asm-offsets.s FORCE
	$(call filechk,offsets,__ASM_OFFSETS_H__)

#####
# 4) Check for missing system calls
#

always += missing-syscalls
targets += missing-syscalls

quiet_cmd_syscalls = CALL    $<
      cmd_syscalls = $(CONFIG_SHELL) $< $(CC) $(c_flags) $(missing_syscalls_flags)

missing-syscalls: scripts/checksyscalls.sh $(offsets-file) FORCE
	$(call cmd,syscalls)

#####
# 5) Generate constants for Python GDB integration
#

#extra-$(CONFIG_GDB_SCRIPTS) += build_constants_py

#build_constants_py: $(timeconst-file) $(bounds-file) FORCE
#	@$(MAKE) $(build)=scripts/gdb/linux $@

# Keep these three files during make clean
no-clean-files := $(bounds-file) $(offsets-file) $(timeconst-file)
