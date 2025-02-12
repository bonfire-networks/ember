defmodule Mix.Tasks.Ember.Install do
  use Igniter.Mix.Task
  alias Bonfire.Common.Mix.Tasks.Helpers

  @shortdoc "Install an extension into the parent app"
  @doc """
  Usage:
  `just mix social.install`
  """

  @app :ember

  def igniter(igniter, args) do
    # IO.inspect(args, label: "Args")

    igniter
    # then we run custom tasks for this flavour
    |> Helpers.igniter_copy(Path.join(Application.app_dir(@app), "priv/templates/"), "lib/")
    |> Helpers.igniter_copy(Path.join(Application.app_dir(@app), "config/"), "config/")
    |> Helpers.igniter_copy(Path.wildcard(Application.app_dir(@app), "deps.*"), "config/")
    # finally we run the standard installer for this flavour (which includes copying `config/ember.exs` and migrations)
    |> Igniter.compose_task(Mix.Tasks.Bonfire.Extension.Installer, [@app]) 
  end 

end
