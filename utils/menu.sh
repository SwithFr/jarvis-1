#!/bin/bash

# Jarvis main menu
jv_main_menu () {
    while [ "$no_menu" = false ]; do
        options=('Start Jarvis'
                 'Settings'
                 'Commands (what JARVIS can understand and execute)'
                 'Events (what JARVIS monitors and notifies you about)'
                 'Plugins (commands from community)'
                 'Search for updates'
                 'Help / Report a problem'
                 'About')
        case "`dialog_menu \" Jarvis - v$jv_version\n$headline\" options[@]`" in
            Start*)
                while true; do
                    options=('Start normally' 'Troubleshooting mode' 'Keyboard mode' 'Start as a service')
                    case "`dialog_menu 'Start Jarvis' options[@]`" in
                        "Start normally")
                            break 2;;
                        "Troubleshooting mode")
                            verbose=true
                            break 2;;
                        "Keyboard mode")
                            keyboard=true
                            quiet=true
                            break 2;;
                        "Start as a service")
                            jv_start_in_background
                            exit;;
                        *) break;;
                    esac
                done;;
            Settings)
                while true; do
                    options=('Step-by-step wizard'
                             'General'
                             'Phrases'
                             'Hooks'
                             'Audio'
                             'Voice recognition'
                             'Speech synthesis')
                    case "`dialog_menu 'Configuration' options[@]`" in
                        "General")
                            while true; do
                                options=("Username ($username)"
                                         "Trigger mode ($trigger_mode)"
                                         "Magic word ($trigger)"
                                         "Show possible commands ($show_commands)"
                                         "Multi-command separator ($separator)"
                                         "Conversation mode ($conversation_mode)"
                                         "Language ($language)"
                                         "Check Updates on Startup ($check_updates)"
                                         "Repository Branch ($jv_branch)"
                                         "Usage Statistics ($send_usage_stats)")
                                case "`dialog_menu 'Configuration > General' options[@]`" in
                                    Username*) configure "username";;
                                    Trigger*) configure "trigger_mode";;
                                    Magic*word*) configure "trigger";;
                                    Show*commands*) configure "show_commands";;
                                    Multi-command*separator*) configure "separator";;
                                    Conversation*) configure "conversation_mode";;
                                    Language*) configure "language";;
                                    Check*Updates*) configure "check_updates";;
                                    Repository*Branch*) configure "jv_branch";;
                                    Usage*Statistics*) configure "send_usage_stats";;
                                    *) break;;
                                esac
                            done;;
                        "Phrases")
                            while true; do
                                options=("Startup greetings ($phrase_welcome)" "Trigger reply ($phrase_triggered)" "Unknown order ($phrase_misunderstood)" "Command failed ($phrase_failed)")
                                case "`dialog_menu 'Configuration > Phrases' options[@]`" in
                                    Startup*greetings*) configure "phrase_welcome";;
                                    Trigger*reply*)     configure "phrase_triggered";;
                                    Unknown*order*)     configure "phrase_misunderstood";;
                                    Command*failed*)    configure "phrase_failed";;
                                    *) break;;
                                esac
                            done;;
                        "Hooks")
                        while true; do
                            options=("Program startup"
                                     "Start listening"
                                     "Stop listening"
                                     "Listening timeout"
                                     "Entering command mode"
                                     "Start speaking"
                                     "Stop speaking"
                                     "Exiting command mode"
                                     "Program exit")
                            case "`dialog_menu 'Configuration > Hooks' options[@]`" in
                                Program*startup*)   configure "program_startup";;
                                Program*exit*)      configure "program_exit";;
                                Entering*)          configure "entering_cmd";;
                                Exiting*)           configure "exiting_cmd";;
                                Listening*timeout)  configure "listening_timeout";;
                                Start*listening*)   configure "start_listening";;
                                Stop*listening*)    configure "stop_listening";;
                                Start*speaking*)    configure "start_speaking";;
                                Stop*speaking*)     configure "stop_speaking";;
                                *) break;;
                            esac
                        done;;
                        "Audio")
                            while true; do
                                options=("Speaker ($play_hw)"
                                         "Mic ($rec_hw)"
                                         "Recorder ($recorder)"
                                         "Auto-adjust levels"
                                         "Volume"
                                         "Sensitivity"
                                         "Gain ($gain)"
                                         "Min noise duration to start ($min_noise_duration_to_start)"
                                         "Min noise perc to start ($min_noise_perc_to_start)"
                                         "Min silence duration to stop ($min_silence_duration_to_stop)"
                                         "Min silence level to stop ($min_silence_level_to_stop)")
                                case "`dialog_menu 'Configuration > Audio' options[@]`" in
                                    Speaker*)  configure "play_hw";;
                                    Mic*)      configure "rec_hw";;
                                    Recorder*) configure "recorder";;
                                    Auto*)     jv_auto_levels;;
                                    Volume) if [ "$platform" == "osx" ]; then
                                                osascript <<EOM
                                                    tell application "System Preferences"
                                                        activate
                                                        set current pane to pane "com.apple.preference.sound"
                                                        reveal (first anchor of current pane whose name is "output")
                                                    end tell
