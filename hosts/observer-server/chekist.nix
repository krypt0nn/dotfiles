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

            database.cleanup_interval = "12h";

            guilds = [
                {
                    guild_id = "910869215857217596";

                    channels = {
                        logs_id = "913441788893732864";
                        reports_id = "1525460785285828708";
                        whitelist = [];
                        blacklist = [
                            "910871800924229654"  # rules
                            "910871843324456970"  # announcements
                            "1104440225222111262" # trailblazers
                            "968846770752856104"  # mod-rules
                            "910873173808017488"  # mod-announcements
                            "913441788893732864"  # mod-logs
                            "1525460785285828708" # mod-reports
                            "917438648809570354"  # faq
                            "910871818158628954"  # repository-updates
                        ];

                        special = [
                            {
                                # i-wanna-leave-the-server
                                channel_id = "1525860388405514270";

                                auto_ban = {
                                    enable = true;
                                    exceptions = modsList;
                                };
                            }
                            {
                                # memes
                                channel_id = "1018900818029727774";

                                filter_text_messages = {
                                    enable = true;
                                    whitelist = modsList;
                                    blacklist = [];
                                    exceptions = [
                                        # Allow links (message embeddings)
                                        ''(https?://)?[\da-z.-]+\.[a-z.]{2,6}([/\w .-]*/?)?''

                                        # Allow emojis
                                        ''<a?:\w+:\d+>''
                                    ];
                                };
                            }
                            {
                                # tech-news
                                channel_id = "1345289710544748585";

                                filter_text_messages = {
                                    enable = true;
                                    whitelist = modsList;
                                    blacklist = [];
                                    exceptions = [
                                        # Only allow messages with a link
                                        ''(https?://)?[\da-z.-]+\.[a-z.]{2,6}([/\w .-]*/?)?''
                                    ];
                                };
                            }
                        ];
                    };

                    commands = {
                        mute = {
                            enable = true;
                            operators = modsList;
                        };

                        kick = {
                            enable = true;
                            operators = modsList;
                        };

                        ban = {
                            enable = true;
                            operators = modsList;
                        };

                        audit = {
                            enable = true;
                            operators = modsList;
                        };
                    };

                    agent = {
                        enable = true;
                        api_url = "http://127.0.0.1:9020/v1";
                        model_name = "qwen3-1.7b";
                        max_context = 8192;
                        max_turn_steps = 10;
                        channel_history = 5;
                        operators = modsList;
                    };

                    rules = {
                        messages_retention = "28d";

                        logs = {
                            joined_members = true;
                            left_members = true;
                            updated_messages = false;
                            deleted_messages = true;
                            muted_members = true;
                            kicked_members = true;
                            banned_members = true;
                        };
                    };
                }
            ];
        };
    };

    environment.persistence."/persistent" = {
        hideMounts = true;

        directories = [
            "/var/lib/chekist"
        ];
    };
}
