defmodule VisionQuest.Settings do

  def load() do
    with :pong <- Node.ping(:"library@jan-VirtualBox"),
         :ok <- :global.sync()
    do
      GenServer.call({:global, Library}, {:read, "projects"})
    else
      _ ->
        {:error, :library_closed}
    end
  end

end
