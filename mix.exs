defmodule UeberauthKeycloak.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :ueberauth_keycloak_strategy,
      version: @version,
      package: package(),
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/Rukenshia/ueberauth_keycloak",
      homepage_url: "https://github.com/Rukenshia/ueberauth_keycloak",
      description: description(),
      deps: deps(),
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
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.7"},

      # docs dependencies
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
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
