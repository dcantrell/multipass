# Demonstration of parallel installable RPMs and the user selecting
# per executable (or library) which one to use.

CWD       = $(shell pwd)
MK        = $(CWD)/mk
CONF      = $(CWD)/conf
SRPMLIST  = $(CONF)/srpmlist
CHECKSUMS = $(CONF)/checksums

# These things are cleaned
SRPMCACHE = $(CWD)/cache
REPO      = $(CWD)/repo

all:
	@echo "Specify a target:"
	@echo "    fetch      Download all the SRPMs in 'srpmlist'"
	@echo "    build      Build all SRPMs in mock for this system"
	@echo "    clean      Remove built files, but not cached SRPMs"
	@echo "    realclean  Remove everything that's built or cached"

fetch: $(SRPMLIST)
	@env SRPMLIST='$(SRPMLIST)' \
	     SRPMCACHE='$(SRPMCACHE)' \
	     CHECKSUMS='$(CHECKSUMS)' \
	$(MK)/fetch.sh

build: fetch
	@sudo env REPO='$(REPO)' \
	     SRPMCACHE='$(SRPMCACHE)' \
	$(MK)/build.sh

clean:
	-rm -rf $(REPO)

realclean: clean
	-rm -rf $(SRPMCACHE)
