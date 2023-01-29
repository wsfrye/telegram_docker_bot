#!/bin/bash
# -----------------------------------------------------------------------------
# https://github.com/wsfrye/telegram_docker_bot
# -----------------------------------------------------------------------------
# A bash script to listen to docker events. When a docker container is
# stopped, started, paused or unpaused, it will send a message to a Telegram
# chat via a Telegram bot.
# -----------------------------------------------------------------------------
# One could use this script via cron to be sure it keeps running.
# */30 * * * * /usr/bin/telegram_docker_bot.sh > /dev/null 2>&1
################################################################################
# Make sure we're not already running
PID_FILE="$HOME/telegram_docker_bot.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)

    if ps -p $PID > /dev/null 2>&1; then
        echo "Process with PID $PID is already running."
        exit
    else
        echo $BASHPID > $PID_FILE
    fi
else
    echo $BASHPID > $PID_FILE
fi

# Initialize the Telegram bot API
. ~/telegram_docker_bot.env

# Start listening for container events
docker events --filter event=start --filter event=stop --filter event=pause --filter event=unpause | while read event; do
    event_data=($event)
    event_type=${event_data[2]}
    container_id=${event_data[3]}
    container_name=$(basename $(docker inspect --format='{{.Name}}' $container_id))

    # Build messages
    # FYI, a newline needs to be sent as %0A
    declare -A events
    events["start"]="Container <b><i>$container_name</i></b> with ID <i>$container_id</i> has been <b>started</b>."
    events["stop"]="Container <b><i>$container_name</i></b> with ID <i>$container_id</i> has been <b>stopped</b>."
    events["pause"]="Container <b><i>$container_name</i></b> with ID <i>$container_id</i> has been <b>paused</b>."
    events["unpause"]="Container <b><i>$container_name</i></b> with ID <i>$container_id</i> has been <b>unpaused</b>."

    # Telegram Message Parse Mode
    # Options: Markdown, MarkdownV2, HTML
    # https://core.telegram.org/bots/api#formatting-options
    telegram_parsemode="HTML"

    # Send updates to Telegram for container events
    url="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=${events[$event_type]}"
    url+=$( [[ $silent_notifications = "true" ]] && echo "&disable_notification=1" )
    url+=$( [[ ! -z "$telegram_parsemode" ]] && echo "&parse_mode=$telegram_parsemode" )
    curl -s -X GET "$url"
done
