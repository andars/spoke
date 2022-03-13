TEST_MODULES := loopback

.PHONY: all $(TEST_MODULES)

.PHONY: all
all: $(TEST_MODULES)

$(TEST_MODULES):
	@cd $@ && $(MAKE)
