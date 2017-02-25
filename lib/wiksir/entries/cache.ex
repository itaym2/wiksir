defmodule Wiksir.Entries.Cache do
  def start_link do
    Agent.start_link(fn -> %{} end, [name: __MODULE__])
  end

  def put_entries(entries) when is_map(entries) do
    Agent.update(__MODULE__, fn _ -> entries end)
  end

  def get_entries do
    Agent.get(__MODULE__, fn m -> m end)
  end 
end