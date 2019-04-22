defmodule PtolemyWeb.ChannelController do
  use PtolemyWeb, :controller

  alias Ptolemy.Channels
  alias Ptolemy.Channels.Channel
  alias Ptolemy.Index

  def index(conn, _params) do
    default_channel = Channels.get_default_for_user(conn.assigns[:current_user])
    redirect(conn, to: Routes.channel_path(conn, :show, default_channel))
  end

  def new(conn, _params) do
    changeset = Channels.change_channel(%Channel{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"channel" => channel_params}) do
    case Channels.create_channel(channel_params, conn.assigns[:current_user]) do
      {:ok, channel} ->
        conn
        |> put_flash(:info, gettext("Channel created successfully."))
        |> redirect(to: Routes.channel_path(conn, :show, channel))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    channel = Channels.get_channel!(id)
    entries = Index.search(channel.query)
    render(conn, "show.html", channel: channel, entries: entries)
  end

  def edit(conn, %{"id" => id}) do
    channel = Channels.get_channel!(id)
    changeset = Channels.change_channel(channel)
    render(conn, "edit.html", channel: channel, changeset: changeset)
  end

  def update(conn, %{"id" => id, "channel" => channel_params}) do
    channel = Channels.get_channel!(id)

    case Channels.update_channel(channel, channel_params) do
      {:ok, channel} ->
        conn
        |> put_flash(:info, gettext("Channel updated successfully."))
        |> redirect(to: Routes.channel_path(conn, :show, channel))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", channel: channel, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    channel = Channels.get_channel!(id)
    {:ok, _channel} = Channels.delete_channel(channel)

    default_channel = Channels.get_default_for_user(conn.assigns[:current_user])

    conn
    |> put_flash(:info, gettext("Channel deleted successfully."))
    |> redirect(to: Routes.channel_path(conn, :show, default_channel))
  end
end
