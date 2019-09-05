defmodule Tequila.IndexTest do
  use Tequila.DataCase

  alias Tequila.Index

  describe "links" do
    alias Tequila.Index.Link

    @valid_attrs %{location: "some location", title: "some title"}
    @update_attrs %{location: "some updated location", title: "some updated title"}
    @invalid_attrs %{location: nil, title: nil}

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

    def link_fixture(attrs \\ %{}) do
      owner = owner_fixture()

      {:ok, link} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Index.create_submit(owner)

      link
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Index.get_link!(link.id).id == link.id
    end

    test "create_link/1 with valid data creates a link" do
      owner = owner_fixture()
      assert {:ok, %Link{} = link} = Index.create_submit(@valid_attrs, owner)
      assert link.location == "some location"
      assert link.title == "some title"
    end

    test "create_link/1 with invalid data returns error changeset" do
      owner = owner_fixture()
      assert {:error, %Ecto.Changeset{}} = Index.create_submit(@invalid_attrs, owner)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      assert {:ok, %Link{} = link} = Index.update_submit(link, @update_attrs)
      assert link.location == "some updated location"
      assert link.title == "some updated title"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Index.update_submit(link, @invalid_attrs)
      assert link.title == Index.get_link!(link.id).title
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Index.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Index.get_link!(link.id) end
    end

    test "change_submit/1 returns a submit changeset" do
      assert %Ecto.Changeset{} = Index.change_submit(%Index.Submit{})
    end
  end
end
