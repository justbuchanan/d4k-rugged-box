{
  description = "Rugged Box for D4K Flashlight";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs (use 0.1 for unstable)
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            openscad

            nodePackages.prettier
            nixpkgs-fmt
          ];
        };

        packages.default =
          pkgs.runCommand "flashbox-stl" { buildInputs = [ pkgs.openscad pkgs.gnumake ]; } ''
            mkdir -p $out
            cp ${./rugged-box.scad} rugged-box.scad
            cp ${./rugged-box-library.scad} rugged-box-library.scad
            cp ${./Makefile} Makefile
            make -j$(nproc)
            cp *.stl $out/
          '';
      }
    );
}
