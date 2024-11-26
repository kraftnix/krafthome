args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;
  cfg = config.khome.shell.git;
in
{
  options.khome.shell.git = {
    enable = mkEnableOption "enable xplr";
    enableDelta = mkEnableOption "enable delta pager";
    enableDifftastic = mkEnableOption "enable difftastic pager" // {
      default = true;
    };
  };

  config = {
    home.packages =
      [ ]
      ++ (optionals cfg.enableDifftastic [ pkgs.difftastic ])
      ++ (optionals cfg.enableDelta [ pkgs.delta ]);
    programs.git = {
      enable = true;
      delta = mkIf cfg.enableDelta {
        enable = true;
        options = {
          #side-by-side = true;
          features = "decorations";
        };
      };
      difftastic = mkIf cfg.enableDifftastic {
        enable = true;
        background = "dark";
        color = "auto";
        display = "side-by-side-show-both";
      };
      extraConfig = {
        # pager = {
        #   diff = "difft";
        #   show = "difft";
        #   log = "difft";
        #   reflog = "difft";
        # };
        pull.rebase = true;

        # colors
        color = {
          ui = true;
          diff-highlight = {
            oldNormal = "red bold";
            oldHighlight = "red bold 52";
            newNormal = "green bold";
            newHighlight = "green bold 22";
          };
          diff = {
            meta = "11";
            frag = "magenta bold";
            func = "146 bold";
            commit = "yellow bold";
            old = "red bold";
            new = "green bold";
            whitespace = "red reverse";
          };
        };
      };

      aliases = {
        a = "add -p";
        co = "checkout";
        cob = "checkout -b";
        f = "fetch -p";
        c = "commit";
        p = "push";
        ba = "branch -a";
        bd = "branch -d";
        bD = "branch -D";
        d = "diff";
        dc = "diff --cached";
        ds = "diff --staged";
        r = "restore";
        rs = "restore --staged";
        st = "status -sb";

        # reset
        soft = "reset --soft";
        hard = "reset --hard";
        s1ft = "soft HEAD~1";
        h1rd = "hard HEAD~1";

        # logging
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
        tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
        rank = "shortlog -sn --no-merges";

        # delete merged branches
        bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
      };
    };
  };
}
