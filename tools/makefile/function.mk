# * @Author: SPeak Shen 
# * @Date: 2020-03-19 21:17:34 


define srcToObjFile
	$(addprefix obj/,$(subst .S,.o,$(subst .c,.o,$(1))))
endef

##create dir of file
#	$(1) list of obj file
define createTargetDir
	$(shell mkdir -p $(dir $(1)))
endef

## batch compiler by gcc
#	$(1): list of src file
#	$(2): Include
#	$(3): flag
define ccBatchCompiler
	$(foreach f,$(1),\
	$(shell gcc -o $(call srcToObjFile,$(f))  $(2)	$(3) -c $(f)))
endef

# exe shell script (script,args1,arg2....)
exeShellScript = sh tools/shell/$(1) $(2) $(3) $(4)

toTargetFile = $(addprefix obj/,$(1)$(2).o)

# get filelist of dir/filename.* type
getFileList = $(shell find $(3) -name *$(1) | grep "\./$(2)")
