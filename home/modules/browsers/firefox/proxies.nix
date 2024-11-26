{
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  ts = with types; [
    bool
    raw
    str
    int
    (listOf str)
  ];
in
{
  options.khome.browsers.firefox.proxies = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          freeformType = with types; attrsOf (oneOf ts);
          options = {
            type = mkOption {
              default = 1;
              description = "proxy type, default 1 (socks5), corresponds to `network.proxy.type`";
              type = types.ints.positive;
            };
            url = mkOption {
              default = "";
              description = "proxy url, corresponds to `network.proxy.socks`";
              type = types.str;
            };
            port = mkOption {
              default = 1080;
              description = "proxy port, corresponds to `network.proxy.socks_port`";
              type = types.ints.positive;
            };
            remoteDns =
              mkEnableOption "use remote dns, corresponds t `network.proxy.socks_remote_dns` option"
              // {
                default = true;
              };
            __opts = mkOption {
              default = {
                "network.proxy.type" = config.type;
                "network.proxy.socks" = config.url;
                "network.proxy.socks_port" = config.port;
                "network.proxy.socks_remote_dns" = config.remoteDns;
                # "network.proxy.no_proxies_on" = exceptions;
              };
              description = "final proxy related options";
            };
          };
        }
      )
    );
    default = { };
    description = "proxies to use for building firefox, only applies when `khome.browser.firefox.package` is not overridden";
  };

  config.khome.browsers.firefox.proxies = {
    au-bne-wg-socks5-302.url = "au-bne-wg-socks5-302.relays.mullvad.net";
    ca-van-wg-socks5-201.url = "ca-van-wg-socks5-201.relays.mullvad.net";
    de-ber-wg-socks5-001.url = "de-ber-wg-socks5-001.relays.mullvad.net";
    de-fra-wg-socks5-003.url = "de-fra-wg-socks5-003.relays.mullvad.net";
    de-fra-wg-socks5-009.url = "de-fra-wg-socks5-009.relays.mullvad.net";
    fi-hel-wg-socks5-101.url = "fi-hel-wg-socks5-101.relays.mullvad.net";
    fr-par-wg-socks5-003.url = "fr-par-wg-socks5-003.relays.mullvad.net";
    ch-zrh-wg-socks5-005.url = "ch-zrh-wg-socks5-005.relays.mullvad.net";
    ch-zrh-wg-socks5-003.url = "ch-zrh-wg-socks5-003.relays.mullvad.net";
    gb-lon-wg-socks5-001.url = "gb-lon-wg-socks5-001.relays.mullvad.net";
    gb-lon-wg-socks5-003.url = "gb-lon-wg-socks5-003.relays.mullvad.net";
    gb-lon-wg-socks5-006.url = "gb-lon-wg-socks5-006.relays.mullvad.net";
    gb-lon-wg-socks5-007.url = "gb-lon-wg-socks5-007.relays.mullvad.net";
    jp-osa-wg-socks5-003.url = "jp-osa-wg-socks5-003.relays.mullvad.net";
    jp-tyo-wg-socks5-001.url = "jp-tyo-wg-socks5-001.relays.mullvad.net";
    jp-tyo-wg-socks5-002.url = "jp-tyo-wg-socks5-002.relays.mullvad.net";
    nl-ams-wg-socks5-003.url = "nl-ams-wg-socks5-003.relays.mullvad.net";
    nl-ams-wg-socks5-006.url = "nl-ams-wg-socks5-006.relays.mullvad.net";
    no-svg-wg-socks5-002.url = "no-svg-wg-socks5-002.relays.mullvad.net";
    no-svg-wg-socks5-004.url = "no-svg-wg-socks5-004.relays.mullvad.net";
    no-svg-wg-socks5-006.url = "no-svg-wg-socks5-006.relays.mullvad.net";
    se-mma-wg-socks5-001.url = "se-mma-wg-socks5-001.relays.mullvad.net";
    us-chi-wg-socks5-201.url = "us-chi-wg-socks5-201.relays.mullvad.net";
    us-lax-wg-socks5-502.url = "us-lax-wg-socks5-502.relays.mullvad.net";
  };
}
