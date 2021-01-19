defmodule VisionQuest.CLI do
  alias VisionQuest.Settings

  def main([pattern]) do
    {:ok, path} = File.cwd()
    main([path, pattern])
  end

  def main([path, pattern]) do
    with {:ok, settings} <- Settings.load() do
      VisionQuest.find_first(path, pattern, settings)
    else
      _ ->
        VisionQuest.find_first(path, pattern)
    end
    |> IO.puts
  end

  def main(_) do
    IO.puts("usage:")
    IO.puts("vq {pattern}")
    IO.puts("vq {path} {pattern}")
  end

end
