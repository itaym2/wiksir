defmodule Wiksir.Entries.Retriever do
  use GenServer

  @interval 2 * 5 * 1000

  def start_link({:repo_url, repo_url}) do
    GenServer.start_link(__MODULE__, repo_url: repo_url)
  end

  def init(repo_url: repo_url) do
    repo = 
      case File.exists? "./entries" do
        true -> Git.new "./entries"      
        _ -> Git.clone! [repo_url, "./entries"]  
      end
    
    Process.send_after(self(), :pull, @interval) # In 2 minutes
    {:ok, repo: repo}
  end

  def handle_info(:pull, repo: repo) do
    Git.pull repo
    Process.send_after(self(), :pull, @interval) # In 2 hours
    {:noreply, repo: repo}
  end
end