# Makefile for installing ccb on Debian/Ubuntu systems

# --- Variables ---
# Installation prefix. Default is /usr/local, which is standard for
# software installed manually by an administrator.
# You can override it from the command line, e.g., `make PREFIX=/usr install`
PREFIX ?= /usr/local

# Define target directories based on the prefix
# Use a name like 'ccb' instead of 'ccb-1.0.1' for easier upgrades.
NAME := ccb
LIBEXECDIR := $(PREFIX)/lib
SBINDIR := $(PREFIX)/sbin
INSTALL_DIR := $(LIBEXECDIR)/$(NAME)

# Use DESTDIR for staging, which is good practice for packaging.
DESTDIR ?=

# --- Targets ---
.PHONY: all install uninstall help

all: help

help:
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@echo "  install      Install ccb to $(PREFIX)"
	@echo "  uninstall    Uninstall ccb from $(PREFIX)"
	@echo "  help         Show this help message"
	@echo ""
	@echo "Note: You will likely need to use 'sudo' for install and uninstall."
	@echo "Example: sudo make install"

# The 'install' target mimics the '%install' section of the spec file.
install:
	@echo "Installing ccb to $(INSTALL_DIR)..."
	# 1. Create main installation directory
	install -d "$(DESTDIR)$(INSTALL_DIR)"
	
	# 2. Copy application files (lib, sbin, tests, etc.)
	# Using 'cp -r' to copy directories.
	cp -r lib sbin tests LICENSE "$(DESTDIR)$(INSTALL_DIR)/"
	
	# 3. Create the sbin directory for the symlink
	install -d "$(DESTDIR)$(SBINDIR)"
	
	# 4. Create the symbolic link for the main executable
	ln -sf "$(INSTALL_DIR)/sbin/cli/ccb" "$(DESTDIR)$(SBINDIR)/ccb"
	
	@echo "Installation complete."
	@echo ""
	@echo "--- IMPORTANT POST-INSTALLATION STEP ---"
	@echo "To make environment settings available in your shell,"
	@echo "add the following line to your shell's startup file"
	@echo "(e.g., ~/.bashrc, ~/.zshrc):"
	@echo ""
	@echo "  source $(INSTALL_DIR)/lib/env.sh"
	@echo ""

# The 'uninstall' target mimics the '%postun' section of the spec file.
uninstall:
	@echo "Uninstalling ccb from $(PREFIX)..."
	# 1. Remove the symbolic link
	rm -f "$(DESTDIR)$(SBINDIR)/ccb"
	
	# 2. Remove the main installation directory
	rm -rf "$(DESTDIR)$(INSTALL_DIR)"
	
	@echo "Uninstallation complete."
	@echo ""
	@echo "--- NOTE ---"
	@echo "This script does not remove user-specific configurations."
	@echo "As noted in the original spec file, you may need to manually delete them:"
	@echo "  - ~/.config/cli"
	@echo "  - /root/.config/cli (if run as root)"
	@echo ""