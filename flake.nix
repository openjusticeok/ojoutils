{
  description = "Tulsa County Jail Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    ojodb = {
      url = "github:openjusticeok/ojodb";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ojodb }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                arrow-cpp = prev.arrow-cpp.override {
                  enableGcs = true;
                  enableS3 = true;
                };
              })
            ];
            config = {
              permittedInsecurePackages = [
                "electron-38.8.4"
              ];
              problems.handlers = {
                googleCloudRunner.broken = "warn";
              };
            };
          };

          # Override arrow R package to properly detect GCS/S3
          arrowWithGcs = pkgs.rPackages.arrow.overrideAttrs (oldAttrs: {
            # Ensure the configure script can find arrow-cpp
            ARROW_HOME = "${pkgs.arrow-cpp}";
            # Force using pkg-config
            ARROW_USE_PKG_CONFIG = "true";
            # Don't use minimal build
            LIBARROW_MINIMAL = "false";
            # Ensure configure can find pkg-config files
            PKG_CONFIG_PATH = "${pkgs.arrow-cpp}/lib/pkgconfig";
            # Additional libraries for linking
            NIX_LDFLAGS = "-L${pkgs.arrow-cpp}/lib -larrow -larrow_compute -larrow_acero -larrow_dataset -lparquet";
            
            # Use postPatch to safely modify the source without breaking directory state
            postPatch = (oldAttrs.postPatch or "") + ''
              echo "Bypassing regex hell by providing a patched ArrowOptions.cmake..."
              
              # 1. Create a local copy of the CMake config and force all "TRUE" values back to "ON"
              mkdir -p .nix-cmake
              sed 's/"TRUE"/"ON"/g' ${pkgs.arrow-cpp}/lib/cmake/Arrow/ArrowOptions.cmake > .nix-cmake/ArrowOptions.cmake
              
              # 2. Force the configure script to read our patched config instead of the system one
              # We overwrite the ARROW_OPTS_CMAKE variable definition directly
              sed -i 's|^ARROW_OPTS_CMAKE=.*|ARROW_OPTS_CMAKE=".nix-cmake/ArrowOptions.cmake"|g' configure
              
              # 3. Catch any direct variable usage just to be absolutely certain
              sed -i 's|$ARROW_OPTS_CMAKE|.nix-cmake/ArrowOptions.cmake|g' configure
            '';
          });

          # Ojodb - installed from source
          ojodb-pkg = pkgs.rPackages.buildRPackage {
            name = "ojodb";
            src = ojodb;
            propagatedBuildInputs = with pkgs.rPackages; [
              dplyr
              dbplyr
              DBI
              RPostgres
              ggplot2
              pool
              rlang
              glue
              stringr
              purrr
              tidyr
              janitor
              lubridate
              hms
              fs
            ];
          };

          # R packages to include in the wrapper
          rPackages = [ ojodb-pkg arrowWithGcs ] ++ (with pkgs.rPackages; [
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
            readr
            renv
            rlang
            stringr
            targets
            tidyr
            usethis
            withr
            devtools
            knitr
            rmarkdown
            testthat
            tibble
            usethis
          ]);

          # R wrapper with all packages
          R = pkgs.rWrapper.override {
            packages = rPackages;
          };
          
          # Wrap RStudio with packages
          rstudio-wrapped = pkgs.rstudioWrapper.override {
            packages = rPackages;
          };
          
          # R library path for tools that need it
          rLibsPath = pkgs.lib.makeLibraryPath rPackages;
        in
        {
          # Development shell
          devShells.default = pkgs.mkShell {
            name = "r-dev";

            buildInputs = [
              R
              pkgs.radian
              pkgs.air-formatter
              pkgs.jarl
              pkgs.quarto
              # Rust toolchain
              pkgs.rustc
              pkgs.cargo
              pkgs.rustfmt
              pkgs.clippy
              pkgs.google-cloud-sdk
              # R CMD check system dependencies
              pkgs.checkbashisms
              pkgs.qpdf
              # rstudio-wrapped  # temporarily disabled due to nixpkgs npm issue
            ];

            shellHook = ''
              export PATH="${R}/bin:$PATH"
              export R_LIBS_SITE="${rLibsPath}"
              # Ensure Arrow GCS support libraries are available at runtime
              export ARROW_HOME="${pkgs.arrow-cpp}"
              export LD_LIBRARY_PATH="${pkgs.arrow-cpp}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              
              echo "🚀 R Development Environment"
              echo ""
              echo "Available tools:"
              echo "  - R (with tidyverse, devtools, ojodb, etc.)"
              echo "  - radian (enhanced R REPL)"
              echo "  - air (R formatter)"
              echo "  - jarl (R linter)"
              echo "  - quarto"
              echo "  - Rust (rustc, cargo, rustfmt, clippy)"
              echo ""
              echo "Quick start:"
              echo "  R                    # Start R console"
              echo "  radian               # Enhanced R REPL"
              echo "  air format .         # Format R code"
              echo "  jarl .               # Lint R code"
              echo "  cargo build          # Build Rust project"
              echo "  cargo test           # Run Rust tests"
              echo ""
              echo "Verify Arrow GCS support:"
              echo "  R -e 'arrow::arrow_info()'"
              echo ""
            '';
          };

          # Packages exposed for inspection
          packages = {
            inherit R;
            air = pkgs.air-formatter;
            jarl = pkgs.jarl;
          };
        };
    };
}
