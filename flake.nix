{
  description = "ojoutils — OJO analyst helpers (R package with Rust extensions)";

  inputs = {
    nixpkgs.url = "github:rstats-on-nix/nixpkgs/r-daily";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { system, ... }:
        let
          # Arrow GCS/S3 fix. nixpkgs' arrow-cpp has GCS/S3 (enableGcs defaults
          # on), but the R `arrow` bindings' configure misdetects it
          # (ArrowOptions.cmake writes "TRUE" where configure expects "ON"), so R
          # arrow reports "built without GCS support". Keep this in sync with
          # flakes/overlays/r-public.nix — it is duplicated here only because this
          # flake cannot import `flakes` (that would be a dependency cycle).
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                rPackages = prev.rPackages.override {
                  overrides = {
                    arrow = prev.rPackages.arrow.overrideAttrs (old: {
                      env = (old.env or { }) // {
                        ARROW_R_CXXFLAGS = "-DARROW_R_WITH_GCS -DARROW_R_WITH_S3";
                        LIBARROW_MINIMAL = "false";
                        ARROW_USE_PKG_CONFIG = "true";
                      };
                    });
                  };
                };
              })
            ];
          };

          # Runtime deps (DESCRIPTION: Imports).
          rImports = with pkgs.rPackages; [
            arrow
            cli
            dbplyr
            dplyr
            fs
            gargle
            gert
            gh
            glue
            googleCloudStorageR
            janitor
            lubridate
            nanoarrow
            processx
            quarto
            readr
            renv
            rlang
            stringr
            targets
            tidyr
            usethis
            withr
          ];

          rDev = with pkgs.rPackages; [
            knitr
            rmarkdown
            devtools
            roxygen2
            testthat
            rcmdcheck
            pkgload
            pkgbuild
            rextendr
          ];

          # Rust extension toolchain. The package vendors its crates
          # (src/rust/vendor.tar.xz) and builds offline via tools/config.R.
          rustTools = with pkgs; [ cargo rustc xz pkg-config ];

          ojoutils = pkgs.rPackages.buildRPackage {
            name = "ojoutils";
            src = ./.;
            propagatedBuildInputs = rImports;
            nativeBuildInputs = rustTools ++ (with pkgs.rPackages; [ knitr rmarkdown ]);
          };
        in
        {
          packages = {
            inherit ojoutils;
            default = ojoutils;
          };

          devShells.default = pkgs.mkShell {
            name = "ojoutils-dev";
            # checkbashisms: R CMD check's "top-level files" check needs it for
            # the package's shell `configure` script.
            buildInputs = [ pkgs.R pkgs.checkbashisms ] ++ rImports ++ rDev ++ rustTools;
            packages = with pkgs; [ jarl arf air-formatter ];
            shellHook = ''
              echo "ojoutils dev shell — R -e 'devtools::check()'"
            '';
          };
        };
    };
}
