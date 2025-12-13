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
    ${pkgs.curl}/bin/curl -s 'wttr.in/North+Bend+WA?format=3&u' | sed 's/+/ /g' | tr '\n' ' '

  '';
  stock-price = pkgs.writeScriptBin "stock-price.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    export PMP_KEY=$(cat "${config.age.secrets.pmp_key.path}")
    ${stock-ticker}/bin/stock-ticker --tickers GOOGL
  '';
}
