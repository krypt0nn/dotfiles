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
                            "968846770752856104"
                            "910873173808017488"
                            "910873266795737138"
                            "913441788893732864"
                            "1525460785285828708"
                            "910871818158628954"
                            "1517941649676828906"
                            "1517945573024465017"
                            "1517948353285980482"
                            "1517945635066872099"
                            "1517941420453789988"
                            "1517941463512649728"
                            "1523030746879492208"
                            "1517941501546463433"
                            "1518364715816976474"
                            "1517941546480177303"
                            "1517952010186526720"
                            "1517941588989444127"
                            "1243320450243891261"
                            "1517951542953513103"
                            "1099041689085157487"
                            "1463877200922022101"
                            "1480270401039765818"
                            "1312027711509758042"
                            "1221929438241886301"
                            "1274566688787922987"
                            "1308509001423650817"
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

                    rules = {
                        messages_retention = "28d";

                        agent = {
                            enable = true;
                            api_url = "http://192.168.1.10:9020/v1";
                            api_token = "";
                            model_name = "default";
                            max_context = 8192;
                            max_turn_steps = 10;
                            channel_history = 7;
                            operators = modsList;
                        };

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
