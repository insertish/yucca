{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/68d8aa3d661f0e6bd5862291b5bb263b2a6595c9.tar.gz";
    sha256 = "0p22chwcyksj099af40210i299jvmp33757qmm1nfma872k8pwmw";
  }) {},

  # Playwright v1.57.0
  unstablePkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/145b67bd0bd4e075f981c1c2b81155d9e2982de2.tar.gz";
    sha256 = "152qwxacs6lw1dskn21985qly8ipjzwpsvicy7inzh3hhma603gg";
  }) {},
}:

let
  nix-ld-libs = pkgs.buildEnv {
    name = "nix-ld-libs";
    paths = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
    ];
  };

in pkgs.mkShell {
  packages = with pkgs; [
    mise
    lsof
    pkg-config
    openssl.dev
    (writeShellScriptBin "fish" ''
      exec ${pkgs.fish}/bin/fish -C 'mise activate fish | source' "$@"
    '')
  ];

  shellHook = ''
    export NIX_LD="${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2"
    export NIX_LD_LIBRARY_PATH="${nix-ld-libs}/lib"

    export MISE_NODE_COMPILE=false
    eval "$(mise activate bash)"

    export PLAYWRIGHT_BROWSERS_PATH=${unstablePkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true

    playwrightPnpmVersion=($(pnpm list -r @playwright/test | grep playwright))
    playwrightPnpmVersion=''${playwrightPnpmVersion[1]}

    echo "❄️  Playwright nix version: ${unstablePkgs.playwright.version}"
    echo "📦 Playwright npm version: $playwrightPnpmVersion"

    if [ "${unstablePkgs.playwright.version}" != "$playwrightPnpmVersion" ]; then
      echo "❌ Playwright versions in nix and npm are not the same!"
    else
      echo "✅ Playwright versions in nix and npm are the same"
    fi
  '';
}