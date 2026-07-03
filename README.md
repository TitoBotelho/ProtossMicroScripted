# Protoss Micro Bot (Ares Framework)

A micro bot for RL training in a combat arena.

This project uses the [ares-sc2](https://github.com/AresSC2/ares-sc2) framework with minimal logic:

- Fixed race: Protoss
- No economy and no macro
- No build order
- This project is built to train RL bots and will evolve gradually as those RL bots improve over time.

## Current behavior

In `bot/main.py`:

- The bot inherits from `AresBot`
- In `on_start`, the build runner is disabled using `set_build_completed()`
- In `on_step`, the bot uses the normal Ares loop (`super().on_step(...)`)
- Then it registers `AMove` for every combat unit (except `Probe`)

In `run.py`:

- Local map is forced to `MicroAIArenaT2R8`
- Default bot race is set to `Protoss`

## Requirements

- Python 3.11
- Poetry
- Git
- StarCraft II installed
- Micro map available in the SC2 maps folder

## Installation

With the project already cloned:

```bash
poetry install
```

If the `ares-sc2` submodule is empty:

```bash
git submodule update --init --recursive
poetry install
```

## Run locally

```bash
poetry run python run.py
```

If SC2 is installed in a different location, update `MAPS_PATH` in `run.py`.

## Basic configuration

You can set bot name and race in `config.yml`:

```yml
MyBotName: ProtossMicroScripted
MyBotRace: Protoss
```

Note: `run.py` already sets Protoss by default. If you set another value in `config.yml`, it can override that.

## Relevant structure

- `bot/main.py`: bot logic
- `run.py`: local execution and map selection
- `config.yml`: name/race/general config
- `protoss_builds.yml`: present in the project, but not used by this micro bot

## Publish to a new GitHub repository

Quick checklist:

```bash
git init
git add .
git commit -m "Initial commit: Protoss micro A-move bot"
git branch -M main
git remote add origin https://github.com/<your-username>/<new-repo>.git
git push -u origin main
```

If this project already has history and you only want to change the remote:

```bash
git remote remove origin
git remote add origin https://github.com/<your-username>/<new-repo>.git
git push -u origin main
```
