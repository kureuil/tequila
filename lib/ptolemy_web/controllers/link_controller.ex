defmodule PtolemyWeb.LinkController do
  use PtolemyWeb, :controller

  alias Ptolemy.Index
  alias Ptolemy.Index.Link

  def new(conn, _params) do
    changeset = Index.change_submit(%Index.Submit{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"submit" => submit_params}) do
    case Index.create_submit(submit_params, conn.assigns[:current_user]) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: Routes.link_path(conn, :show, link))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    link = Index.get_link!(id)
    render(conn, "show.html", link: link)
  end

  def edit(conn, %{"id" => id}) do
    link = Index.get_link!(id)
    submit = Link.to_submit(link)
    changeset = Index.change_submit(submit)
    render(conn, "edit.html", link: link, changeset: changeset)
  end

  def update(conn, %{"id" => id, "submit" => submit_params}) do
    link = Index.get_link!(id)

    case Index.update_submit(link, submit_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: Routes.link_path(conn, :show, link))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", link: link, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    link = Index.get_link!(id)
    {:ok, _link} = Index.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: Routes.channel_path(conn, :index))
  end
end
