{ inputs, ... }: {
    imports = [ inputs.chekist.nixosModules.default ];

    services.chekist = {
        enable = true;
        environmentFile = "/persistent/chekist.secrets";

        config = let
            modsList = [
                "303153225605840907" # krypt0n_
                "82662823523516416"  # maroxy
                "163299522074771456" # cybik
                "118563900521316353" # muffinsdesu
                "712565315074261014" # natimerry
            ];
        in {
            bot.cache = {
                messages = 10000;
                duration = "2h";
            };

            database = {
                cleanup_interval = "12h";
                messages_retention = "28d";
            };

            guilds = [{
                guild_id = "910869215857217596"; # The Dawn Winery

                channels.blacklist = [
                    # Welcome
                    "910871800924229654"  # rules
                    "910871843324456970"  # announcements
                    "1104440225222111262" # trailblazers

                    # Mod channels
                    "968846770752856104"  # mod-rules
                    "910873173808017488"  # mod-announcements

                    # Dev channels
                    "917438648809570354"  # faq
                    "910871818158628954"  # repository-updates
                    "1111152418172964916" # ban-reports

                    # Announcements channels
                    "1113025734521409556" # genshin-announcements
                    "1108393184821792808" # genshin-codes
                    "1113025688820273192" # hsr-announcements
                    "1108393287909396720" # hsr-codes
                    "1176844314870030346" # zzz-announcements
                    "1256213160004685936" # zzz-codes
                    "1242992386246840412" # wuwa-announcements
                    "1256660185481609317" # wuwa-codes
                    "1113025797247225867" # honkai-announcements
                    "1410944118930014309" # hna-announcements

                    # Bot channels
                    "1221929438241886301" # starboard
                    "1274566688787922987" # owoboard
                    "1308509001423650817" # noskillboard

                    # Secret channels
                    "1099041689085157487" # ca-discussions
                    "1463877200922022101" # ca-times
                    "1099041689085157487" # ca-debates
                    "1517941649676828906" # dwteam-general
                    "1517945573024465017" # dwteam-software
                    "1517948353285980482" # dwteam-packages
                    "1517945635066872099" # dwteam-vpn
                    "1517941420453789988" # dwteam-cdn
                    "1517941463512649728" # dwteam-email
                    "1523030746879492208" # dwteam-sso
                    "1517941501546463433" # dwteam-forgejo
                    "1518364715816976474" # dwteam-ci
                    "1517941546480177303" # dwteam-zulip
                    "1517952010186526720" # dwteam-gifs
                    "1517941588989444127" # dwteam-proton
                    "1243320450243891261" # dwteam-reveng
                    "1243320450243891261" # dwteam-meetup
                ];

                agent = {
                    enable = true;
                    api_url = "https://openrouter.ai/api/v1";
                    api_request = {
                        model = "deepseek/deepseek-v4.1-flash";
                        provider = {
                            zdr = true;
                            data_collection = "deny";
                            allow_fallbacks = true;
                            order = [
                                #               $ INPT OUTP CACHE SPEED QAT HIT
                                "relace"        # 0.13 0.52 0.003 37tps fp4 86%
                                "deepinfra/fp8" # 0.14 0.42 0.004 42tps fp8 92%
                                "wafer"         # 0.20 0.60 0.006 75tps --- 93%
                                "fireworks"     # 0.22 0.66 0.007 69tps --- 94%
                                "novita/fp8"    # 0.29 1.14 0.006 96tps fp8 83%
                            ];
                        };
                        tools = [
                            {
                                type = "openrouter:web_search";
                                max_results = 5;
                                max_total_results = 20;
                            }
                        ];
                    };
                    enable_vision = true;
                    memory_slots_num = 50;
                    context_messages_num = 7;
                    max_loop_steps = 100;
                    max_skill_duration = "1m";
                    http_fetch_max_size = "1mb";
                    stand_by_duration = "2m";
                    operators = modsList;
                };

                plugins = [
                    {
                        name = "mod_logs";
                        when = [
                            "guild_member_join"
                            "guild_member_leave"
                            "message_delete"
                        ];
                        env = {
                            logs_channel_id = "913441788893732864";
                        };
                        source = "https://git.dawn.wine/dawn-winery/chekist/raw/branch/master/plugins/mod_logs.luau";
                    }
                    {
                        name = "mod_commands";
                        when = [
                            "ready"
                            "command_use"
                        ];
                        env = {
                            logs_channel_id = "913441788893732864";
                        };
                        admin = true;
                        source = "https://git.dawn.wine/dawn-winery/chekist/raw/branch/master/plugins/mod_commands.luau";
                    }
                    {
                        name = "auto_ban_channel";
                        when = [ "message_add" ];
                        env = {
                            logs_channel_id = "913441788893732864";
                            ban_channels = "1525860388405514270";
                            delete_message_days = "1";
                        };
                        admin = true;
                        source = "https://git.dawn.wine/dawn-winery/chekist/raw/branch/master/plugins/auto_ban_channel.luau";
                    }
                    {
                        name = "attachments_channel";
                        when = [ "message_add" ];
                        env = {
                            channels = "1018900818029727774,1109591186840240212,1364910316609081374";
                        };
                        admin = true;
                        source = "https://git.dawn.wine/dawn-winery/chekist/raw/branch/master/plugins/attachments_channel.luau";
                    }
                    {
                        name = "anti_raid";
                        when = [ "message_add" ];
                        before = [ "attachments_channel" ];
                        after = [ "auto_ban_channel" ];
                        env = {
                            report_channel_id = "1525460785285828708";
                        };
                        admin = true;
                        source = "https://git.dawn.wine/dawn-winery/chekist/raw/branch/master/plugins/anti_raid.luau";
                    }
                ];
            }];
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/chekist"
        ];
    };
}
