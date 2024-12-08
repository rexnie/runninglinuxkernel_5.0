# SPDX-License-Identifier: GPL-2.0

ifdef building_out_of_srctree

symlinks := $(patsubst $(srctree)/$(src)/%,%,$(wildcard $(srctree)/$(src)/*.py))

quiet_cmd_symlink = SYMLINK $@
      cmd_symlink = ln -fsn $(patsubst $(obj)/%,$(abspath $(srctree))/$(src)/%,$@) $@

always-y += $(symlinks)
$(addprefix $(obj)/, $(symlinks)): FORCE
	$(call if_changed,symlink)

endif

quiet_cmd_gen_constants_py = GEN     $@
      cmd_gen_constants_py = \
	$(CPP) -E -x c -P $(c_flags) $< > $@ ;\
	sed -i '1,/<!-- end-c-headers -->/d;' $@

targets += constants.py
$(obj)/constants.py: $(obj)/constants.py.in FORCE
	$(call if_changed_dep,gen_constants_py)

build_constants_py: $(obj)/constants.py
       @:

clean-files := *.pyc *.pyo $(if $(KBUILD_SRC),*.py) $(obj)/constants.py
