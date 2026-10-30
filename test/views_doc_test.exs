defmodule Ember.Views.DocTest do
  use Bonfire.UI.Me.ConnCase, async: false

  doctest Bonfire.Web.Components.HomeHeroLive

  setup do
    # both loaders are cached for hours: start every test from the current DB state
    Bonfire.Me.Users.list_declared_moderators(cache: :reset)
    Bonfire.Social.Pins.list_spotlight_activities(cache: :reset)
    Bonfire.UI.Groups.WidgetGroupsCarouselLive.list_guest_groups(cache: :reset)
    :ok
  end
end
