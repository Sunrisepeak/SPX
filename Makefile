# @Author: SPeak Shen 
# @Date: 2020-03-19 21:08:59 

include tools/makefile/function.mk

# project dir
ROOT_DIR = ./

# compiler Info
CC := gcc
C_FLAGS	:= -march=i686 -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc -fno-stack-protector -Os

# ld Info
LD := ld
LD_FLAGS = -m elf_i386 -nostdlib -N

# obj, bin dir
OBJ_DIR := obj/
BIN_DIR := bin/

# libs and include
LIBS_DIR := libs/
INCLUDE := $(addprefix -I,$(LIBS_DIR))

# branch
mbr_block := bin/mbr_block
kernel := bin/kernel
spx_img := bin/spx.img


main : $(mbr_block) $(kernel) $(spx_img)
	@echo + spx.img
	$(call exeShellScript,create_img.sh,$(spx_img),$(mbr_block),$(kernel))
	@echo success, create spx.img


# --------------------------------Create mbr_block Start--------------------------->>>

# boot dir
BOOT_DIR := boot/

# src file of .c .S type of local
LOCAL_SRC_ALL := $(call getFileList,.S,$(BOOT_DIR))
LOCAL_SRC_ALL += $(call getFileList,.c,$(BOOT_DIR))

# src to obj of local 
LOCAL_OBJ_ALL = $(call srcToObjFile,$(LOCAL_SRC_ALL))

# create dir of obj-file
$(call createTargetDir,$(LOCAL_OBJ_ALL))
$(call createTargetDir,$(BIN_DIR))

# local include
LOCAL_INC = $(addprefix -I,$(BOOT_DIR)) $(INCLUDE)

# batch compiler to obj by gcc
$(call ccBatchCompiler,$(LOCAL_SRC_ALL),$(LOCAL_INC),$(C_FLAGS))

# BootBLOCK_OBJ.o
BootBLOCK_OBJ = $(call srcToObjFile,mbr_block.o)

$(mbr_block) : $(BootBLOCK_OBJ)
	@echo +2 obj/mbr_block.asm obj/mbr_block.out
	objdump -S $(BootBLOCK_OBJ) > obj/mbr_block.asm
	objcopy -S -O binary $(BootBLOCK_OBJ) obj/mbr_block.out
	@echo + $@
	$(call exeShellScript,set_mbr_sign.sh,obj/mbr_block.out)

$(BootBLOCK_OBJ) : $(LOCAL_OBJ_ALL)
	@echo + $@
	$(LD) -o $@ $(LD_FLAGS) -e start -Ttext 0x7C00 $^
	
# <<<-------------------------------------------------------------------------------

#create kernel

$(kernel) :
	@echo + $@
	echo 123 > bin/kernel


# -----------------------------------Create spx.img Start------------------------>>>

$(spx_img) : $(mbr_block)
	@echo + $(BIN_DIR)spx.img
	$(call exeShellScript,create_img.sh,$@,$(mbr_block),$(kernel))

# <<<-------------------------------------------------------------------------------

.PHONY : debug
debug :
	@echo 1


.PHONY : clean
clean :
	rm -rf obj bin