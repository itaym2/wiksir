defmodule Wiksir.Entries.Cache do
  use GenServer

  @interval 2 * 60 * 1000

  def start_link do
    GenServer.start_link(__MODULE__, repo_path: "https://github.com/itaym2/docs.git")
  end

  def init(repo_path: repo_path) do
    repo = 
      case File.exists? "./entries" do
        true -> Git.new repo_path      
        _ -> Git.clone! [repo_path, "./entries"]  
      end
    
    Process.send_after(self(), :pull, @interval) # In 2 minutes
    {:ok, repo: repo}
  end

  def handle_info(:pull, repo: repo) do

    Process.send_after(self(), :work, @interval) # In 2 hours

    {:noreply, repo: repo}
  end
end