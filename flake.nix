{
  description = "Formatted BT device readout";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=23.11";

  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          rustc
          cargo
          rustfmt
          rust-analyzer
          clippy
          sqlite

          pkgs.dbus.lib
        ];

        PKG_CONFIG_PATH = "${pkgs.dbus.dev}/lib/pkgconfig";

        RUST_BACKTRACE = "full";
      };

      nixosModules.default =
        { pkgs, ... }:
        {
          environment.systemPackages = [ self.packages.${pkgs.system}.default ];
        };

      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "get_bt";
        version = "0.0.1";
        src = ./.;
        cargoBuildFlags = "-p get_bt";

        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          openssl.dev
          sqlite
        ];
        PKG_CONFIG_PATH = "${pkgs.dbus.dev}/lib/pkgconfig";

        buildPhase = ''
          cargo build
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp target/debug/get_bt $out/bin
        '';

      };
    };
}
