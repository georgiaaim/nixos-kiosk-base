# NixOS Configuration Base Flake for UGA Module Factory Kiosks

This repository houses the NixOS configuration flake for a kiosk system, optimized for a UGA Module Factory setup running on a ZimaBoard. It includes configurations for a seamless user experience, network setup, service management, and software provisioning tailored for kiosk operations. The configuration emphasizes security, ease of use, and minimal manual intervention for maintenance and updates.

## Configuration Structure

The configuration is split across several files and directories to separate concerns and simplify management. Here's an overview:

- **`flake.nix`**: The entry point of the flake, defining inputs such as Nixpkgs and Home-Manager, and outputs including the NixOS modules and packages.
- **`boot.nix`**: Contains bootloader configurations, including settings for systemd, GRUB, and various boot-time parameters.
- **`net.nix`**: Defines network configuration, including firewall rules, IP forwarding, DNS settings, and network interfaces.
- **`users/` directory**: Houses user definitions and general user configurations.
  - **`default.nix`**: Defines user accounts and points to Home Manager configurations for each.
  - **`kiosk-home.nix`**: Home Manager configuration for the kiosk user, setting up the user environment.
  - **`kioskadmin-home.nix`**: Home Manager configuration for the kiosk admin user, including administrative tools and settings.
- **`sw.nix`**: Specifies the software environment, including Home Assistant, system packages, services like SSH, Docker containers, and customization for the desktop environment.
- **`disks.nix`**: Drive configuration and mounting definitions.

## Features

This configuration incorporates numerous features tailored for a kiosk setup:

- Silent and pretty boot process with customized splash screens.
- Auto-login for a kiosk user with a predefined environment.
- Comprehensive network setup with secure defaults and easy customization options.
- Seamless integration of services like SSH, printing support, and virtualization.
- Detailed user environment configurations using Home Manager for both kiosk and admin users.

## Usage

This repository is meant to be imported into another system flake configuration. 

## Customization

- To change boot options, edit `boot.nix`.
- Network settings can be adjusted in `net.nix`.
- User-specific configurations are located in the `users/` directory, where you can add or modify user environments.
- For software and service adjustments, see `sw.nix`.

