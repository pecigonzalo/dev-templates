{
  description =
    "Ready-made templates for easily creating flake-driven environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      templates = {
        cue = {
          path = ./cue;
          description = "Cue development environment";
        };

        dhall = {
          path = ./dhall;
          description = "Dhall development environment";
        };

        elixir = {
          path = ./elixir;
          description = "Elixir development environment";
        };

        elm = {
          path = ./elm;
          description = "Elm development environment";
        };

        gleam = {
          path = ./gleam;
          description = "Gleam development environment";
        };

        go1_17 = {
          path = ./go1.17;
          description = "Go 1.17 development environment";
        };

        go1_18 = {
          path = ./go1.18;
          description = "Go 1.18 development environment";
        };

        hashi = {
          path = ./hashi;
          description = "HashiCorp DevOps tools development environment";
        };

        java = {
          path = ./java;
          description = "Java development environment";
        };

        kotlin = {
          path = ./kotlin;
          description = "Kotlin development environment";
        };

        nim = {
          path = ./nim;
          description = "Nim development environment";
        };

        nix = {
          path = ./nix;
          description = "Nix development environment";
        };

        node = {
          path = ./node;
          description = "Node.js development environment";
        };

        opa = {
          path = ./opa;
          description = "Open Policy Agent development environment";
        };

        protobuf = {
          path = ./protobuf;
          description = "Protobuf development environment";
        };

        python = {
          path = ./python;
          description = "Python development environment";
        };

        ruby = {
          path = ./ruby;
          description = "Ruby development environment";
        };

        rust = {
          path = ./rust;
          description = "Rust development environment";
        };

        scala = {
          path = ./scala;
          description = "Scala development environment";
        };

        zig = {
          path = ./zig;
          description = "Zig development environment";
        };
      };

      lib = let
        pkgs = nixpkgs;
        inherit (pkgs.lib) optionals;
        inherit (pkgs.stdenv) isDarwin isLinux;
      in {
        inherit flake-utils nixpkgs;
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) mkShell writeScriptBin;
        run = pkg: "${pkgs.${pkg}}/bin/${pkg}";

        format = writeScriptBin "format" ''
          ${run "nixfmt"} **/*.nix
        '';
        update = writeScriptBin "update" ''
          # Update root
          $${run "nix"} flake update

          for dir in `ls -d */`; do # Iterate through all the templates
            (
              cd $dir
              ${run "nix"} flake update # Update flake.lock
              ${run "direnv"} reload    # Make sure things work after the update
            )
          done
        '';

        visit = writeScriptBin "visit" ''
          for dir in `ls -d */`; do
            (
              cd $dir
              ${run "direnv"} reload
            )
          done
        '';
      in {
        devShells = {
          default = mkShell {
            buildInputs = [ format update visit ];
          };
        };
      }
    );
}
