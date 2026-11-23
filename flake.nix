{
  description = "herdtools7";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
  flake-utils.lib.eachDefaultSystem (system:
  let 
    pkgs = nixpkgs.legacyPackages.${system};
    ocamlPackages = pkgs.ocamlPackages;
  in
  {
    packages.default = ocamlPackages.buildDunePackage {
      pname = "herdtools7";
      version = "7.58+1";
      src = ./.;
      nativeBuildInputs = [ ocamlPackages.menhir ];
      buildInputs = with ocamlPackages; [ menhirLib zarith logs];
      doCheck = false;
    };

    # `nix develop`
    devShells.default = pkgs.mkShell {
      inputsFrom = [ self.packages.${system}.default ];
      packages = with ocamlPackages; [ ocaml-lsp ocamlformat pkgs.pre-commit pkgs.graphviz pkgs.d2 ];
    };
  });
}
