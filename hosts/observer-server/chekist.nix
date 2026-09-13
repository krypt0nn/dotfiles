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
                guild_id = "910869215857217596";

                channels.blacklist = [
                    "910871800924229654"  # rules
                    "910871843324456970"  # announcements
                    "1104440225222111262" # trailblazers
                    "968846770752856104"  # mod-rules
                    "910873173808017488"  # mod-announcements
                    "917438648809570354"  # faq
                    "910871818158628954"  # repository-updates
                    "1111152418172964916" # ban-reports
                    "1463877200922022101" # capybara-times
                    "1221929438241886301" # starboard
                    "1274566688787922987" # owoboard
                    "1308509001423650817" # noskillboard
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
                ];

                agent = {
                    enable = true;
                    api_url = "https://openrouter.ai/api/v1";
                    api_request = {
                        model = "z-ai/glm-5.3-flash";
                        providers = {
                            zdr = true;
                            data_collection = "deny";
                            quantizations = ["fp8"];
                        };
                    };
                    enable_vision = true;
                    channel_context = 7;
                    max_context = 65536;
                    max_loop_steps = 100;
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
