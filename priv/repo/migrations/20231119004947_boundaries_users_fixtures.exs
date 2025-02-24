defmodule Bonfire.Boundaries.Repo.Migrations.BoundariesUsersFixturesUp do
  use Ecto.Migration

  def up() do
    Bonfire.Boundaries.Scaffold.Users.up()
  end

  def down, do: :ok
end
