{
  description = "A basic flake for STREAM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,

  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default =
        pkgs.mkShell.override
        {
          # Override stdenv in order to change compiler:
          #stdenv = pkgs.clangStdenv;
        }
        {
          packages = with pkgs;
            [
              (pkgs.python311.withPackages (ps: [
              ]))
              gfortran
              gcc
              clang
              gnumake
              cmake
              cppcheck
            ]
            ++ (
              if system == "aarch64-darwin"
              then []
              else [gdb]
            );
        };

      buildInputs = [pkgs.clang-tools];
      shellHook = ''
        PATH="${pkgs.clang-tools}/bin:$PATH"
      '';
    });
  };
}
