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

    if [[ "''${STATUS}" == "connected" ]]; then
        echo "🔒 $(mullvad status -j | jq '.details.location.city' -r)"
    else
        echo "🔓"
    fi
  '';
  weather = pkgs.writeScriptBin "weather.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    curl -s 'wttr.in/North+Bend+WA?format=3&u' | sed 's/+/ /g' | tr '\n' ' '

  '';
  stock-price = pkgs.writeScriptBin "stock-price.sh" ''
    #!${pkgs.bash}/bin/bash

    set -eu
    export PMP_KEY=$(cat "${config.age.secrets.pmp_key.path}")
    stock-ticker --tickers GOOG
  '';
}
