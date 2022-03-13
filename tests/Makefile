SELF:=$(lastword $(MAKEFILE_LIST))
OUT=$(realpath $(dir $(SELF))/..)/_out/tests
$(info writing test output to $(OUT))

TEST_MODULES := loopback

.PHONY: all $(TEST_MODULES)

.PHONY: all
all: $(TEST_MODULES)

$(TEST_MODULES):
	@mkdir -p $(OUT)/$@ && $(MAKE) -C $(OUT)/$@ -f $(realpath $@/Makefile)
