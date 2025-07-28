defmodule SubjectManagerWeb.SubjectLive.Show do
  use SubjectManagerWeb, :live_view
  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(%{"id" => id}, _session, socket) do
    IO.inspect(socket.endpoint, label: "HERE___")
    socket =
      socket
      |> assign(page_title: "Subject")
      |> assign(subject: Subjects.get_by_id(id))

    {:ok, socket}
  end

end
