Code.eval_file("mess.exs", if(File.exists?("../../lib/mix/mess.exs"), do: "../../lib/mix/"))

defmodule Ember.MixProject do
  use Mix.Project

  def project do
    if System.get_env("AS_UMBRELLA") == "1" do
      [
        build_path: "../../_build",
        config_path: "../../config/config.exs",
        deps_path: "../../deps",
        lockfile: "../../mix.lock"
      ]
    else
      []
    end ++
      [
        app: :ember,
        version: "0.0.1",
        elixir: "~> 1.10",
        elixirc_paths: elixirc_paths(Mix.env()),
        compilers: Mix.compilers(),
        start_permanent: Mix.env() == :prod,
        aliases: aliases(),
        description: "A flavour of Bonfire",
        homepage_url: "https://bonfirenetworks.org/",
        source_url: "https://github.com/bonfire-networks/ember",
        package: [
          licenses: ["AGPL-3.0"],
          links: %{
            "Repository" => "https://github.com/bonfire-networks/ember",
            "Hexdocs" => "https://hexdocs.pm/ember"
          }
        ],
        docs: [
          # The first page to display from the docs
          main: "readme",
          # extra pages to include
          extras: ["README.md"]
        ],
        deps:
          Mess.deps(
            [
              {:phoenix_live_reload, "~> 1.2", only: :dev},
              {:floki, ">= 0.0.0", only: [:dev, :test]},
              {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
              {:finch, "~> 0.16"},
              # {:tz, "~> 0.26.2"},

              # tests
              {:mneme, ">= 0.0.0", only: [:dev, :test]},

              # error reporting
              {:sentry, "~> 10.0", optional: true},
              {:orion, "~> 1.0.5"},
              # {:live_admin, #"~> 0.12.0"
              # git: "https://github.com/bonfire-networks/live_admin"
              # },

              # API
              # {:exonerate, "~> 1.1.3", runtime: Mix.env() != :prod},
              # {:yaml_elixir, "~> 2.9"},

              ## dev conveniences
              {:phoenix_live_reload, "~> 1.3", optional: true},
              {:pbkdf2_elixir, "~> 2.0", optional: true}
            ] ++
              if(System.get_env("AS_DESKTOP_WEBAPP") in ["1", "true"],
                do: [
                  {:elixirkit,
                   git: "https://github.com/livebook-dev/livebook", sparse: "elixirkit"}
                ],
                else: []
              ) ++
              if(System.get_env("AS_DESKTOP_APP") in ["1", "true"],
                do: [
                  {:desktop, github: "elixir-desktop/desktop"}
                ],
                else: []
              ) ++
              if(System.get_env("WITH_API_GRAPHQL") == "yes",
                do: [
                  {:absinthe, "~> 1.7"},
                  {:bonfire_api_graphql,
                   git: "https://github.com/bonfire-networks/bonfire_api_graphql"},
                  {:absinthe_client, git: "https://github.com/bonfire-networks/absinthe_client"}
                ],
                else: []
              )
          )
      ]
  end

  def application, do: [extra_applications: [:logger, :runtime_tools]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "hex.setup": ["local.hex --force"],
      "rebar.setup": ["local.rebar --force"],
      "js.deps.get": ["cmd npm install --prefix assets"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      setup: [
        "hex.setup",
        "rebar.setup",
        "deps.get",
        "ecto.setup",
        "js.deps.get"
      ],
      updates: ["deps.get", "ecto.migrate", "js.deps.get"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "ecto.seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
