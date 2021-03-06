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
			 -fno-stack-protector -Os \
			 -fno-rtti \
			 -fpack-struct \

# ld Info
LD := ld
LD_FLAGS = -m elf_i386
# obj, bin dir
OBJ_DIR := obj/
BIN_DIR := bin/

# libs and include
LIBS_DIR := libs/ \
			libs/container/

INCLUDE := $(addprefix -I,$(LIBS_DIR))

# src file type
SRC_FILE_TYPE := .S .c .cpp

# branch
mbr_block := bin/mbr_block
kernel := bin/kernel
user := bin/user
spx_img := bin/spx.img

# bin dir
$(call createTargetDir,$(BIN_DIR))

main : $(mbr_block) $(spx_img)
	@echo success, create spx.img

##################################### Part I ######################################
# -------------------------------Create mbr_block Start--------------------------->>>

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
	$(LD) -o $@ $(LD_FLAGS) -nostdlib -N -T tools/boot.ld $^
	
# <<<-------------------------------------------------------------------------------
##################################### Part II ######################################
# -----------------------------------User------------------------>>>

UINCLUDE	:= user/include/ \
			   user/libs/

UDIR		:= user/

ULIBDIR		:= user/libs

USER_BINS	:=

# all file of src
#---> user
USRC += $(call getFileList,.user.cpp,$(UDIR))

#---> user lib
ULIB_SRC := $(call getFileList,.S,$(ULIBDIR))
ULIB_SRC += $(call getFileList,.cpp,$(ULIBDIR))

# src to obj of local 
UOBJS := $(call srcToObjFile,$(USRC))
ULIB_OBJS := $(call srcToObjFile,$(ULIB_SRC))

# create dir of obj-file
$(call createTargetDir,$(UOBJS) $(ULIB_OBJS))

# local include
LOCAL_INC := $(addprefix -I,$(UINCLUDE)) $(INCLUDE)

# batch compiler to obj by gcc
$(call batchCompiler,$(CXX),$(USRC) $(ULIB_SRC),$(LOCAL_INC),$(CXX_FLAGS))

define user_ld
__user_bin__ := $$(addprefix obj/,$$(notdir $$(basename $(1))))
USER_BINS += $$(__user_bin__)
$$(__user_bin__): tools/user.ld
	@echo + $$@
	ld $(LD_FLAGS) -T tools/user.ld -o $$@ $$(ULIB_OBJS) $(1)
	objdump -S $$@ > obj/$$(notdir $$(__user_bin__)).asm
	objdump -t $$@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$$$/d' > obj/$$(notdir $$(__user_bin__)).sym
endef

$(foreach p,$(UOBJS),$(eval $(call user_ld,$(p))))

# <<<-------------------------------------------------------------------------------
##################################### Part III ######################################
# --------------------------------Create Kernel Start---------------------------->>>

KINCUDE_DIR :=	kernel/include/ \
				kernel/include/driver \
				kernel/include/video/ \
				kernel/include/interrupt/ \
				kernel/include/mm/ \
				kernel/include/mm/malgorithms/ \
				kernel/include/sync/ \
				kernel/kdebug/ \
				kernel/libs/ \
				kernel/console/ \
				kernel/fs/ \
				kernel/interrupt/ \
				kernel/pm/ \
				kernel/pm/thread/ \
				kernel/schedule/ \
				kernel/syscall/ \
				kernel/trap/



KSRC_DIR	:=	kernel/init/ \
				kernel/console/ \
				kernel/interrupt/ \
				kernel/driver/ \
				kernel/libs/ \
				kernel/mm/ \
				kernel/pm/ \
				kernel/schedule/ \
				kernel/syscall/ \
				kernel/trap/ \
				libs/ \

# all file of src
LOCAL_SRC_ALL := $(call getFileList,.S,$(KSRC_DIR))
LOCAL_SRC_ALL += $(call getFileList,.cpp,$(KSRC_DIR))

# src to obj of local 
LOCAL_OBJ_ALL := $(call srcToObjFile,$(LOCAL_SRC_ALL))

# create dir of obj-file
$(call createTargetDir,$(LOCAL_OBJ_ALL))

# local include
LOCAL_INC := $(addprefix -I,$(KINCUDE_DIR)) $(INCLUDE)

# batch compiler to obj by g++
$(call batchCompiler,$(CXX),$(LOCAL_SRC_ALL),$(LOCAL_INC),$(CXX_FLAGS))
		
$(kernel) : $(LOCAL_OBJ_ALL) $(USER_BINS)
	@echo + $@
	$(LD) -o $@ $(LD_FLAGS) -T tools/kernel.ld $(LOCAL_OBJ_ALL) -b binary $(USER_BINS)
	@echo +2 obj/kernel.asm obj/kernel.sym
	objdump -S $@ > obj/kernel.asm
	objdump -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > obj/kernel.sym
	




# <<<-------------------------------------------------------------------------------
##################################### Part IV ######################################
# -----------------------------------Create spx.img Start------------------------>>>

$(spx_img) : $(mbr_block) $(kernel)
	@echo + $(BIN_DIR)spx.img
	$(call exeShellScript,create_img.sh,$@,$(mbr_block),$(kernel))


# <<<------------------------------------------------------------------------------
##################################### Part V ######################################
# ------------------------------------Debug------------------------------------->>>

VBOX_VHD := vm/master.vhd
SWAPIMG  := vm/swap.vhd

QEMUOPTS = -hda $(VBOX_VHD) -drive file=$(SWAPIMG),media=disk,cache=writeback

.PHONY: qemu debug

qemu : $(VBOX_VHD) $(SWAPIMG)
	dd if=$(spx_img) of=$(VBOX_VHD) conv=notrunc
	qemu-system-i386 -no-reboot -parallel stdio $(QEMUOPTS) -serial null

debug :
	@echo Bochs Debug Mode
	make clean
	make
	dd if=$(spx_img) of=$(VBOX_VHD) conv=notrunc
	bochs -f bochsConfig.cfg


.PHONY : clean
clean :
	rm -rf obj bin
