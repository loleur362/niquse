# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  alcom = pkgs.appimageTools.wrapType2 {
    pname = "alcom";
    version = "1.1.8";
    src = pkgs.fetchurl {
      url = "https://github.com/vrc-get/vrc-get/releases/download/gui-v1.1.8/alcom-1.1.8-x86_64.AppImage";
      sha256 = "sha256-4c/4N1R+Q+k8I+jSMWSt42+LDfShJEs76/Pl5mjQCbw=";
    };
    extraPkgs = pkgs: with pkgs; [
      sqlite lcms2 webkitgtk_4_1 libsoup_3 gtk3 openssl libwebp
      librsvg libglvnd fontconfig freetype harfbuzz pango cairo
      gdk-pixbuf glib atk dbus nspr nss cups expat libxkbcommon libtasn1
      libpsl libnghttp2 libepoxy libpng libjpeg libtiff woff2 libxml2 libxslt
      gst_all_1.gstreamer gst_all_1.gst-plugins-base
    ];
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./osu-tools-module.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.timeout = 5;
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" ];
  boot.kernelModules = [ "uninput" ]; 

  networking.hostName = "Uhee"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  security.rtkit.enable = true;
  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."nicolas" = {
    isNormalUser = true;
    description = "Nicolas";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      librewolf
      obs-studio
      vesktop
      alvr
      osu-lazer-bin
      steam
      prismlauncher
      fastfetch
      signal-desktop
      vscodium
      obsidian
      easyeffects
      opencode
    ];
  };

  environment.shellAliases = {
    config = "sudo vim /etc/nixos/configuration.nix";
    hoshino = "sudo nixos-rebuild switch";
    clean = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
    osu-tools-gui = "rm -rf -- /home/nicolas/Documents/osu-tools/PerformanceCalculatorGUI/'C:\'*/ && cd /home/nicolas/Documents/osu-tools/PerformanceCalculatorGUI/ && dotnet watch";
    osu-tools-cli = "rm -rf -- /home/nicolas/Documents/osu-tools/PerformanceCalculatorGUI/'C:\'*/ && dotnet build -c Release && /home/nicolas/Documents/osu-tools/sr.sh";
    midori = "nix-shell /home/nicolas/Documents/";
};

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     gamescope
     vim
     wget
     wineWow64Packages.stable
     winetricks
     steam-run
     ghex
     dotnet-sdk_8
     vrc-get
     alcom
     wayvr
     wivrn
     git
     appimage-run
     SDL2
     vulkan-loader
     github-cli
     (discord.override { withVencord = true; })
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    sqlite
    lcms2
    webkitgtk_4_1
    libsoup_3
    gtk3
    openssl
    libwebp
    librsvg
    libglvnd
    fontconfig
    freetype
    harfbuzz
    pango
    cairo
    gdk-pixbuf
    glib
    atk
    dbus
    nspr
    nss
    cups
    expat
    libxkbcommon
    libtasn1
    stdenv.cc.cc.lib
    zlib
    icu
    python3
  ];

  services.flatpak.enable = true;
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
  package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "595.99.02";
    sha256_64bit = "sha256-6HR3lYv3YwcFSTJL1a1slI66btIQ5EAFs+/4SUD24ew=";
    sha256_aarch64 = "sha256-CCqHZTN2KNOZ4yZp2rDcuRJp9pHfRw47k4m4dWnS/2w=";
    openSha256 = "sha256-T36x/jx8yQ8l3LFp1rZIrTfcSwbGy8YSAvXOUSptpb4=";
    settingsSha256 = "sha256-GYCcnxfKPrTCrsmd25sMyzfC5cqJQJx0c31haooyTYM=";
    persistencedSha256 = "sha256-VyKtF/HdHPQrHHK6opSO69M72LmnGZtauuchj9uuje8=";
  };
  modesetting.enable = true;
  powerManagement.enable = false;
  open = true;
  nvidiaSettings = true;
};

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
};

  environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
};

  powerManagement.cpuFreqGovernor = "performance";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9757 ];
    allowedUDPPorts = [ 27015 27016 27017 27018 27019 27020 9757 ];
    allowedUDPPortRanges = [
      { from = 27000; to = 27100; }
  ];
};

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      addresses = true;
      enable = true;
      userServices = true;
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
