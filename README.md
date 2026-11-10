# Exercise: Stop the Runaway

Exercise code for the lesson **Exercise: Stop the Runaway** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

The night before a deadline, your laptop's fan is roaring. Three programs were left running in the background: one is stuck in a loop, one beeps every second, and one refuses to stop when asked nicely. Meanwhile, the video export you actually need has to keep going even when you close the terminal. Find the programs, stop them the right way, then write two small tools: one that stops any process politely before it uses force, and one that starts the export so it survives the terminal closing. A check script tells you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

**On Windows, unzip or clone this folder inside Ubuntu**, in your Linux home folder (for example `~/terminal-practice/`), not in a Windows folder under `/mnt/c`, so `chmod` works on the scripts.

## What's here

- `answers.txt`: five questions, each with a numbered line for your answer. For you to finish.
- `stop-politely.sh`: stops one process by its PID, the polite way first. For you to finish.
- `start-export.sh`: starts the export so it keeps going after the terminal closes. For you to finish.
- `export-video.sh`: a pretend video export, one line a second for ten minutes. Ready to use.
- `start-the-mess.sh`: starts the three programs in `mess/` in the background, writing into `logs/`.
- `clean-up.sh`: stops whatever the mess left running. Use it if you get stuck.
- `mess/`: the three misbehaving programs. Each one stops by itself after 30 minutes, in case you forget it.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `answers.txt` in it), make the scripts runnable, and start the mess:

```bash
chmod +x *.sh
./start-the-mess.sh
```

Then:

1. **Find the runaway.** Look at what's running with `ps aux --sort=-%cpu | head -n 5`, `pgrep -af mess/` or `top`, and answer questions 1 to 5 in `answers.txt` as you go.
2. **Stop the mess.** Stop the alarm with one `pkill` command, and the other two with `kill` and their PIDs. One of them won't stop the polite way. `pgrep -af mess/` prints nothing when they're all gone.
3. **Write `stop-politely.sh`.** Its first lines say exactly what it must do and print. Try it on a mess of your own: run `./start-the-mess.sh` again, then `./stop-politely.sh` with each PID.
4. **Write `start-export.sh`.** Its first lines say what it must do. Run it, close the terminal, open a new one, and check with `pgrep -af export-video` that the export is still going. Stop it with `pkill -f export-video` when you're done.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each question you answer and each job you finish turns its check into a ✓. The check tries your scripts on small practice processes of its own, in a throwaway folder, and stops only the processes it started. It takes about 20 seconds, because it waits the way your script does.

## The rules

- Write each answer on its numbered line, after the `)`, like the example: `0) ps aux`.
- Print each message exactly as the script's comments give it: the check compares them word for word.
- Stop only processes you started: the mess, your export, and your own practice.

## Tips

- A script runs as `bash`, so `pgrep` and `pkill` need `-f` to match the script's name in the whole command line.
- `ps -p PID > /dev/null` succeeds only while that process is running: use it in an `if`, or in a loop with `sleep 1`.
- `kill` with only a PID sends TERM. `kill -KILL PID` can't be ignored, so send it only when TERM didn't work.
- `$!` is the PID of the job you started last with `&`.
- `nohup` in front of a command makes it ignore the hang-up a closing terminal sends. `> export.log 2>&1` sends its output and its errors into the log.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
