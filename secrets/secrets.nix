let
  loki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFOI6pZqWnvS+ePkQkvaKNnzs1sgsXldEcLiWZ/T99t root@loki";
  freia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYZmwM5fljuQF2JpA/pPMmFI26wiYJP/+Ka1HIIELTF root@freia";
in
{
  "pmp_key.age".publicKeys = [
    loki
    freia
  ];
  "user_pass.age".publicKeys = [
    loki
    freia
  ];
  "namecheap-api.age".publicKeys = [
    loki
    freia
  ];
}
