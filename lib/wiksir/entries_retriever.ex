defmodule Wiksir.Entries.Retriever do
  use GenServer
  require Logger

  @interval 2 * 5 * 1000
  @entries_dir "./entries"

  def start_link({:repo_url, repo_url}) do
    GenServer.start_link(__MODULE__, repo_url: repo_url)
  end

  def init(repo_url: repo_url) do
    repo = 
      case File.exists? @entries_dir do
        true -> Git.new @entries_dir      
        _ -> Git.clone! [repo_url, @entries_dir]  
      end
    
    load_entries

    Process.send_after(self(), :pull, @interval) # In 2 minutes
    {:ok, repo: repo}
  end

  def handle_info(:pull, repo: repo) do
    Git.pull repo
    load_entries

    Process.send_after(self(), :pull, @interval) # In 2 hours
    {:noreply, repo: repo}
  end

  defp load_entries() do
    files = File.ls!(@entries_dir)
              |> Enum.filter(&String.ends_with?(&1, ".md"))
    
    Logger.debug inspect files
      
  end

end