defmodule MySlackBot.SlackApi.SlackCommandTest do
  use MySlackBot.DataCase

  alias MySlackBot.ChatgptPrompts
  alias MySlackBot.SlackApi.SlackCommand
  alias MySlackBot.SlackApi.SlackBot

  describe "process_list_members_command/1" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns {:ok, []} when no members", %{channel: %{channel_id: channel_id}} do
      assert {:ok, []} = SlackCommand.process_list_members_command(channel_id)
    end

    test "returns the one member in the channel", %{channel: %{channel_id: channel_id}} do
      {:ok, %{name: member_name}} = SlackBot.add_member(channel_id, "member1")
      {:ok, [name | _]} = SlackCommand.process_list_members_command(channel_id)
      assert name == member_name
    end
  end

  describe "process_add_member_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns :ok when the member is added", %{channel: %{channel_id: channel_id}} do
      assert {:ok, _} = SlackCommand.process_add_member_command(channel_id, "member1")
    end

    test "returns :error when the member already exists", %{channel: %{channel_id: channel_id}} do
      {:ok, _} = SlackBot.add_member(channel_id, "member1")
      assert {:error, _} = SlackCommand.process_add_member_command(channel_id, "member1")
    end
  end

  describe "process_delete_member_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns :ok when the member is deleted", %{channel: %{channel_id: channel_id}} do
      {:ok, _} = SlackBot.add_member(channel_id, "member1")
      assert {:ok, _} = SlackCommand.process_delete_member_command(channel_id, "member1")
    end

    test "returns :error when the member does not exist", %{channel: %{channel_id: channel_id}} do
      assert {:error, _} = SlackCommand.process_delete_member_command(channel_id, "member1")
    end
  end

  describe "process_pick_member_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns an empty list if no member in the channel", %{channel: %{channel_id: channel_id}} do
      assert {:ok, "no members to pick"} = SlackCommand.process_pick_member_command(channel_id, "message")
    end

    test "returns a randomized member from the member list", %{channel: %{channel_id: channel_id}} do
      {:ok, _} = SlackBot.add_member(channel_id, "member1")
      {:ok, _} = SlackBot.add_member(channel_id, "member2")
      {:ok, _} = SlackBot.add_member(channel_id, "member3")
      {:ok, _} = SlackBot.add_member(channel_id, "member4")
      assert {:ok, reply} = SlackCommand.process_pick_member_command(channel_id, ", is picked to do the task")
      assert reply =~ "is picked to do the task"
    end
  end

  describe "parse_add_member_command/1" do
    test "return add_task parameters" do
      assert {:ok,
      %{
        command: :pick,
        command_argument: ", you got picked!",
        days: %{monday: true, wednesday: true},
        hour: 10,
        minute: 30,
        name: "task1",
        status: :active
      }} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --day \"Monday\" --day \"Wednesday\" --hour 10 --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "return error name is required" do
      assert {:error, %{message: "--name is required"}} =
        SlackCommand.parse_add_task_command_args(
          "--day \"Monday\" --day \"Wednesday\" --hour 10 --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "return error day is required" do
      assert {:error, %{message: "--day is required"}} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --hour 10 --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "return error day is invalid" do
      assert {:error, %{message: "invalid day: Monday1"}} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --day \"Monday1\" --day \"Wednesday\" --hour 10 --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "return error hour is required" do
      assert {:error, %{message: "--hour is required"}} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --day \"Monday\" --day \"Wednesday\" --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "return error minute is required" do
      assert {:error, %{message: "--minute is required"}} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --day \"Monday\" --day \"Wednesday\" --hour 10 --command pick --command-args \", you got picked!\"")
    end

    test "return error command is required" do
      assert {:error, %{message: "--command is required"}} =
        SlackCommand.parse_add_task_command_args(
          "--name \"task1\" --day \"Monday\" --day \"Wednesday\" --hour 10 --minute 30  --command-args \", you got picked!\"")
    end
  end

  describe "process_list_tasks_command/1" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns an empty list if no task in the channel", %{channel: %{channel_id: channel_id}} do
      assert {:ok, []} = SlackCommand.process_list_tasks_command(channel_id)
    end

    test "returns tasks in the channel", %{channel: %{channel_id: channel_id}} do
      {:ok, _} =
        SlackBot.add_task(
          channel_id,
          "task 1",
          %{
            monday: false,
            tuesday: true,
            wednesday: true,
            thursday: true,
            friday: false,
            saturday: false,
            sunday: false
          },
          9,
          20,
          :active,
          :pick,
          "pick 1")

      {:ok, _} =
        SlackBot.add_task(
          channel_id,
          "task 2",
          %{
            monday: false,
            tuesday: true,
            wednesday: true,
            thursday: true,
            friday: false,
            saturday: false,
            sunday: false
          },
          9,
          0,
          :active,
          :pick,
          "pick 2")

      {:ok, tasks} = SlackCommand.process_list_tasks_command(channel_id)

      assert Enum.count(tasks) == 2
    end
  end

  describe "process_add_task_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns a new pick task", %{channel: %{channel_id: channel_id}} do
      assert {:ok, _} =
        SlackCommand.process_add_task_command(
          channel_id,
          "--name \"task1\" --day \"Monday\" --day \"Wednesday\" --hour 10 --minute 30 --command pick --command-args \", you got picked!\"")
    end

    test "returns a new generate_random_prompt task", %{channel: %{channel_id: channel_id}} do
      assert {:ok, _} =
        SlackCommand.process_add_task_command(
          channel_id,
          "--name \"task2\" --day \"Monday\" --day \"Wednesday\" --hour 10 --minute 30 --command generate_random_prompt")
    end
  end

  describe "process_delete_task_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns a new task", %{channel: %{channel_id: channel_id}} do
      {:ok, task} =
        SlackBot.add_task(
          channel_id,
          "task 1",
          %{
            monday: false,
            tuesday: true,
            wednesday: true,
            thursday: true,
            friday: false,
            saturday: false,
            sunday: false
          },
          9,
          20,
          :active,
          :pick,
          "pick 1")

      {:ok, _task} =
        SlackCommand.process_delete_task_command(channel_id, task.name)
    end

    test "returns :error if the task name does not exist", %{channel: %{channel_id: channel_id}} do
      {:error, _error} =
        SlackCommand.process_delete_task_command(channel_id, "task 1")
    end
  end

  describe "process_add_prompt_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns :ok when the prompt is added", %{channel: %{channel_id: channel_id}} do
      assert {:ok, _} = SlackCommand.process_add_prompt_command(channel_id, "hello")
    end

    test "returns :error when the member already exists", %{channel: %{channel_id: channel_id}} do
      {:ok, _} = SlackCommand.process_add_prompt_command(channel_id, "hello")
      assert {:error, _} = SlackCommand.process_add_prompt_command(channel_id, "hello")
    end
  end

  describe "process_delete_prompt_command/2" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns :ok when the prompt is deleted", %{channel: %{channel_id: channel_id}} do
      {:ok, _} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello")
      assert {:ok, _} = SlackCommand.process_delete_prompt_command(channel_id, "hello")
    end

    test "returns :error when the prompt does not exist", %{channel: %{channel_id: channel_id}} do
      assert {:error, _} = SlackCommand.process_delete_prompt_command(channel_id, "hello 2")
    end
  end

  describe "process_list_prompts_command/1" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns {:ok, []} when no members", %{channel: %{channel_id: channel_id}} do
      assert {:ok, []} = SlackCommand.process_list_prompts_command(channel_id)
    end

    test "returns the one prompt in the channel", %{channel: %{channel_id: channel_id}} do
      {:ok, %{message: message}} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello")
      {:ok, [prompt_message | _]} = SlackCommand.process_list_prompts_command(channel_id)
      assert prompt_message == message
    end
  end

  describe "process_generate_random_prompt_command/1" do
    setup do
      {:ok, channel} = SlackBot.add_channel("C01", "test-channel")
      {:ok, channel: channel}
    end

    test "returns an empty list if no prompt in the channel", %{channel: %{channel_id: channel_id}} do
      assert {:ok, "no prompt to pick"} = SlackCommand.process_generate_random_prompt_command(channel_id)
    end

    test "returns a randomized prompt response from the prompts", %{channel: %{channel_id: channel_id}} do
      {:ok, p1} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello 1")
      {:ok, _p1_history} = ChatgptPrompts.add_chatgpt_prompt_history(p1.id, "hello 1 history")
      {:ok, p2} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello 2")
      {:ok, _p2_history} = ChatgptPrompts.add_chatgpt_prompt_history(p2.id, "hello 2 history")
      {:ok, p3} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello 3")
      {:ok, _p3_history} = ChatgptPrompts.add_chatgpt_prompt_history(p3.id, "hello 3 history")
      {:ok, p4} = ChatgptPrompts.add_chatgpt_prompt(channel_id, "hello 4")
      {:ok, _p4_history} = ChatgptPrompts.add_chatgpt_prompt_history(p4.id, "hello 4 history")
      assert {:ok, reply} = SlackCommand.process_generate_random_prompt_command(channel_id)
      assert reply =~ ~r/hello/
    end
  end

end
