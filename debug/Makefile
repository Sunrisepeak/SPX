# @Author: SPeak Shen 
# @Date: 2020-03-19 21:08:59 

# Debug ../tools/makefile/function.mk

include ../tools/makefile/f.mk

SRC_DIR = ./

# test----->
test_batchCompiler : test_createTargetDir
	$(call ccBatchCompiler,gcc,$(SRC_ALL))

# test----->
test_createTargetDir : test_srcToObjFile
	$(call createTargetDir,$(to_obj))

# test----->
to_obj = $(call srcToObjFile,$(SRC_ALL))
test_srcToObjFile : test_getFileList
	@echo test_srcToObjFile: $(to_obj)

# test----->
SRC_ALL += $(call getFileList,.c,$(SRC_DIR))
SRC_ALL += $(call getFileList,.S,$(SRC_DIR))
SRC_ALL += $(call getFileList,.cpp,$(SRC_DIR))

test_getFileList:	
	@echo test_getFileList: $(SRC_ALL)

.PHONY : clean
clean :
	rm -rf obj



