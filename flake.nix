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
      format = "qcow2";
      modules = [ ./configuration.nix ];
    }; 

    devShells.${system}.default = pkgs.mkShell {
      # These tools are available only inside this shell
      buildInputs = with pkgs; [
        pulumi-bin        # The Pulumi CLI
        kubectl           # To talk to your k3s cluster
        kubernetes-helm   # If you use Helm charts in k3s
        
        # Languages for Pulumi
        nodejs_22         
        
        # Proxmox/Virtualization tools
        proxmox-backup-client
        libguestfs-with-appliance # Handy for inspecting VM images locally
      ];

      shellHook = ''
        echo "--- 🚀 Infrastructure Lab Environment Loaded ---"
        echo "Pulumi version: $(pulumi version)"
        echo "NixOS target: 25.11"
        
        # Set Pulumi to use local state if you don't want to use their SaaS
        export PULUMI_BACKEND_URL="file://$(pwd)"
        
        # Help text for your future self
        alias build-template="nix build .#proxmox-template"
        alias deploy="pulumi up"
      '';
    };
  };
}
