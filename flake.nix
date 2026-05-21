{
  description = "xmos_dfu — JDS Labs XMOS USB DAC firmware flasher, patched for the iFi XU216 PID";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs:
        let
          xmos-dfu = pkgs.stdenv.mkDerivation {
            pname = "xmos-dfu";
            version = "unstable-2026-03-08";

            src = pkgs.fetchFromGitHub {
              owner = "jdslabs";
              repo = "xmos_dfu";
              rev = "bfae9954ae864bf9485e56fa6028ef9a9c2e17c2";
              hash = "sha256-X7Aw1M4XswvkVU5htV7Cys5bOsoP157JSzA95oJxuBU=";
            };

            sourceRoot = "source/xmos_dfu";

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.libusb1 ];

            # Add the iFi XU216 product ID (0x3008) to the recognized device list.
            # Vendor ID 0x20b1 (XMOS) is already handled upstream.
            postPatch = ''
              substituteInPlace xmosdfu.cpp \
                --replace-fail '#define XMOS_VID 0x20b1' \
                               '#define IFI_XU216_PID 0x3008
              #define XMOS_VID 0x20b1' \
                --replace-fail 'unsigned short pidList[] = {ATOMDAC2_PID,' \
                               'unsigned short pidList[] = {IFI_XU216_PID,
                                          ATOMDAC2_PID,'
            '';

            buildPhase = ''
              runHook preBuild
              make -f Makefile linux
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              install -Dm755 xmosdfu $out/bin/xmosdfu
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "CLI DFU utility for XMOS-based JDS Labs USB devices, patched for the iFi XU216";
              homepage = "https://github.com/jdslabs/xmos_dfu";
              license = licenses.mit;
              mainProgram = "xmosdfu";
              platforms = systems;
            };
          };
        in
        {
          default = xmos-dfu;
          xmos-dfu = xmos-dfu;
        });
    };
}
