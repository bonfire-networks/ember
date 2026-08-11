defmodule Ember.Localise do
  @moduledoc """
  Registers the object type names for gettext extraction, at compile time.

  See `Bonfire.Common.Localise.localise_object_type_names/0` for why this belongs to a flavour extension rather than to `bonfire_common` or the root app.
  """

  use Bonfire.Common.Localise

  Bonfire.Common.Localise.localise_object_type_names()
end
