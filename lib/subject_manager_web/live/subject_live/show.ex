defmodule SubjectManagerWeb.SubjectLive.Show do
  use SubjectManagerWeb, :live_view
  alias SubjectManager.Subjects

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Subject")}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    subject = %Subjects.Subject{}
    {:noreply,
    socket
    |> assign(subject: subject)
    |> assign(form: to_form(%{}))}
  end

  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    subject = Subjects.get_subject!(id)
    changeset = Subjects.change_subject(subject)
    {:noreply,
    socket
    |> assign(subject: subject)
    |> assign(form: to_form(changeset))}
  end

  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :show}} = socket) do
    subject = Subjects.get_subject!(id)
    {:noreply,
    assign(socket, subject: subject)}
  end

  def render(assigns) do
     ~H"""
     <.header>
        <%= case @live_action do %>
          <% :new -> %>New Subject
          <% :edit -> %>Edit Subject
          <% _ -> %><%= @subject.name %>
        <% end %>
        <%!-- <:actions>
          <%= if @live_action == :show do %>
            <.link patch={~p"/subjects/#{@subject.id}/edit"}>
              <.button>Edit</.button>
            </.link>
          <% end %>
        </:actions> --%>
      </.header>

    <div class="subject-show subject">
        <%= if @live_action == :show do %>
            <img
                src={@subject.image_path}
                alt="Preview Image"
                class="mx-auto w-1/2 px-8 md:w-full"
            />
        <% end %>
        <%= if @live_action in [:edit, :new] do %>
          <.form for={@form} phx-submit="save" class="space-y-4">
            <.input field={@form[:image_path]} label="Image Path" />
            <.input field={@form[:name]} label="Name" />
            <.input
              label="Position"
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
            <.input field={@form[:team]} label="Team" />
            <.input field={@form[:bio]} label="Bio" type="textarea" />
            <.button><%= if @live_action == :new, do: "Create", else: "Save" %></.button>
            <.link patch={cancel_path(@live_action, @subject)} class="btn ml-2">Cancel</.link>
          </.form>
        <% else %>
          <.list>
            <:item title="Name">{@subject.name}</:item>
            <:item title="Position"><.badge status={@subject.position} /></:item>
            <:item title="Team">{@subject.team}</:item>
            <:item title="Bio">{@subject.bio}</:item>
          </.list>
        <% end %>
        </div>


    <.back navigate={~p"/subjects"}>Back to list</.back>
    """
  end

  defp cancel_path(:new, _subject), do: ~p"/subjects"
  defp cancel_path(_, subject), do: ~p"/subjects/#{subject}"

def handle_event("save", params, socket) do
  case socket.assigns.live_action do
    :edit ->
      case Subjects.update_subject(socket.assigns.subject, params) do
        {:ok, subject} ->
          {:noreply,
           socket
           |> put_flash(:info, "Subject updated")
           |> push_patch(to: ~p"/subjects/#{subject}")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end

    :new ->
      case Subjects.create_subject(params) do
        {:ok, subject} ->
          {:noreply,
           socket
           |> put_flash(:info, "Subject created")
           |> push_patch(to: ~p"/subjects/#{subject}")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
  end
end

end
