defmodule Tequila.ChannelsTest do
  use Tequila.DataCase

  alias Tequila.Channels

  describe "channels" do
    alias Tequila.Channels.Channel

    @valid_attrs %{name: "some name", query: "some query"}
    @update_attrs %{name: "some updated name", query: "some updated query"}
    @invalid_attrs %{name: nil, query: nil}

    def owner_fixture() do
      alias Tequila.Accounts

      email = "louis@person.guru"

      try do
        Accounts.get_user_by_email!(email)
      rescue
        _ in Ecto.NoResultsError ->
          {:ok, user} = Accounts.create_user(%{email: email})
          user
      end
    end

    def channel_fixture(attrs \\ %{}) do
      owner = owner_fixture()

      {:ok, channel} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Channels.create_channel(owner)

      channel
    end

    test "list_channels/0 returns all channels" do
      owner = owner_fixture()
      channel = channel_fixture()

      user_channels = Channels.list_channels_by_user(owner)
      assert length(user_channels) == 1
      [head | _tail] = user_channels
      assert head.id == channel.id
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Channels.get_channel!(channel.id).id == channel.id
    end

    test "create_channel/1 with valid data creates a channel" do
      owner = owner_fixture()
      assert {:ok, %Channel{} = channel} = Channels.create_channel(@valid_attrs, owner)
      assert channel.name == "some name"
      assert channel.query == "some query"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      owner = owner_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.create_channel(@invalid_attrs, owner)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{} = channel} = Channels.update_channel(channel, @update_attrs)
      assert channel.name == "some updated name"
      assert channel.query == "some updated query"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_channel(channel, @invalid_attrs)
      assert channel.id == Channels.get_channel!(channel.id).id
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Channels.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Channels.change_channel(channel)
    end
  end
end
