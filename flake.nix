{
  description = "A flake for building xlsx-validator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      xlsx-validator = pkgs.buildDotnetPackage rec {
        pname = "xlsx-validator";
        baseName = pname; # workaround for "called without baseName"
        version = "1.0";

        # Source directory containing the .NET project
        src = ./XlsxValidator;

        # The main project file
        projectFile = ["./XlsxValidator.csproj"];

        # Any patches to apply to the project
        patches = [ ./0001-patch-csproj-to-find-the-openxml-dll.patch ];

        # Pre-build actions to include the OpenXML dependency manually
        preBuild = ''
          set -xe
          cp -r ${pkgs.callPackage ./nix/openxml.nix { }}/lib ./lib
          ls
          ls ./lib/dotnet/DocumentFormat.OpenXml
        '';

        # Dependencies required for the build
        nativeBuildInputs = [
          pkgs.pkg-config
        ];
      };
    };

    defaultPackage.x86_64-linux = self.packages.xlsx-validator;

    devShell = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        pkg-config
        dotnet-sdk
      ];
    };
  };
}
