defmodule TwitchStory.Oban do
  @moduledoc false

  import Ecto.Query

  alias TwitchStory.Repo

  @doc "Returns the number of jobs by state"
  @spec jobs() :: [{atom(), integer()}]
  def jobs do
    Repo.all(from j in Oban.Job, group_by: j.state, select: {j.state, count(j.id)})
  end

  @doc "Pause all queues"
  @spec pause() :: :ok
  def pause, do: Oban.pause_all_queues()

  @doc "Resume all queues"
  @spec resume() :: :ok
  def resume, do: Oban.resume_all_queues()

  @doc "Cancel all jobs"
  @spec cancel() :: :ok
  def cancel do
    {:ok, _} = Oban.cancel_all_jobs(Oban.Job)
    :ok
  end

  @doc "Delete all jobs"
  @spec delete() :: :ok
  def delete, do: Repo.delete_all(Oban.Job)
end
