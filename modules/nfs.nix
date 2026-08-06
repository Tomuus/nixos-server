{ ... }:

{
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /shares/bigblack 100.0.0.0/8(rw,sync,no_subtree_check,all_squash,anonuid=1002,anongid=991,insecure,fsid=1)
    /shares/megaraid 100.0.0.0/8(rw,sync,no_subtree_check,crossmnt,all_squash,anonuid=1002,anongid=991,insecure,fsid=2)
    /shares/piectb 100.0.0.0/8(rw,sync,no_subtree_check,crossmnt,all_squash,anonuid=1002,anongid=991,insecure,fsid=3)

    /shares/bigblack 192.168.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1002,anongid=991,insecure,fsid=1)
    /shares/megaraid 192.168.0.0/24(rw,sync,no_subtree_check,crossmnt,all_squash,anonuid=1002,anongid=991,insecure,fsid=2)
    /shares/piectb 192.168.0.0/24(rw,sync,no_subtree_check,crossmnt,all_squash,anonuid=1002,anongid=991,insecure,fsid=3)
  '';

  # Copied straight out of nixos wiki

  services.nfs.server = {
    # fixed rpc.statd port; for firewall
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = "";
  };
  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
  };
}
