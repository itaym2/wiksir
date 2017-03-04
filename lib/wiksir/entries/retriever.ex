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

  defp load_entries do
    files = 
      markdown_files
      |> Enum.map(fn name -> {name, read_content(name)} end)
      |> Enum.into(%{})

    Wiksir.Entries.Cache.put_entries(files)
  end

  defp markdown_files do
    File.ls!(@entries_dir)
    |> Enum.filter(&String.ends_with?(&1, ".md"))
  end

  defp read_content(file_name) do
    Path.join([@entries_dir, file_name]) |> File.read!
  end
end