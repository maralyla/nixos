{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
      ms-python.python
      hashicorp.terraform
      ms-azuretools.vscode-docker
    ];
  };
  programs.zsh.shellAliases.code = "codium";
}