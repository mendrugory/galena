defmodule Galena.Mixfile do
  use Mix.Project

  @version  "0.1.0"

  def project do
    [app: :galena,
     version: @version,
     elixir: "~> 1.4",
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [main: "Galena", source_ref: "v#{@version}",
     source_url: "https://github.com/mendrugory/galena"]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:gen_stage, "~> 0.11.0"},
    {:ex_doc, "~> 0.12", only: :docs},]
  end

  defp package do
    %{licenses: ["MIT"],
      maintainers: ["Gonzalo Jiménez fuentes"],
      links: %{"GitHub" => "https://github.com/mendrugory/galena"}}
  end
end
