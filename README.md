# telegram_docker_bot
This bash script can be used to send docker event (stop, start, pause, unpause) updates to a specific chat_id using the Telegram Bot API.

# Usage
To use it, update the relevant environmental variables, make it executable (chmod +x), and execute it.

# Run Unattended
If you would like to run the script unattended, you can set up a cron job to execute it on a schedule.

In this example, we will try to execute the script every 30 minutes:
```bash
*/30 * * * * /usr/bin/telegram_docker_bot.sh > /dev/null 2>&1
```

The script will check for the presence of a PID file. If one is found, it will verify that the process identified by the PID file is currently running. If it is, the script will exit. If no PID file is present, or if the process identified by the PID file is not running, the script will create the PID file and then continue execution. In the event that the script is unexpectedly terminated, the next cron job will check for process listed in the PID file and continue execution if it is not running.

# Optional
Additionally, you can set the silent_notifications="true" environmental variable to disable notifications in your Telegram app. Any other value will be evaluated as false. 
