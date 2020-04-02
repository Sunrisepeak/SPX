# @Author: SPeak Shen 
# @Date: 2020-03-19 21:08:59 

include tools/makefile/function.mk

# project dir
ROOT_DIR = ./

# compiler Info
CXX := g++
CXX_FLAGS := -march=i686 -m32 \
			 -fno-exceptions \
			 -fno-builtin \
			 -Wall -ggdb -gstabs \
			 -nostdinc  -nostdinc++ \
			 -fno-stack-protector -Os

# ld Info
LD := ld
LD_FLAGS = -m elf_i386
# obj, bin dir
OBJ_DIR := obj/
BIN_DIR := bin/

# libs and include
LIBS_DIR := libs/
INCLUDE := $(addprefix -I,$(LIBS_DIR))

# src file type
SRC_FILE_TYPE := .S .c .cpp

# branch
mbr_block := bin/mbr_block
kernel := bin/kernel
spx_img := bin/spx.img

# bin dir
$(call createTargetDir,$(BIN_DIR))

main : $(mbr_block) $(kernel) $(spx_img)
	@echo + spx.img
	$(call exeShellScript,create_img.sh,$(spx_img),$(mbr_block),$(kernel))
	@echo success, create spx.img


# --------------------------------Create mbr_block Start--------------------------->>>

# boot dir
BOOT_DIR := boot/

# src file of .c .S type of local
LOCAL_SRC_ALL := $(call getFileList,.S,$(BOOT_DIR))
LOCAL_SRC_ALL += $(call getFileList,.cpp,$(BOOT_DIR))

# src to obj of local 
LOCAL_OBJ_ALL = $(call srcToObjFile,$(LOCAL_SRC_ALL))

# create dir of obj-file
$(call createTargetDir,$(LOCAL_OBJ_ALL))

# local include
LOCAL_INC := $(addprefix -I,$(BOOT_DIR)) $(INCLUDE)

# batch compiler to obj by gcc
$(call batchCompiler,$(CXX),$(LOCAL_SRC_ALL),$(LOCAL_INC),$(CXX_FLAGS))

# bootblock.o
bootblock = $(call srcToObjFile,mbr_block.o)

$(mbr_block) : $(bootblock)
	@echo +2 obj/mbr_block.asm obj/mbr_block.out
	objdump -S $^ > obj/mbr_block.asm
	objcopy -S -O binary $^ obj/mbr_block.out
	@echo + $@
	$(call exeShellScript,set_mbr_sign.sh,obj/mbr_block.out)

$(bootblock) : $(LOCAL_OBJ_ALL)
	@echo + $@
	$(LD) -o $@ $(LD_FLAGS) -nostdlib -N -e start -Ttext 0x7C00 $^
	
# <<<-------------------------------------------------------------------------------
##################################### Part II ######################################
# --------------------------------Create Kernel Start---------------------------->>>

KINCUDE_DIR :=	kernel/include/ \
				kernel/include/video/ \
				kernel/include/interrupt/ \
				kernel/libs/ \
				kernel/console/ \
				kernel/interrupt/ \
				kernel/mm/ \
				kernel/trap/



KSRC_DIR	:=	kernel/init/ \
				kernel/console/ \
				kernel/interrupt/ \
				kernel/driver/	\
				kernel/libs/ \
				kernel/mm/ \
				kernel/trap/ \
				libs/

# all file of src
LOCAL_SRC_ALL := $(call getFileList,.cpp,$(KSRC_DIR))
LOCAL_SRC_ALL += $(call getFileList,.S,$(KSRC_DIR))

# src to obj of local 
LOCAL_OBJ_ALL := $(call srcToObjFile,$(LOCAL_SRC_ALL))

# create dir of obj-file
$(call createTargetDir,$(LOCAL_OBJ_ALL))

# local include
LOCAL_INC := $(addprefix -I,$(KINCUDE_DIR)) $(INCLUDE)

# batch compiler to obj by g++
$(call batchCompiler,$(CXX),$(LOCAL_SRC_ALL),$(LOCAL_INC),$(CXX_FLAGS))
		
$(kernel) : $(LOCAL_OBJ_ALL)
	@echo + $@
	$(LD) -o $@ $(LD_FLAGS) -T tools/kernel.ld $^
	@echo +2 obj/kernel.asm obj/kernel.sym
	objdump -S $@ > obj/kernel.asm
	objdump -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > obj/kernel.sym
	
# <<<-------------------------------------------------------------------------------


# -----------------------------------Create spx.img Start------------------------>>>

$(spx_img) : $(mbr_block)
	@echo + $(BIN_DIR)spx.img
	$(call exeShellScript,create_img.sh,$@,$(mbr_block),$(kernel))

# <<<-------------------------------------------------------------------------------

VBOX_VHD := ../Book/x86-Assembly-Real-To-Protected_Mode/testVM/testVM.vhd
TERMINAL := gnome-terminal
.PHONY : debug
debug :
	@echo Bochs Debug Mode
	dd if=$(spx_img) of=$(VBOX_VHD) conv=notrunc
	bochs -f $(VBOX_VHD)../bochsConfig.txt

.PHONY : clean
clean :
	rm -rf obj bin