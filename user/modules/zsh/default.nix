{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./aliases.nix
    ./plugins.nix
    ./functions
  ];
  home.packages = with pkgs; [
    carapace
  ];
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;

    initExtra = ''
      source <(carapace _carapace zsh)

      bindkey '^ ' autosuggest-accept
      AGKOZAK_CMD_EXEC_TIME=5
      AGKOZAK_COLORS_CMD_EXEC_TIME='yellow'
      AGKOZAK_COLORS_PROMPT_CHAR='magenta'
      AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' )
      AGKOZAK_MULTILINE=0
      AGKOZAK_PROMPT_CHAR=( ❯ ❯ ❮ )
      autopair-init

      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line

      unalias lsd # where does that come from anyway?

      alias -s pdf="setsid xdg-open"

      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
    '';

    envExtra = ''
      path=("$HOME/.local/bin" $path)
      #export PYTHON_KEYRING_BACKEND=keyring_pass.PasswordStoreBackend
    '';

    profileExtra = ''
      stty -ixon # disable ctrl-s, ctrl-q
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
