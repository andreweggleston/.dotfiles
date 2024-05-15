
# Build the system config and switch to it when running `just` with no args
default: switch

hostname := `hostname | cut -d "." -f 1`

# Build the NixOS configuration without switching to it
build target_host=hostname flags="":
	nixos-rebuild build --flake .#{{target_host}} {{flags}}

# Build the NixOS config with the --show-trace flag set
trace target_host=hostname: (build target_host "--show-trace")

# Build the NixOS configuration and switch to it.
switch target_host=hostname:
  sudo nixos-rebuild switch --flake .#{{target_host}}

# Update flake inputs to their latest revisions
update:
  nix flake update


# Garbage collect old OS generations and remove stale packages from the nix store
gc generations="5d":
  sudo nix-env --delete-generations {{generations}}
  sudo nix-store --gc
