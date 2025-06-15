{ pkgs, ... }:
{
  services.deluge = {
    enable = true;
    web.enable = true;
  };

  # binding deluged to network namespace
  systemd.services.deluged = {
    bindsTo = [ "vpn_wg.service" ];
    after = [ "vpn_wg.service" ];
    unitConfig.JoinsNamespaceOf = "netns@vpn_wg.service";
    serviceConfig.PrivateNetwork = true;
  };

  # allowing delugeweb to access deluged in network namespace, a socket is necesarry
  systemd.sockets."proxy-to-deluged" = {
    enable = true;
    description = "Socket for Proxy to Deluge Daemon";
    listenStreams = [ "58846" ];
    wantedBy = [ "sockets.target" ];
  };

  # creating proxy service on socket, which forwards the same port from the root namespace to the isolated namespace
  systemd.services."proxy-to-deluged" = {
    enable = true;
    description = "Proxy to Deluge Daemon in Network Namespace";
    requires = [
      "deluged.service"
      "proxy-to-deluged.socket"
    ];
    after = [
      "deluged.service"
      "proxy-to-deluged.socket"
    ];
    unitConfig = {
      JoinsNamespaceOf = "deluged.service";
    };
    serviceConfig = {
      User = "deluge";
      Group = "deluge";
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
      PrivateNetwork = "yes";
    };
  };
}