EOM
                                            else
                                                alsamixer -c ${play_hw:3:1} -V playback || read -p "ERROR: check above"
                                            fi;;
                                    Sensitivity)
                                    if [ "$platform" == "osx" ]; then
                                                osascript <<EOM
                                                    tell application "System Preferences"
                                                        activate
                                                        set current pane to pane "com.apple.preference.sound"
                                                        reveal (first anchor of current pane whose name is "input")
                                                    end tell
EOM
                                            else
                                                alsamixer -c ${rec_hw:3:1} -V capture || read -p "ERROR: check above"
                                            fi;;
                                    Gain*)            configure "gain";;
                                    *duration*start*) configure "min_noise_duration_to_start";;
                                    *perc*start*)     configure "min_noise_perc_to_start";;
                                    *duration*stop*)  configure "min_silence_duration_to_stop";;
                                    *level*stop*)     configure "min_silence_level_to_stop";;
                                    *) break;;
                                esac
                            done;;
                        "Voice recognition")
                            while true; do
                                options=("Recognition of magic word ($trigger_stt)"
                                         "Recognition of commands ($command_stt)"
                                         "Snowboy settings"
                                         "Bing settings"
                                         "Wit settings"
                                         "PocketSphinx setting")
                                case "`dialog_menu 'Settings > Voice recognition' options[@]`" in
                                    Recognition*magic*word*)    configure "trigger_stt";;
                                    Recognition*command*)       configure "command_stt";;
                                    Snowboy*)
                                        while true; do
                                            options=("Show trained hotwords/commands"
                                                     "Token ($snowboy_token)"
                                                     "Train a hotword/command"
                                                     "Sensitivity ($snowboy_sensitivity)"
                                                     "Check ticks ($snowboy_checkticks)")
                                            case "`dialog_menu 'Settings > Voice recognition > Snowboy' options[@]`" in
                                                Check*)         configure "snowboy_checkticks";;
                                                Show*)          IFS=','; dialog_msg "Models stored in stt_engines/snowboy/resources/:\n${snowboy_models[*]}";;
                                                Sensitivity*)   configure "snowboy_sensitivity";;
                                                Token*)         configure "snowboy_token";;
                                                Train*)         stt_sb_train "$(dialog_input "Hotword / Quick Command to (re-)train" "$trigger")" true;;
                                                *) break;;
                                            esac
                                        done;;
                                    Bing*)
                                            while true; do
                                                options=("Bing key ($bing_speech_api_key)")
                                                case "`dialog_menu 'Settings > Voice recognition > Bing' options[@]`" in
                                                    Bing*key*)  configure "bing_speech_api_key";;
                                                    *) break;;
                                                esac
                                            done;;
                                    Wit*)
                                        while true; do
                                            options=("Wit key ($wit_server_access_token)")
                                            case "`dialog_menu 'Settings > Voice recognition > Wit' options[@]`" in
                                                Wit*)   configure "wit_server_access_token";;
                                                *) break;;
                                            esac
                                        done;;
                                    PocketSphinx*)
                                        while true; do
                                            options=("PocketSphinx dictionary ($dictionary)"
                                                     "PocketSphinx language model ($language_model)"
                                                     "PocketSphinx logs ($pocketsphinxlog)")
                                            case "`dialog_menu 'Settings > Voice recognition > PocketSphinx' options[@]`" in
                                                PocketSphinx*dictionary*)   configure "dictionary";;
                                                PocketSphinx*model*)        configure "language_model";;
                                                PocketSphinx*logs*)         configure "pocketsphinxlog";;
                                                *) break;;
                                            esac
                                        done;;
                                    *) break;;
                                esac
                            done;;
                        "Speech synthesis")
                            while true; do
                                options=("Speech engine ($tts_engine)" "OSX voice ($osx_say_voice)" "Cache folder ($tmp_folder)") #"Voxygen voice ($voxygen_voice)" 
                                case "`dialog_menu 'Configuration > Speech synthesis' options[@]`" in
                                    Speech*engine*) configure "tts_engine";;
                                    #Voxygen*voice*) configure "voxygen_voice";;
                                    OSX*voice*)     configure "osx_say_voice";;
                                    Cache*folder*)  configure "tmp_folder";;
                                    *) break;;
                                esac
                            done;;
                        "Step-by-step wizard")
                            wizard;;
                        *) break;;
                    esac
                done
                configure "save";;
            Commands*)
                editor jarvis-commands
                #update_commands
                ;;
            Events*)
                dialog_msg <<EOM
    WARNING: JARVIS currently uses Crontab to schedule monitoring & notifications
    This will erase crontab entries you may already have, check with:
        crontab -l
    If you already have crontab rules defined, add them to JARVIS events:
        crontab -l >> jarvis-events
    Press [Ok] to start editing Event Rules
