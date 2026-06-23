{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel"; nix-cachyos-kernel.inputs.nixpkgs.follows = "nixpkgs"; };
  nixConfig = { extra-substituters = ["https://attic.xuyh0120.win/lantian"]; extra-trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="]; };
  outputs = { self, nixpkgs, nix-cachyos-kernel }: { nixosConfigurations.nixos = nixpkgs.lib.nixosSystem { system = "x86_64-linux"; modules = [ ./configuration.nix { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ]; } ]; }; };
}
