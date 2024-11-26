# NOTE: not currently used, WIP
let
  hyperlinkRules = {
    # This is actually the default if you don't specify any hyperlink_rules
    default = {
      regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b";
      format = "$0";
    };
    # linkify email addresses
    emailAddresses = {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b";
      format = "mailto:$0";
    };
    # Make task numbers clickable
    # {regex = "\\b[tT](\\d+)\\b"; format = "https://example.com/tasks/?t=$1" }

    # Linkify things that look like URLs

    # file:// URI
    fileUrls = {
      regex = "\\bfile://\\S*\\b";
      format = "$0";
    };
    # nixpkgs review current program
    nixPkgsReview = {
      regex = "nixpkgs-review pr (\\d+)";
      format = "https://github.com/NixOS/nixpkgs/pull/$1";
    };
    nixPksReviewAlt = {
      regex = "pr-(\\d+)-?\\d?";
      format = "https://github.com/NixOS/nixpkgs/pull/$1";
    };
    # nix flake github references
    nixFlakeGithub = {
      regex = "github:([\\w\\d_-]+)/([\\w\\d_\\.-]+)";
      format = "https://github.com/$1/$2";
    };
    # nix flake github references with commit
    nixFlakeGithubCommit = {
      regex = "github:([\\w\\d_-]+)/([\\w\\d_\\.-]+)/([\\d\\w-]+)";
      format = "https://github.com/$1/$2/commit/$3";
    };
    # git ssh remote url
    gitSshRemote = {
      regex = "git@(\\w+\\.\\w+):(\\w+/\\w+)\\.git";
      format = "https://$1/$2";
    };
    # go packages on github.com
    goPackagesGithub = {
      regex = "github.com/([\\w_-]+)/([\\w_-]+)";
      format = "https://github.com/$1/$2";
    };
  };
in
hyperlinkRules
