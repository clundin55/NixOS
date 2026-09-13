# The *.clundin.dev services live behind Caddy on odin:8888, normally
# reached via a TLS-passthrough proxy on carl-rpi (name -> carl-rpi:443 ->
# odin:8888). Resolve them to loopback instead and proxy straight to odin:
# the LAN address when reachable, seamlessly falling back to odin's
# tailscale address when away. TLS stays end-to-end; Caddy serves the
# *.clundin.dev certificate and routes by SNI/Host, so one passthrough
# covers every endpoint.
{ ... }:
let
  clundinHosts = map (name: "${name}.clundin.dev") [
    "prowlarr"
    "radarr"
    "sonarr"
    "lidarr"
    "qbittorrent"
    "jellyfin"
    "immich"
    "vaultwarden"
    "pihole"
    "karakeep"
  ];
in
{
  networking.hosts = {
    "127.0.0.1" = clundinHosts;
    "::1" = clundinHosts;
  };

  services.nginx = {
    enable = true;
    streamConfig = ''
      upstream odin-caddy {
        server 192.168.50.33:8888 max_fails=1 fail_timeout=10s;
        server 100.113.49.85:8888 backup;
      }
      server {
        listen 127.0.0.1:443;
        listen [::1]:443;
        proxy_pass odin-caddy;
        proxy_connect_timeout 2s;
      }
    '';
  };
}
