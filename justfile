# Build the system config and switch to it when running `just` with no args
default: switch

hostname := `hostname | cut -d "." -f 1`

# Build the nix-darwin system configuration without switching to it
[macos]
build target_host=hostname flags="":
  @echo "Building nix-darwin config..."
  nh darwin build . -H {{target_host}} {{flags}}

# Build the nix-darwin config with the --show-trace flag set
[macos]
trace target_host=hostname: (build target_host "--show-trace")

# Build the nix-darwin configuration and switch to it
[macos]
switch target_host=hostname: (build target_host)
  @echo "switching to new config for {{target_host}}"
  # if macOS updates and overwrites /etc/shells, nix will refuse to update it
  sudo mv /etc/shells /tmp/shells.bak || true
  nh darwin switch . -H {{target_host}}

# Reload the skhd (hotkey daemon) service to apply new config. Workaround for config changes not being auto-detected.
[macos]
reload-skhd:
  launchctl stop org.nixos.skhd && launchctl start org.nixos.skhd && sleep 1 && skhd -r

# on asahi linux, we need to pass the --impure flag to read in firmware files
rebuild_flags := `if [ -d /boot/asahi ]; then echo "--impure"; else echo "--impure"; fi`


# Build the NixOS configuration without switching to it
[linux]
build target_host=hostname flags="":
	nh os build . -H {{target_host}} {{rebuild_flags}} {{flags}}

# Build the NixOS config with the --show-trace flag set
[linux]
trace target_host=hostname: (build target_host "--show-trace")

# Build the NixOS configuration and switch to it.
[linux]
switch target_host=hostname:
  nh os switch . -H {{target_host}} {{rebuild_flags}}

# Build the NixOS configuration and test it without adding a boot entry.
[linux]
test target_host=hostname:
  nh os test . -H {{target_host}} {{rebuild_flags}}

# Update flake inputs to their latest revisions
update:
  nix flake update


# Garbage collect old OS generations and remove stale packages from the nix store
gc generations="5d":
  sudo nix-env --delete-generations {{generations}}
  sudo nix-store --gc
