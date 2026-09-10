# Bambu Studio (3D-print slicer) and a Tinkercad launcher for the Dash.
#
# Bambu Studio is unfree and not in the Nix binary cache, so building it from
# nixpkgs would compile a huge tree on every laptop. Install the prebuilt
# Flathub app instead (flatpak is already enabled fleet-wide). nix-flatpak
# installs it on activation and refreshes it on the weekly timer.
#
# Tinkercad (https://www.tinkercad.com) is browser-only. The launcher opens it
# as a Chromium app window so it gets its own Dash entry, next to the browsers.
{ pkgs, ... }:

let
  tinkercadUrl = "https://www.tinkercad.com/";

  tinkercad = pkgs.makeDesktopItem {
    name = "tinkercad";
    desktopName = "Tinkercad";
    comment = "Online 3D-design og kredsløb";
    exec = "chromium --app=${tinkercadUrl}";
    icon = "applications-engineering";
    categories = [ "Education" "Graphics" "3DGraphics" ];
    # Chromium derives this WM class from the --app URL; matching it lets GNOME
    # group the running window under the Dash launcher.
    startupWMClass = "chrome-www.tinkercad.com__-Default";
  };
in
{
  # flatpak.enable and the flathub remote come from ./configuration.nix and
  # nix-flatpak's defaults.
  services.flatpak.packages = [ "com.bambulab.BambuStudio" ];

  # Pull in new Flathub builds on every rebuild (the nightly auto-upgrade), plus
  # a weekly catch-up timer for laptops left on between upgrades.
  services.flatpak.update = {
    onActivation = true;
    auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  environment.systemPackages = [ tinkercad ];
}