EOM
                editor jarvis-events &&
                crontab jarvis-events -i;;
            Plugins*)
                menu_store
                ;;
            Help*)
                dialog_msg <<EOM
    A question?
    http://domotiquefacile.fr/jarvis/content/support

    A problem or enhancement request?
    Create a ticket on GitHub
    https://github.com/alexylem/jarvis/issues/new

    Just want to discuss?
    http://domotiquefacile.fr/jarvis/content/disqus
EOM
                ;;
            "About") dialog_msg <<EOM
    JARVIS
    By Alexandre Mély

    http://domotiquefacile.fr/jarvis
    alexandre.mely@gmail.com
    (I don't give support via email, please check Help)

    You like Jarvis? consider making a 1€ donation:
    http://domotiquefacile.fr/jarvis/content/credits

    JARVIS is freely distributable under the terms of the MIT license.
EOM
                ;;
            "Search for updates")
                jv_check_updates
                jv_update_config # apply config updates
                jv_plugins_check_updates
                ;;
            *) exit;;
        esac
    done
}

menu_store_browse () { # $1 (optional) sorting, $2 (optionnal) space separated search terms
    
    local plugins=()
    local category=""
    
    if [ -n "$2" ]; then
        # Retrieve list of plugins for these search terms
        while read plugin; do
            plugins+=("$plugin")
        done <<< "$(store_search_plugins "$2")"
        category="Results"
    else
        # Select Category    
        category="`dialog_menu 'Categories' categories[@]`"
        if [ -z "$category" ] || [ "$category" == "false" ]; then
            return
        fi
        
        # Retrieve list of plugins for this Category
        while read plugin; do
            plugins+=("$plugin")
        done <<< "$(store_list_plugins "$category" "$1")"
    fi
    
    while true; do        
        # Select plugin
        local plugin_title="`dialog_menu \"$category\" plugins[@]`"
        
        [ -z "$plugin_title" ] && break
        if [ -z "$plugin_title" ] || [ "$plugin_title" == "false" ]; then
            break
        fi
        
        local plugin_url=$(store_get_field "$plugin_title" 'repo') #https://github.com/alexylem/jarvis
        
        while true; do
            # Display plugin details
            store_display_readme "$plugin_url"
            
            # Plugin menu
            local options=("Info"
                     "Install")
            case "`dialog_menu \"$plugin_title\" options[@]`" in
                Info)    continue;;
                Install) 
                         store_install_plugin "$plugin_url"
                         break 2;;
                *)       break;;
            esac
        done
    done
}

