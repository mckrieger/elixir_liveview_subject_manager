defmodule SubjectManagerWeb.SubjectLive.Index do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Subjects")
      |> assign(subjects: Subjects.list_subjects())
      |> assign(form: to_form(%{}))
      |> assign(subject_to_delete: nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters.
        </div>
        <.subject :for={subject <- @subjects} subject={subject} dom_id={"subject-#{subject.id}"} live_action={@live_action}/>
      </div>
    </div>

    <.modal
      :if={@subject_to_delete}
      id="delete-modal"
      show
      on_cancel={JS.push("cancel-delete")}
    >
      <div class="p-6 space-y-4">
        <h2 class="text-xl font-semibold text-gray-900">
          Are you sure you want to delete "<%= @subject_to_delete.name %>"?
        </h2>
        <div class="flex justify-end gap-2">
          <.button phx-click="cancel-delete" class="btn">
            Cancel
          </.button>
          <.button
            phx-click="delete-subject"
            phx-value-id={@subject_to_delete.id}
            class="btn btn-danger"
          >
            Yes, Delete
          </.button>
        </div>
      </div>
    </.modal>
    """
  end

  attr(:subject, SubjectManager.Subjects.Subject, required: true)
  attr(:dom_id, :string, required: true)
  attr(:live_action, :string, required: false)

  def subject(assigns) do
    ~H"""
    <div class="subject-card-container">
    <.link navigate={~p"/subjects/#{@subject}"} id={@dom_id}>
      <div class="card">
        <img src={@subject.image_path} />
        <h2>{@subject.name}</h2>
        <div class="details">
          <div class="team">
            {@subject.team}
          </div>
          <.badge status={@subject.position} />
        </div>
      </div>
    </.link>
    <%= if @live_action == :admin do %>
      <div class="buttons mt-2 flex gap-2">
        <.link navigate={~p"/subjects/#{@subject}/edit"} class="btn">
        Edit
        </.link>
        <.button phx-click="confirm-delete", phx-value-id={@subject.id} class="btn btn-danger">
        Delete
        </.button>
      </div>
    <% end %>
    </div>
    """
  end

  attr(:form, Phoenix.HTML.Form, required: true)

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="update">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="300"/>
      <.input
        type="select"
        field={@form[:position]}
        prompt="Position"
        options={[
          Forward: "forward",
          Midfielder: "midfielder",
          Winger: "winger",
          Defender: "defender",
          Goalkeeper: "goalkeeper"
        ]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[
          Name: "name",
          Team: "team",
          Position: "position"
        ]}
      />

      <.link patch={~p"/subjects"}>
        Reset
      </.link>
    </.form>
    """
  end

  def handle_event("update",form, socket) do
    socket =
      socket
      |> assign(form: to_form(form))
      |> assign(subjects: Subjects.list_subjects(form))
    {:noreply, socket}
  end

  def handle_event("confirm-delete", %{"id" => id}, socket) do
    subject = Subjects.get_subject!(id)

    {:noreply, assign(socket, :subject_to_delete, subject)}
  end

  def handle_event("cancel-delete", _params, socket) do
  {:noreply, assign(socket, :subject_to_delete, nil)}
end

def handle_event("delete-subject", %{"id" => id}, socket) do
  {:ok, _} = Subjects.delete(id)

  socket =
    socket
    |> assign(subject_to_delete: nil)
    |> assign(subjects: Subjects.list_subjects())

  {:noreply, socket}
end
end
