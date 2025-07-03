let
  loki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFOI6pZqWnvS+ePkQkvaKNnzs1sgsXldEcLiWZ/T99t root@loki";
in
{
  "pmp_key.age".publicKeys = [ loki ];
}
