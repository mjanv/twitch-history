defmodule TwitchStory.Oban do
  @moduledoc false

  import Ecto.Query
  alias TwitchStory.Repo

  def jobs do
    Repo.all(from j in Oban.Job, group_by: j.state, select: {j.state, count(j.id)})
  end

  def pause, do: Oban.pause_all_queues()
  def resume, do: Oban.resume_all_queues()
  def cancel, do: Oban.cancel_all_jobs(Oban.Job)
  def delete, do: Repo.delete_all(Oban.Job)
end
