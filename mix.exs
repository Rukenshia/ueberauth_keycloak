defmodule UeberauthKeycloak.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ueberauth_keycloak_strategy,
      version: @version,
      package: package(),
      deps: deps(),
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/Rukenshia/ueberauth_keycloak",
      homepage_url: "https://github.com/Rukenshia/ueberauth_keycloak",
      description: description(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ueberauth, :oauth2]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 0.9"},
      {:ueberauth, "~> 0.6.3"},

      # dev/test only dependencies
      {:credo, "~> 1.4.0", only: [:dev, :test]},
      {:exvcr, "~> 0.11.0", only: [:test]},

      # docs dependencies
      {:earmark, ">= 1.4.4", only: :dev},
      {:ex_doc, ">= 0.22.1", only: :dev}
    ]
  end

  defp docs do
    [main: "uebereauth_Keycloak", extras: ["README.md"]]
  end

  defp description do
    "An Ueberauth strategy for using Keycloak to authenticate your users."
  end

  defp package do
    [
      name: "ueberauth_keycloak_strategy",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jan C. <jan@ruken.pw>"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/Rukenshia/ueberauth_keycloak"}
    ]
  end
end
