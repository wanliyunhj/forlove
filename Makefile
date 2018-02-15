SHELL              = /bin/sh
CC                 = g++
BIN_NAME           = forlove
BASEPATH           = .
SOURCE_PATH        = $(BASEPATH)/src
BIN_PATH           = $(BASEPATH)/bin

Thirdlibs_include = $(SOURCE_PATH)/../thirdlibs/linux/include
Thirdlibs_lib     = $(SOURCE_PATH)/../thirdlibs/linux/lib
LinkFlags          = -levent

CXXFLAGS           = -std=c++11 -w -m64 -g
DEBUG_FLAG         = $(CXXFLAGS) -O0
RELEASE_FLAG       = $(CXXFLAGS) -O2

SOURCE             = $(shell find $(SOURCE_PATH) -name "*.cpp" )
OBJ                = $(SOURCE:%.cpp=%.o)
DFILE              = $(SOURCE:%.cpp=%.d)

INCLUDE_PATH       = $(shell find $(SOURCE_PATH) | grep -v "^\..*\." | awk '{printf("-I%s\n",$$0)}') \
					-I$(Thirdlibs_include)

.PHONY: all
all: $(BIN_NAME)

$(BIN_NAME): $(OBJ)
	@echo -e "\033[32m[start]\033[0m link"
	@mkdir -p $(BIN_PATH)
	$(CC) $(INCLUDE_PATH) $(RELEASE_FLAG) -o $(BIN_PATH)/$(BIN_NAME) $(OBJ) $(LinkFlags) -L$(Thirdlibs_lib)
	@echo -e "\033[32m[end]\033[0m   link"

%.o: %.cpp
	@echo -e "\033[32m[start]\033[0m complie $<"
	$(CC) $(INCLUDE_PATH) $(RELEASE_FLAG) -c $< -o $@
	@echo -e "\033[32m[end]\033[0m   complie $<"

%.d: %.cpp
	@echo -e "\033[32m[start]\033[0m generate $@"
	@set -e; \
	rm -f $@; \
	$(CC) $(INCLUDE_PATH) $(RELEASE_FLAG) -MM $< > $@.$$$$; \
	sed 's,.*\.o[ :]*,$*.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
	@echo -e "\033[32m[end]\033[0m   generate $@"

-include $(DFILE)

.PHONY: clean
clean:
	rm -rf $(OBJ) $(DFILE) $(BIN_PATH)/$(BIN_NAME)
