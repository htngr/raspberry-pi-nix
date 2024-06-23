{
  description = "raspberry-pi nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    u-boot-src = {
      flake = false;
      url = "https://ftp.denx.de/pub/u-boot/u-boot-2024.04.tar.bz2";
    };
    rpi-linux-6_6-src = {
      flake = false;
      url = "github:raspberrypi/linux/stable_20240529";
    };
    rpi-firmware-src = {
      flake = false;
      url = "github:raspberrypi/firmware/1.20240529";
    };
    rpi-firmware-nonfree-src = {
      flake = false;
      url = "github:RPi-Distro/firmware-nonfree/bookworm";
    };
    rpi-bluez-firmware-src = {
      flake = false;
      url = "github:RPi-Distro/bluez-firmware/bookworm";
    };
    libcamera-apps-src = {
      flake = false;
      url = "github:raspberrypi/rpicam-apps/v1.5.0";
    };
    libcamera-src = {
      flake = false;
      url = "github:raspberrypi/libcamera/v0.3.0+rpt20240617";
    };
    libpisp-src = {
      flake = false;
      url = "github:raspberrypi/libpisp/v1.0.6";
    };
  };

  outputs = srcs@{ self, ... }:
    let
      pinned = import srcs.nixpkgs {
        system = "aarch64-linux";
        overlays = with self.overlays; [ core libcamera ];
      };
    in
    {
      overlays = {
        core = import ./overlays (builtins.removeAttrs srcs [ "self" ]);
        libcamera = import ./overlays/libcamera.nix (builtins.removeAttrs srcs [ "self" ]);
      };
      nixosModules.raspberry-pi = import ./rpi {
        inherit pinned;
        core-overlay = self.overlays.core;
        libcamera-overlay = self.overlays.libcamera;
      };
      packages.aarch64-linux = {
        linux_2711 = pinned.rpi-kernels.v6_6_31.bcm2711;
        linux_2712 = pinned.rpi-kernels.v6_6_31.bcm2712;
        firmware = pinned.raspberrypifw;
        wireless-firmware = pinned.raspberrypiWirelessFirmware;
        uboot-rpi-arm64 = pinned.uboot-rpi-arm64;
      };
    };
}
