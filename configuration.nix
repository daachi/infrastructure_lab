{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = "nixos-k3s-node"; 
  
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  services.qemuGuest.enable = true;

  environment.systemPackages = with pkgs; [
    # k3s
    # nfs-utils
    vim 
    # git
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXjNcCOraXhyQ+VHkOMhkwvL08kEiktec17F0WE5oXj ajohnsto@nrao.edu"
  ];

  system.stateVersion = "25.11"; 
}
