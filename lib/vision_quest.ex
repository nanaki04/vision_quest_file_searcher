defmodule VisionQuest do

  def look(path) do
    {:ok, files} = File.ls(path)
    files = Enum.map(files, fn file -> "#{path}/#{file}" end)

    Enum.reduce(files, {[], []}, fn file, {dirs, files} ->
      if File.dir?(file) do
        {[file | dirs], files}
      else
        {dirs, [file | files]}
      end
    end)
  end

  def find_first(path, pattern) do
    {:ok, regex} = Regex.compile(pattern)
    task = Task.async(fn ->
      find_recursive(path, regex)
    end)

    Task.await(task)
  end

  def find_first(path, pattern, settings) do
    {ext, pattern} = case Regex.run(~r/\..+$/, pattern) do
                       [extension] -> {[extension], String.replace(pattern, ~r/\..+$/, "")}
                       _ -> {[], pattern}
                     end

    result = Enum.filter(settings, fn
               {_, %{"priority" =>  _, "paths" =>  _, "extensions" =>  _}} ->
                 true
               _ ->
                 false
             end)
             |> Enum.sort_by(fn {_, %{"priority" => priority}} -> priority end)
             |> Stream.flat_map(fn
               {_, %{"paths" => paths, "extensions" => extensions}} ->
                 Stream.flat_map(ext ++ extensions, fn
                   ext -> Stream.map(paths, fn path -> {ext, path} end)
                 end)
             end)
             |> Stream.map(fn {ext, path} ->

               pattern = if String.ends_with?(pattern, "$") do
                           String.replace(pattern, ~r/\$$/, ".#{ext}$")
                         else
                          "#{pattern}.*\.#{ext}$"
                         end

               pattern = if String.starts_with?(pattern, "^") do
                           String.replace(pattern, ~r/\^/, "/")
                         else
                           pattern
                         end

               find_first(path, pattern)
             end)
             |> Stream.filter(fn result -> result != nil end)
             |> Stream.take(1)
             |> Enum.into([])
             |> List.first()

    if result == nil do
      find_first(path, pattern)
    else
      result
    end
  end

  def find(files, regex) do
    Enum.find(files, fn file -> Regex.match?(regex, file) end)
  end

  def find_recursive(path, regex) do
    {dirs, files} = look(path)
    pid = self()
    case find(files, regex) do
      nil ->
        pids = Enum.map(dirs, fn dir ->
                 spawn(fn ->
                   Process.flag(:trap_exit, true)
                   case find_recursive(dir, regex) do
                     :shutdown ->
                       nil
                     result ->
                       send(pid, {:file_search_result, result})
                   end
                 end)
               end)

        await_result(pids, length(pids))
      some ->
        some
    end
  end

  defp await_result(_, 0) do
    nil
  end

  defp await_result(pids, task_count) do
    receive do
      {:file_search_result, nil} ->
        await_result(pids, task_count - 1)
      {:file_search_result, result} ->
        Enum.each(pids, fn pid -> Process.exit(pid, :normal) end)
        result
      {:EXIT, _, :normal} ->
        Enum.each(pids, fn pid -> Process.exit(pid, :normal) end)
        :shutdown
      _ ->
        await_result(pids, task_count)
    end
  end

end
