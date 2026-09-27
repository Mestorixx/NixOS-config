{ pkgs, ... }:

let
  qnum = 200;
  fakeTls = "${pkgs.zapret}/usr/share/zapret/files/fake/tls_clienthello_www_google_com.bin";
  fakeDiscord = "${pkgs.zapret}/usr/share/zapret/files/fake/discord-ip-discovery-with-port.bin";

  zapretRules = pkgs.writeText "zapret.nft" ''
    table inet zapret {
      chain output {
        type filter hook output priority -1; policy accept;
        oifname "lo" accept
        tcp dport { 80, 443 } ct state new,established queue num ${toString qnum} bypass
        udp dport 443 reject
        udp dport 50000-65535 ct state new,established queue num ${toString qnum} bypass
      }
    }
  '';
in
{
  boot.kernelModules = [ "nf_conntrack" "xt_NFQUEUE" ];

  systemd.services.zapret = {
    description = "Zapret DPI bypass service";
    after = [ "network-online.target" "nftables.service" ];
    wants = [ "network-online.target" ];
    # wantedBy = [ "multi-user.target" ]; # Отключено от автозагрузки
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;

      ExecStartPre = pkgs.writeShellScript "zapret-nft-setup" ''
        ${pkgs.nftables}/bin/nft delete table inet zapret 2>/dev/null || true
        ${pkgs.nftables}/bin/nft -f ${zapretRules}
      '';

      ExecStart = "${pkgs.zapret}/bin/nfqws --qnum=${toString qnum} --filter-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=badseq --new --filter-tcp=443 --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-autottl=2 --dpi-desync-fooling=badseq --dpi-desync-fake-tls=${fakeTls} --new --filter-udp=50000-65535 --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d1 --dpi-desync-fake-unknown-udp=${fakeDiscord}";

      ExecStopPost = pkgs.writeShellScript "zapret-nft-cleanup" ''
        ${pkgs.nftables}/bin/nft delete table inet zapret 2>/dev/null || true
      '';
    };
  };
}
