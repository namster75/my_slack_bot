# MySlackBot

## Background
Our team has standup meeting every morning. To give each member a chance to run the standup, it would be nice to have a bot that randomly selects a team member to run it.

## Supported Commands
Currently, this app supports these following commands
* `add`
  - add a member's name into the channel's member list
  - i.e. `/add John`
* `delete`
  - delete a member from the channel's member list
  - i.e. `/delete John`
* `list`
  - list the channel's member list
  - i.e. `/list`
* `pick`
  - randomly select a member's name from the member list then send a message to the Slack channel
  - i.e. `/pick` -> `John, you have been picked to run the standup!`
  - a *optional* parameter can be used for the message
  - i.e `/pick today is your lucky day.` -> `John, today is your lucky day`
* `add-task`
  - add a scheduled task to run a *command* for the channel
  - supported parameters
    1. `--name` *task-name*
    2. `--day` *Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday*
    3. `--hour` *0 - 23*
    4. `--minute` *0 - 59`
    5. `--command` *pick*
    6. `--command-args` *you have been randomly picked to run the standup!*
  - i.e `/add-task --name task-1 --day monday --day tuesday --day wednesday --day thursday --hour 10 --minute 0 --command pick --command-args "you have been randomly picked to run the standup!"`
* `delete-task`
  - delete a task from the channel's task list
  - i.e. `/delete-task task-1`
* `list-tasks`
  - list the channel's task list
  - i.e. `/list-tasks`


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
