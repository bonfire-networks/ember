defmodule Ember.Views.DocTest do
  use Bonfire.UI.Me.ConnCase, async: false

  doctest Bonfire.Web.Components.HomeHeroLive


  setup do
    # both loaders are cached for hours: start every test from the current DB state
    Bonfire.UI.Me.WidgetUsersLive.list_admins(cache: :reset)
    Bonfire.UI.Reactions.InstancePins.list_activities(cache: :reset)
    Bonfire.UI.Groups.WidgetGroupsCarouselLive.list_guest_groups(cache: :reset)
    :ok
  end

end
