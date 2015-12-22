ROOT = .

KAZOODIRS = core/Makefile \
	    applications/Makefile

MAKEDIRS = deps/Makefile \
	   core/Makefile \
	   applications/Makefile

.PHONY: $(MAKEDIRS) core deps apps xref dialyze dialyze-apps dialyze-core dialyze-kazoo

all : compile

compile: ACTION = all
compile: $(MAKEDIRS)

$(MAKEDIRS):
	$(MAKE) -C $(@D) $(ACTION)

clean: ACTION = clean
clean: $(MAKEDIRS) clean-release
	$(if $(wildcard *crash.dump), rm *crash.dump)
	$(if $(wildcard scripts/log/*), rm -rf scripts/log/*)

clean-release:
	$(if $(wildcard _rel/), rm -r _rel/)
	$(if $(wildcard relx.config), rm relx.config)

clean-test : ACTION = clean-test
clean-test : $(KAZOODIRS)

eunit: ACTION = test
eunit: $(KAZOODIRS)

proper: ACTION = test
proper: ERLC_OPTS += -DPROPER
proper: $(KAZOODIRS)

test: ACTION = test
test: ERLC_OPTS += -DPROPER
test: $(KAZOODIRS)

core:
	$(MAKE) -C core all
deps:
	$(MAKE) -C deps all
apps:
	$(MAKE) -C applications all

kazoo: core apps

DIALYZER ?= dialyzer
PLT ?= .kazoo.plt
$(PLT): DEPS_SRCS  ?= $(shell find $(ROOT)/deps -name src )
# $(PLT): CORE_EBINS ?= $(shell find $(ROOT)/core -name ebin)
$(PLT):
	@$(DIALYZER) --no_native --build_plt --output_plt $(PLT) \
	    --apps erts kernel stdlib crypto public_key ssl \
	    -r $(DEPS_SRCS)
	@for ebin in $(CORE_EBINS); do \
	    $(DIALYZER) --no_native --add_to_plt --plt $(PLT) --output_plt $(PLT) -r $$ebin; \
	done
build-plt: $(PLT)

dialyze-kazoo: TO_DIALYZE  = $(shell find $(ROOT)/applications -name ebin) $(shell find $(ROOT)/core -name ebin)
dialyze-kazoo: dialyze
dialyze-apps:  TO_DIALYZE  = $(shell find $(ROOT)/applications -name ebin)
dialyze-apps: dialyze
dialyze-core:  TO_DIALYZE  = $(shell find $(ROOT)/core         -name ebin)
dialyze-core: dialyze
dialyze:       TO_DIALYZE ?= $(shell find $(ROOT)/applications -name ebin)
dialyze: $(PLT)
	@$(ROOT)/scripts/check-dialyzer.escript $(ROOT)/.kazoo.plt $(TO_DIALYZE)

xref: TO_XREF = $(shell find $(ROOT) -name ebin)
xref:
	@$(ROOT)/scripts/check-xref.escript $(TO_XREF)

sup_completion: sup_completion_file = $(ROOT)/sup.bash
sup_completion: kazoo
	@$(if $(wildcard $(sup_completion_file)), rm $(sup_completion_file))
	@$(ROOT)/scripts/sup-build-autocomplete.escript $(sup_completion_file) applications/ core/
	@echo SUP Bash completion file written at $(sup_completion_file)

release: RELX = $(ROOT)/utils/relx/relx
release: relx.config
	$(RELX) -v release --config $^ --relname kazoo_whistle_apps
#	$(RELX) -v release --config $^ --relname kazoo_ecallmgr
relx.config: relx.config.script
	$(ROOT)/scripts/script2any.escript relx.config.script
