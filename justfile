default:
  @just --list

sources: sources-nixos sources-nvim

# update nixos sources
sources-nixos:
  nvfetcher -c nixos/pkgs/sources.toml -o nixos/pkgs/_sources

# update (neo)vim plugins sources
sources-nvim:
  nvfetcher -c home/vimPlugins/sources.toml -o home/vimPlugins/_sources

sources-home:
  nvfetcher -c home/overlays/sources.toml -o home/overlays/_sources

# only works on a single host
# uses ssh ControlMaster to only use 1 SSH connection for deploy
deploy:
  DEPLOY_HOST=$1
  MODE=${2:-switch}
  ssh -M -N -f "deploy@$DEPLOY_HOST"
  colmena apply "$MODE" --on "$DEPLOY_HOST"
  ssh -O exit "deploy@$DEPLOY_HOST"
