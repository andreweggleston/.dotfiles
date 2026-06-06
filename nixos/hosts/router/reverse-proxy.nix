{
  addresses,
  interfaces,
  services,
  secrets,
  lib,
  pkgs,
}:
let
  caddypkg = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
    hash = "sha256-BKUsUoBE1IjnD9Xu8kTVkbRqqk2qvNtFDD/pvVkfRmI=";
  };
in
{
  services.caddy = {
    enable = true;
    package = caddypkg.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.nss.tools pkgs.makeWrapper ];
      buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.nss.tools pkgs.makeWrapper ];
      installPhase = ''
        ${oldAttrs.installPhase or ""}

        wrapProgram $out/bin/caddy \
          --prefix PATH : ${pkgs.nss.tools}/bin
      '';
    });
    globalConfig = ''
      local_certs
      email "admin@${secrets.external_domain}"
      acme_dns porkbun {
		    api_key ${secrets.porkbun.api_key}
		    api_secret_key ${secrets.porkbun.secret_key}
	    }
    '';
    virtualHosts = lib.listToAttrs (
      lib.concatMap (
        {
          name,
          host,
          port,
        }:
        [
        {
          name = "${name}.${secrets.internal_domain}";
          value = {
            extraConfig = ''
              reverse_proxy http://${host}.${secrets.internal_domain}:${port}
            '';
          };
        }
        {
          name = "${name}.internal.${secrets.external_domain}";
          value = {
            extraConfig = ''
              tls {
                resolvers curitiba.ns.porkbun.com fortaleza.ns.porkbun.com maceio.ns.porkbun.com salvador.ns.porkbun.com 8.8.8.8 1.1.1.1 9.9.9.9
                dns porkbun {
		              api_key ${secrets.porkbun.api_key}
		              api_secret_key ${secrets.porkbun.secret_key}
                }
              }
              reverse_proxy http://${host}.${secrets.internal_domain}:${port}
            '';
          };
        }
        ]
      ) services
    );
  };
}
