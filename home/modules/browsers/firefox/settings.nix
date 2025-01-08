{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.browsers.firefox;
  inherit (lib)
    mkEnableOption
    mkIf
    optionalString
    mkOption
    types
    ;
in
{
  options.khome.browsers.firefox.presets = {
    enableDefaultSettings = mkEnableOption "enable default settings preset groups" // {
      default = true;
    };
    settings = mkOption {
      type = with types; attrsOf raw;
      default = { };
      description = "settings groups / profiles for enablement in firefox profiles.";
    };
  };

  config = mkIf cfg.presets.enableDefaultSettings {
    khome.browsers.firefox.presets.settings = {
      treestyleTheme = ''
        /* Hide tab bar in FF Quantum */
        @-moz-document url("chrome://browser/content/browser.xul") {
          #TabsToolbar {
            visibility: collapse !important;
            margin-bottom: 21px !important;
          }

          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
            visibility: collapse !important;
          }
        }
        #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
          opacity: 0;
          pointer-events: none;
        }
        #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
            visibility: collapse !important;
        }
      '';
      hardened = {
        ## usability settings
        "browser.startup.page" = 3; # restore prev sess
        "browser.shell.checkDefaultBrowser" = false;
        "signon.rememberSignons" = false; # disable passwords
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "media.autoplay.blocking_policy" = 2; # disable autoplay

        "app.update.auto" = false; # auto update
        "browser.search.update" = false;
        # 0309: disable sending Flash crash reports **
        "dom.ipc.plugins.flash.subprocess.crashreporter.enabled" = false;
        # 0310: disable sending the URL of the website where a plugin crashed **
        "dom.ipc.plugins.reportCrashURL" = false;
        # 0320: disable about:addons' Recommendations pane (uses Google Analytics) **
        "extensions.getAddons.showPane" = false;
        # 0321: disable recommendations in about:addons' Extensions and Themes panes [FF68+] **
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "accessibility.force_disabled" = 1;

        ## privacy settings

        ### Activity stream
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";

        ### geo settings
        "geo.provider.network.url" =
          "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "geo.provider.network.logging.enabled" = true;
        "geo.provider.use_gpsd" = false;
        "browser.region.network.url" = "";
        "browser.region.update.enabled" = false;

        ### fingerprinting
        "privacy.firstparty.isolate" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.enabled" = true;

        ### sending data
        "dom.event.clipboardevents.enabled" = false;
        "network.prefetch-next" = false;
        /*
           0602: disable DNS prefetching
          * [1] https://developer.mozilla.org/docs/Web/HTTP/Headers/X-DNS-Prefetch-Control **
        */
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        # 0603: disable predictor / prefetching **
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        /*
           0605: disable link-mouseover opening connection to linked server
          * [1] https://news.slashdot.org/story/15/08/14/2321202/how-to-quash-firefoxs-silent-requests **
        */
        "network.http.speculative-parallel-limit" = 0;
        /*
           0606: enforce no "Hyperlink Auditing" (click tracking)
          * [1] https://www.bleepingcomputer.com/news/software/major-browsers-to-prevent-disabling-of-click-tracking-privacy-risk/ **
        */
        "browser.send_pings" = false;
        "browser.send_pings.require_same_host" = true;

        ### DRM
        "media.eme.enabled" = false;
        "media.gmp-widevinecdm.enabled" = false;
        "media.gmp-widevinecdm.visible" = false;
        "media.navigator.enabled" = false;
        # disable hardware accel
        "dom.webaudio.enabled" = false;

        ### Cookies / Local Storage
        "network.cookie.cookieBehavior" = 1;
        "browser.contentblocking.category" = "custom";
        "network.cookie.thirdparty.sessionOnly" = true;
        "network.cookie.thirdparty.nonsecureSessionOnly" = true;
        "browser.cache.offline.storage.enable" = false;
        "dom.storage.next_gen" = true;
        "browser.sessionstore.privacy_level" = 2;
        "beacon.enabled" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.uitour.enabled" = false;
        "browser.uitour.url" = "";

        ### Misc
        "middlemouse.contentLoadURL" = false;
        "network.http.redirection-limit" = 10;
        "permissions.manager.defaultsUrl" = "";
        "webchannel.allowObject.urlWhitelist" = "";
        "network.IDN_show_punycode" = true;
        "browser.display.use_system_colors" = false;
        "permissions.delegation.enabled" = false;
        "browser.download.useDownloadDir" = false;
        "browser.download.hide_plugins_without_extensions" = false;
        "security.csp.enable" = true;
        "security.dialog_enable_delay" = 700;

        ### Crash reporting
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;

        ### Telemetry
        /*
           0331: disable Telemetry Coverage
          * [1] https://blog.mozilla.org/data/2018/08/20/effectively-measuring-search-in-firefox/ **
        */
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        /*
           0340: disable Health Reports
          * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to send technical... data **
        */
        "datareporting.healthreport.uploadEnabled" = false;
        /*
           0341: disable new data submission, master kill switch [FF41+]
          * If disabled, no policy is shown or upload takes place, ever
          * [1] https://bugzilla.mozilla.org/1195552 **
        */
        "datareporting.policy.dataSubmissionEnabled" = false;
        /*
           0342: disable Studies (see 0503)
          * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to install and run studies **
        */
        "app.shield.optoutstudies.enabled" = false;
        /*
           0343: disable personalized Extension Recommendations in about:addons and AMO [FF65+]
          * [NOTE] This pref has no effect when Health Reports (0340) are disabled
          * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to make personalized extension recommendations
          * [1] https://support.mozilla.org/kb/personalized-extension-recommendations **
        */
        "browser.discovery.enabled" = false;
        # 0350: disable Crash Reports **
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        /*
           0351: disable backlogged Crash Reports
          * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to send backlogged crash reports  **
        */
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        # normandy telemetry
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        # 0505: disable System Add-on updates **
        "extensions.systemAddon.update.enabled" = false;
        "extensions.systemAddon.update.url" = "";
        /*
           0506: disable PingCentre telemetry (used in several System Add-ons) [FF57+]
          * Currently blocked by 'datareporting.healthreport.uploadEnabled' (see 0340) **
        */
        "browser.ping-centre.telemetry" = false;
        # 0515: disable Screenshots **
        "extensions.screenshots.disabled" = true;
        /*
           0517: disable Form Autofill
          * [NOTE] Stored data is NOT secure (uses a JSON file)
          * [NOTE] Heuristics controls Form Autofill on forms without @autocomplete attributes
          * [SETTING] Privacy & Security>Forms and Autofill>Autofill addresses
          * [1] https://wiki.mozilla.org/Firefox/Features/Form_Autofill **
        */
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.available" = "off";
        "extensions.formautofill.creditCards.available" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.heuristics.enabled" = false;
        /*
           0518: disable Web Compatibility Reporter [FF56+]
          * Web Compatibility Reporter adds a "Report Site Issue" button to send data to Mozilla **
        */
        "extensions.webcompat-reporter.enabled" = false;

        ### Safe Browsing
        # enforce firefox blocklist
        "extensions.blocklist.enabled" = true;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";

        ### HTTP / DNS / PROXY etc.
        "network.dns.disableIPv6" = true;
        /*
           0703: disable HTTP Alternative Services [FF37+]
          * [SETUP-PERF] Relax this if you have FPI enabled (see 4000) *AND* you understand the
          * consequences. FPI isolates these, but it was designed with the Tor protocol in mind,
          * and the Tor Browser has extra protection, including enhanced sanitizing per Identity.
          * [1] https://tools.ietf.org/html/rfc7838#section-9
          * [2] https://www.mnot.net/blog/2016/03/09/alt-svc **
        */
        "network.http.altsvc.enabled" = false;
        "network.http.altsvc.oe" = false;
        /*
           0704: enforce the proxy server to do any DNS lookups when using SOCKS
          * e.g. in Tor, this stops your local DNS server from knowing your Tor destination
          * as a remote Tor node will handle the DNS request
          * [1] https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/WebBrowsers **
        */
        "network.file.disable_unc_paths" = true;
        /*
           0710: disable GIO as a potential proxy bypass vector
          * Gvfs/GIO has a set of supported protocols like obex, network, archive, computer, dav, cdda,
          * gphoto2, trash, etc. By default only smb and sftp protocols are accepted so far (as of FF64)
          * [1] https://bugzilla.mozilla.org/1433507
          * [2] https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/23044
          * [3] https://en.wikipedia.org/wiki/GVfs
          * [4] https://en.wikipedia.org/wiki/GIO_(software) **
        */
        "network.gio.supported-protocols" = "";
        "browser.taskbar.previews.enable" = false;

        # LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS
        "keyword.enabled" = false;
        "browser.fixup.alternate.enabled" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
        "browser.formfill.enable" = false;

        # SSL
        ## WARNING: may break local server HTTPS
        "security.ssl.require_safe_negotiation" = true;
        "security.tls.version.enable-deprecated" = false;
        "security.ssl.disable_session_identifiers" = true;
        "security.ssl.errorReporting.automatic" = false;
        "security.ssl.errorReporting.enabled" = false;
        "security.ssl.errorReporting.url" = "";
        "security.tls.enable_0rtt_data" = false;

        # OSCP (cert pinning)
        ## WARNING: may break local server HTTPS
        "security.ssl.enable_ocsp_stapling" = true;
        "security.OCSP.enabled" = 1;
        "security.OCSP.require" = true;

        # Certs
        "security.pki.sha1_enforcement_level" = 1;
        "security.cert_pinning.enforcement_level" = 2;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;

        # Mixed Content
        "security.mixed_content.block_active_content" = true;
        "security.mixed_content.block_display_content" = true;
        "security.mixed_content.block_object_subrequest" = true;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_send_http_background_request" = false;

        # UI SSL
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.ssl_override_behavior" = 1;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.insecure_connection_text.enabled" = true;

        # Fonts
        "gfx.font_rendering.opentype_svg.enabled" = false;
        "gfx.font_rendering.graphite.enabled" = false;

        # Headers
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.http.referer.hideOnionSource" = true;
        "privacy.donottrackheader.enabled" = true;

        # Containers
        "privacy.userContext.ui.enabled" = true;
        "privacy.userContext.enabled" = true;

        # Plugins
        "plugin.state.flash" = 0;

        # WebRTC
        "media.peerconnection.enabled" = false;
        "media.peerconnection.ice.default_address_only" = true;
        "media.peerconnection.ice.no_host" = true;
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "webgl.disabled" = true;
        "webgl.enable-webgl2" = false;
        "webgl.min_capability_mode" = true;
        "webgl.disable-fail-if-major-performance-caveat" = true;
        ## Disable screensharing
        "media.getusermedia.screensharing.enabled" = false;
        "media.getusermedia.browser.enabled" = false;
        "media.getusermedia.audiocapture.enabled" = false;

        # Window meddling / popups
        "dom.disable_window_move_resize" = true;
        "browser.link.open_newwindow" = 3; # force open new tab
        "browser.link.open_newwindow.restriction" = 0;
        "dom.disable_open_during_load" = true;
        "dom.popup_allowed_events" = "click dblclick";

        # web workers
        "dom.serviceWorkers.enabled" = false;
        "dom.push.enabled" = false;

        # DOM
        "dom.allow_cut_copy" = false;
        "dom.vibrator.enabled" = false;
        "javascript.options.asmjs" = false;
      };
    };
  };
}
