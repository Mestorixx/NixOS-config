{ pkgs, ... }:

let
  qnum = 200;

  binDir = ./zapret/bin;
  listsDir = ./zapret/lists;

  fakeQuicGoogle = "${binDir}/quic_initial_www_google_com.bin";
  fakeDiscordUdp = "${binDir}/ACTIVE_DISCORD_UDP.bin";
  fakeTlsGoogle  = "${binDir}/tls_clienthello_www_google_com.bin";
  fakeStun       = "${binDir}/stun.bin";
  fakeHttpMaxRu  = "${binDir}/tls_clienthello_max_ru.bin";

  listGeneral    = "${listsDir}/list-general.txt";
  listGoogle     = "${listsDir}/list-google.txt";
  listExclude    = "${listsDir}/list-exclude.txt";
  ipsetExclude   = "${listsDir}/ipset-exclude.txt";
  ipsetAll       = "${listsDir}/ipset-all.txt";

  # Правила nftables:
  # 1. predefrag с priority -401: пакеты nfqws (mark 0x40000000) помечаются notrack,
  #    чтобы сгенерированные фейки не ломали conntrack и не переводили соединения в INVALID.
  # 2. output: исключаем mark 0x40000000, чтобы избежать дедлока и повторного попадания фейков в очередь.
  # 3. ct original packets 1-12: перехватываем только фазу рукопожатия (TLS ClientHello / HTTP GET),
  #    весь последующий поток данных (видео, скачивание) идет напрямую через ядро без оверхеда.
  zapretRules = pkgs.writeText "zapret.nft" ''
    table ip zapret {
      chain predefrag {
        type filter hook output priority -401; policy accept;
        meta mark and 0x40000000 != 0 notrack
      }

      chain output {
        type filter hook output priority -1; policy accept;
        oifname "lo" accept

        # Пропускаем пакеты, сгенерированные самим nfqws (защита от зацикливания и зависания)
        meta mark and 0x40000000 != 0 accept

        # HTTP, HTTPS, Discord Media (рукопожатие: 1-12 пакетов)
        tcp dport { 80, 443, 2053, 2083, 2087, 2096, 8443 } ct original packets 1-12 queue num ${toString qnum} bypass

        # QUIC (YouTube, Google)
        udp dport 443 ct original packets 1-6 queue num ${toString qnum} bypass

        # Discord Voice / WebRTC
        udp dport 19294-19344 queue num ${toString qnum} bypass
        udp dport 50000-50100 queue num ${toString qnum} bypass
      }
    }
  '';
in
{
  boot.kernelModules = [ "nf_conntrack" "nft_queue" ];

  # Либеральная проверка TCP-окон conntrack (предотвращает сброс соединений при фейковых TCP пакетах)
  boot.kernel.sysctl = {
    "net.netfilter.nf_conntrack_tcp_be_liberal" = 1;
  };

  systemd.services.zapret = {
    description = "Zapret DPI bypass service (Flowseal ALT preset)";
    after = [ "network-online.target" "nftables.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;

      ExecStartPre = pkgs.writeShellScript "zapret-nft-setup" ''
        ${pkgs.nftables}/bin/nft delete table inet zapret 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table ip zapret 2>/dev/null || true
        ${pkgs.nftables}/bin/nft -f ${zapretRules}
      '';

      ExecStart = ''${pkgs.zapret}/bin/nfqws \
        --qnum=${toString qnum} \
        --filter-udp=443 \
          --hostlist=${listGeneral} \
          --hostlist-exclude=${listExclude} \
          --ipset-exclude=${ipsetExclude} \
          --dpi-desync=fake \
          --dpi-desync-repeats=6 \
          --dpi-desync-fake-quic=${fakeQuicGoogle} \
        --new \
        --filter-udp=19294-19344,50000-50100 \
          --filter-l7=discord,stun \
          --dpi-desync=fake \
          --dpi-desync-fake-discord=${fakeDiscordUdp} \
          --dpi-desync-fake-stun=${fakeDiscordUdp} \
          --dpi-desync-repeats=6 \
        --new \
        --filter-tcp=2053,2083,2087,2096,8443 \
          --hostlist-domains=discord.media \
          --dpi-desync=fake,fakedsplit \
          --dpi-desync-repeats=6 \
          --dpi-desync-fooling=ts \
          --dpi-desync-fakedsplit-pattern=0x00 \
          --dpi-desync-fake-tls=${fakeTlsGoogle} \
        --new \
        --filter-tcp=443 \
          --hostlist=${listGoogle} \
          --ip-id=zero \
          --dpi-desync=fake,fakedsplit \
          --dpi-desync-repeats=6 \
          --dpi-desync-fooling=ts \
          --dpi-desync-fakedsplit-pattern=0x00 \
          --dpi-desync-fake-tls=${fakeTlsGoogle} \
        --new \
        --filter-tcp=80,443 \
          --hostlist=${listGeneral} \
          --hostlist-exclude=${listExclude} \
          --ipset-exclude=${ipsetExclude} \
          --dpi-desync=fake,fakedsplit \
          --dpi-desync-repeats=6 \
          --dpi-desync-fooling=ts \
          --dpi-desync-fakedsplit-pattern=0x00 \
          --dpi-desync-fake-tls=${fakeStun} \
          --dpi-desync-fake-tls=${fakeTlsGoogle} \
          --dpi-desync-fake-http=${fakeHttpMaxRu} \
        --new \
        --filter-udp=443 \
          --ipset=${ipsetAll} \
          --hostlist-exclude=${listExclude} \
          --ipset-exclude=${ipsetExclude} \
          --dpi-desync=fake \
          --dpi-desync-repeats=6 \
          --dpi-desync-fake-quic=${fakeQuicGoogle} \
        --new \
        --filter-tcp=80,443,8443 \
          --ipset=${ipsetAll} \
          --hostlist-exclude=${listExclude} \
          --ipset-exclude=${ipsetExclude} \
          --dpi-desync=fake,fakedsplit \
          --dpi-desync-repeats=6 \
          --dpi-desync-fooling=ts \
          --dpi-desync-fakedsplit-pattern=0x00 \
          --dpi-desync-fake-tls=${fakeStun} \
          --dpi-desync-fake-tls=${fakeTlsGoogle} \
          --dpi-desync-fake-http=${fakeHttpMaxRu}
      '';

      ExecStopPost = pkgs.writeShellScript "zapret-nft-cleanup" ''
        ${pkgs.nftables}/bin/nft delete table inet zapret 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table ip zapret 2>/dev/null || true
      '';
    };
  };
}
