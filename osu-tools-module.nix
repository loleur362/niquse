# osu-tools-module.nix

{ pkgs, ... }:

let
  osuToolsLibs = pkgs.lib.makeLibraryPath [
    pkgs.SDL2
    pkgs.ffmpeg_4
    pkgs.alsa-lib
    pkgs.lttng-ust
    pkgs.numactl
  ];

  dotnet = pkgs.dotnetCorePackages.sdk_8_0;

  osuTools = pkgs.writeShellScriptBin "osu-tools" ''
    set -euo pipefail

    export LD_LIBRARY_PATH="${osuToolsLibs}:''${LD_LIBRARY_PATH:-}"
    export DOTNET_ROOT="${dotnet}"

    PCG_DIR="$HOME/Documents/osu-tools/PerformanceCalculatorGUI"

    exec ${dotnet}/bin/dotnet run --project "$PCG_DIR" -- "$@"
  '';
in
{
  environment.systemPackages = [ osuTools ];
}
