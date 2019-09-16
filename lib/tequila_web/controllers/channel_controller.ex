defmodule TequilaWeb.ChannelController do
  use TequilaWeb, :controller

  alias Tequila.Channels
  alias Tequila.Channels.Channel
  alias Tequila.Index

  def index(conn, _params) do
    case Channels.get_default_for_user(conn.assigns[:current_user]) do
      nil ->
        redirect(conn, to: Routes.channel_path(conn, :new))

      default_channel ->
        redirect(conn, to: Routes.channel_path(conn, :show, default_channel))
    end
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

  def show(conn, %{"id" => id} = params) do
    page = Map.get(params, "page", "1")
    channel = Channels.get_channel!(id)
    current_user = conn.assigns[:current_user].id
    current_page = case Integer.parse(page) do
      {parsed, _rest} -> parsed
      :error -> 1
    end

    case channel.owner_id do
      ^current_user ->
        {entries, has_next, has_prev} = Index.search!(channel.query, page: current_page)
        prev_page = max(current_page - 1, 1)
        next_page = current_page + 1
        render(conn, "show.html", channel: channel, entries: entries, has_next: has_next, has_prev: has_prev, prev_page: prev_page, next_page: next_page)

      _ ->
        conn
        |> put_flash(:error, gettext("You are not authorized to view this channel"))
        |> redirect(to: Routes.channel_path(conn, :index))
    end
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