menu_store () {
    store_init
    categories=("All")
    while read line; do
        categories+=("$line")
    done <<< "$(store_get_categories)"
    
    while true; do
        shopt -s nullglob
        nb_installed=(plugins/*/)
        shopt -u nullglob
        
        options=("Installed (${#nb_installed[@]})"
                 "Matching Order"
                 "Search"
                 "Browse ($(store_get_nb_plugins))" # total
                 "New Plugins" #TODO X new since last visit
                 "Top Plugins" #TODO top X
                 "Install from URL" #TODO also as jarvis option argument
                 "Publish your Plugin")
        case "`dialog_menu 'Plugins' options[@]`" in
            Installed*) if [ "${#nb_installed[@]}" -gt 0 ]; then
                            cd plugins/
                            while true; do
                                shopt -s nullglob
                                options=(*)
                                shopt -u nullglob
                                local plugin="`dialog_menu 'Installed' options[@]`"
                                if [ -n "$plugin" ] && [ "$plugin" != "false" ]; then
                                    cd "$plugin"
                                    local plugin_git_url="$(git config --get remote.origin.url)"
                                    local plugin_url="${plugin_git_url%.*}"
                                    cd ../
                                    options=("Info"
                                             "Configure"
                                             "Update"
                                             "Rate"
                                             "Report an issue"
                                             "Reinstall"
                                             "Uninstall")
                                    while true; do
                                        case "`dialog_menu \"$plugin\" options[@]`" in
                                            Info)
                                                store_display_readme "$plugin_url"
                                                ;;
                                            Configure)
                                                editor "$plugin/config.sh"
                                                ;;
                                            Update)
                                                echo "Checking for updates..."
                                                cd "$plugin"
                                                git pull &
                                                jv_spinner $!
                                                jv_press_enter_to_continue
                                                cd ../
                                                ;;
                                            Rate)
                                                dialog_msg "$(store_get_field_by_repo "$plugin_url" "url")#comment-form"
                                                ;;
                                            Report*)
                                                dialog_msg "$plugin_url/issues/new"
                                                ;;
                                            Reinstall)
                                                source "$plugin/install.sh"
                                                dialog_msg "Installation Complete"
                                                ;;
                                            Uninstall)
                                                if dialog_yesno "Are you sure?" true >/dev/null; then
                                                    store_plugin_uninstall "$plugin"
                                                    dialog_msg "Uninstallation Complete"
                                                    break 2
                                                fi
                                                ;;
                                            *)  break;;
                                        esac
                                    done
                                else
                                    break
                                fi
                            done
                            cd ../
                        fi
                        ;;
            Matching*)  dialog_msg <<EOM
This is to edit the order in which the plugin commands are evaluated
Put at the bottom plugins with generic patterns, such as Jeedom or API
EOM
                        editor plugins_order.txt
                        jv_plugins_order_rebuild
                        ;;
            Search*)    local search_terms="$(dialog_input "Search in Plugins (keywords seperate with space)" "$search_terms")"
                        menu_store_browse "" "$search_terms"
                        ;;
            Browse*)    menu_store_browse;;
            New*)       menu_store_browse "date";;
            Top*)       menu_store_browse "rating";;
            Install*)   local plugin_url="$(dialog_input "Repo URL, ex: https://github.com/alexylem/time")"
                        [ -z "$plugin_url" ] && continue
                        store_install_plugin "$plugin_url"
                        ;;
            Publish*)   dialog_msg <<EOM
Why keeping your great Jarvis commands just for you?
Share them and have the whole community using them!
It's easy, and a great way to make one's contribution to the project.
Procedure to publish your commands on the Jarvis Store:
http://domotiquefacile.fr/jarvis/content/publish-your-plugin
EOM
                        ;;
            *) break;;
        esac
    done
}
