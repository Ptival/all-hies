let
  haskellNixVersion = "af5998fe8d6b201d2a9be09993f1b9fae74e0082";
  haskellNixSrc = fetchTarball {
    url = "https://github.com/input-output-hk/haskell.nix/tarball/${haskellNixVersion}";
    sha256 = "0z5w99wkkpg2disvwjnsyp45w0bhdkrhvnrpz5nbwhhp21c71mbn";
  };
  haskellNix = import haskellNixSrc {};

  glibcSpecificPkgs = {
    "glibc-2.31" = import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/a45f68ccac476dc37ddf294530538f2f2cce5a92";
      sha256 = "0i19mrky9m73i601hczyfk25qqyr3j75idb72imdz55szc4vavzc";
    }) haskellNix.nixpkgsArgs;
    "glibc-2.30" = import haskellNix.sources.nixpkgs-2003 haskellNix.nixpkgsArgs;
    "glibc-2.27" = import haskellNix.sources.nixpkgs-1909 haskellNix.nixpkgsArgs;
  };

  pkgs = glibcSpecificPkgs."glibc-2.30";

  hie = rec {
    # unstable-2020-05-23
    version = "fe630a1e31232013549518909e511924e19af4af";
    src = fetchTarball {
      url = "https://github.com/haskell/haskell-ide-engine/archive/${version}.tar.gz";
      sha256 = "1lbbzk9kj39h79wb8imv5s22y592cyyrk06y24glrcxh5bzghb9l";
    };
  };

  # String gets written to the generated directory, so CI can quickly know
  # whether materialization files need to be updated
  materializationId = builtins.toFile "materialization-id" ''
    These materialization files were generated with
    haskell.nix ${haskellNixVersion}
    haskell-ide-engine ${hie.version}
  '';

in {
  inherit glibcSpecificPkgs pkgs hie materializationId;
}
