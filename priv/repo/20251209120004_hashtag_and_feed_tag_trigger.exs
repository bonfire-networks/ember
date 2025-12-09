defmodule Ember.Repo.Migrations.TaggedOrFeedActivityIntegrationTrigger do
  use Ecto.Migration
alias Ember.TaggedOrFeedActivityIntegration

  def up do
    TaggedOrFeedActivityIntegration.up()
  end

  def down do
    TaggedOrFeedActivityIntegration.down()
  end
end
