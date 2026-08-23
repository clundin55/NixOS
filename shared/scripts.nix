{
  config,
  pkgs,
  stock-ticker,
  ...
}:
{
  vpn-status = pkgs.writeScriptBin "vpn-status.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    STATUS=$(mullvad status -j | jq '.state' -r)
    TAIL_STATUS=$(tailscale status --json | jq '.BackendState' -r)

    if [[ "''${STATUS}" == "connected" ]]; then
        echo "🔒 $(mullvad status -j | jq '.details.location.city' -r)"
    elif [[ "''${TAIL_STATUS}" == "Running" ]]; then
        echo "🏠"
    else
        echo "🔓"
    fi
  '';
  weather = pkgs.writeScriptBin "weather.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    NB=$(${pkgs.curl}/bin/curl -s 'wttr.in/North+Bend+WA?format=3&u' | sed 's/+/ /g' | tr -d '\n')
    STK=$(${pkgs.curl}/bin/curl -s 'wttr.in/Stockholm?format=3' | sed 's/+/ /g' | tr -d '\n')
    VIE=$(${pkgs.curl}/bin/curl -s 'wttr.in/Vienna?format=3' | sed 's/+/ /g' | tr -d '\n')
    PRG=$(${pkgs.curl}/bin/curl -s 'wttr.in/Prague?format=3' | sed 's/+/ /g' | tr -d '\n')
    ${pkgs.jq}/bin/jq -cn --arg text "$NB  $STK" --arg tooltip "$(printf '%s\n%s\n%s' "$STK" "$VIE" "$PRG")" \
      '{text: $text, tooltip: $tooltip}'
  '';
  home-firefox = pkgs.writeScriptBin "home-firefox" ''
    #!${pkgs.bash}/bin/bash

    exec ${pkgs.firefox}/bin/firefox \
      --proxy-server="socks5://localhost:9999" \
      --setpref "network.proxy.socks_remote_dns=true" \
      "$@"
  '';
  stock-price = pkgs.writeScriptBin "stock-price.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    export PMP_KEY=$(cat "${config.age.secrets.pmp_key.path}")
    GOOGL=$(${stock-ticker}/bin/stock-ticker --tickers GOOGL)
    TOOLTIP=""
    for TICKER in AMD ARM AAPL META AMZN; do
      RESULT=$(${stock-ticker}/bin/stock-ticker --tickers "$TICKER" 2>/dev/null) || continue
      TOOLTIP="$TOOLTIP$RESULT\n"
    done
    ${pkgs.jq}/bin/jq -cn --arg text "$GOOGL" --arg tooltip "$(printf "$TOOLTIP")" \
      '{text: $text, tooltip: $tooltip}'
  '';
  vpn-switch = pkgs.writeScriptBin "vpn-switch" ''
    #!${pkgs.bash}/bin/bash

    # Switch the active VPN, driven by the waybar custom/vpn menu.
    # Mullvad's kill switch blocks Tailscale, so selecting Tailscale drops
    # Mullvad first. Selecting a Mullvad exit leaves Tailscale alone.
    set -eu

    mullvad_to() {
      mullvad relay set location "$@"
      mullvad connect
    }

    case "''${1:-}" in
      tailscale) mullvad disconnect || true; tailscale up ;;
      seattle)   mullvad_to us sea ;;
      stockholm) mullvad_to se sto ;;
      barcelona) mullvad_to es bcn ;;
      off)       mullvad disconnect || true ;;
      *)
        echo "usage: vpn-switch [tailscale|seattle|stockholm|barcelona|off]" >&2
        exit 1
        ;;
    esac

    # Refresh the waybar module immediately instead of waiting for its poll.
    ${pkgs.procps}/bin/pkill -RTMIN+5 waybar || true
  '';
}
