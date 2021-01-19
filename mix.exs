defmodule VisionQuest.MixProject do
  use Mix.Project

  def project do
    [
      app: :vision_quest,
      version: "0.1.0",
      elixir: "~> 1.10-rc",
      start_permanent: Mix.env() == :prod,
      escript: [
        main_module: VisionQuest.CLI,
        name: "vq",
        emu_args: ["-sname vision_quest -setcookie P6IJCYXOHFT4G3XS7AETBNNPRV62KS5YXCS7ECLNCLIJBHPJWIBA===="]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
