{
  description = "NixOS + Proxmox + Pulumi Infrastructure Lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.proxmox-template = nixos-generators.nixosGenerate {
      inherit system;
      format = "proxmox";
      modules = [ ./configuration.nix ];
    };

    local-vm = nixos-generators.nixosGenerate {
      inherit system;
      format = "qcow";
      modules = [ ./configuration.nix ];
    }; 

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pulumi-bin
        kubectl
        kubernetes-helm

        # Languages for Pulumi
        nodejs_22         
        
        proxmox-backup-client
        # libguestfs-with-appliance # derivation is broken on RHEL9
                                    # with IdM
      ];

      shellHook = ''
        echo "--- 🚀 Infrastructure Lab Environment Loaded ---"
        echo "Pulumi version: $(pulumi version)"
        echo "NixOS target: 25.11"
        
        # Set Pulumi to use local state
        export PULUMI_BACKEND_URL="file://$(pwd)"
      '';
    };
  };
}
