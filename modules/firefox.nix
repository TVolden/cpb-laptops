# https://wiki.nixos.org/wiki/Firefox
# https://mozilla.github.io/policy-templates/
{ ... }:

let
  amoLatest = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
in
{
  programs.firefox = {
    enable = true;
    policies = {
      DontCheckDefaultBrowser = true;
      ManagedBookmarks = import ./classroom-bookmarks.nix;
      # Skip Mozilla's first-run tour so the start page is what actually opens.
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";

      DNSOverHTTPS = {
        Enabled = false;
      };

      Homepage = {
        URL = "https://programmering.notion.site/";
        Locked = true;
        StartPage = "homepage";
      };

      WebsiteFilter = {
        Block = [
          "*://youtube.com/*"
          "*://*.youtube.com/*"
          "*://youtu.be/*"
          "*://*.youtu.be/*"
          "*://youtube-nocookie.com/*"
          "*://*.youtube-nocookie.com/*"

          # Unity WebGL build output has near-constant file naming regardless
          # of which site embeds it, so this blocks it on any host (unlike
          # modules/dns-block.nix, which only reaches domains we've already
          # named). Chromium/Brave's URLBlocklist policy cannot do mid-path
          # wildcard matching, so this is Firefox-only.
          "*://*/*.loader.js"
          "*://*/*.framework.js"
          "*://*/*.unityweb"
          "*://*/*Build/*.wasm"
          "*://*/*Build/*.data*"
        ];
      };

      SearchEngines = {
        Add = [
          {
            Name = "Qwant";
            URLTemplate = "https://www.qwant.com/?q={searchTerms}&client=opensearch";
            Method = "GET";
            IconURL = "https://www.qwant.com/favicon.ico";
            Alias = "@qwant";
            Description = "Qwant search";
            SuggestURLTemplate = "https://api.qwant.com/v3/suggest/?q={searchTerms}&client=opensearch";
          }
        ];
        Default = "Qwant";
      };

      ExtensionSettings = {
        # Qwant — required so search actually uses Qwant
        # https://addons.mozilla.org/firefox/addon/qwantcom-for-firefox/
        "qwantcomforfirefox@jetpack" = {
          install_url = amoLatest "qwantcom-for-firefox";
          installation_mode = "force_installed";
        };
        # uBlock Origin — https://github.com/gorhill/uBlock#ublock-origin
        "uBlock0@raymondhill.net" = {
          install_url = amoLatest "ublock-origin";
          installation_mode = "force_installed";
        };
        # Consent-O-Matic — https://github.com/cavi-au/Consent-O-Matic
        "gdpr@cavi.au.dk" = {
          install_url = amoLatest "consent-o-matic";
          installation_mode = "force_installed";
        };
        # Privacy Badger — https://privacybadger.org/
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = amoLatest "privacy-badger17";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
