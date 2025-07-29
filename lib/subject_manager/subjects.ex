defmodule SubjectManager.Subjects do
  import Ecto.Query
  alias SubjectManager.Subjects.Subject
  alias SubjectManager.Repo

# On lines _ and _ I've opted to use "atom when atom in []", but could alternatively use these:
#   @sortable_fields %{
#   "name" => :name,
#   "team" => :team,
#   "position" => :position
# }
# @position_types %{
#   "forward" => :forward,
#   "midfielder" => :midfielder,
#   "winger" => :winger,
#   "defender" => :defender,
#   "goalkeeper" => :goalkeeper
# }

  def list_subjects do
    Repo.all(Subject)
  end

  def list_subjects( %{
  "position" => position,
  "q" => query,
  "sort_by" => order_by
}) do
    base_query = from s in Subject

  base_query
  |> maybe_filter_name(query)
  |> maybe_filter_by_position(position)
  |> maybe_order_by(order_by)
  |> Repo.all()
  end

  defp maybe_order_by(query, ""), do: query
  defp maybe_order_by(query, nil), do: query
  defp maybe_order_by(query, field) when is_binary(field) do
    case String.to_existing_atom(field) do
      atom when atom in [:name, :team, :position] ->
        order_by(query, [u], field(u, ^atom))
      _ ->
        query
    end
  end

  defp maybe_filter_by_position(query, ""), do: query
  defp maybe_filter_by_position(query, nil), do: query
  defp maybe_filter_by_position(query, position) when is_binary(position) do
    case String.to_existing_atom(position) do
      atom when atom in [:forward, :midfielder, :winger, :defender, :goalkeeper] ->
        where(query, [u], u.position == ^atom)
      _ ->
        query
    end
  end

  defp maybe_filter_name(query, ""), do: query
  defp maybe_filter_name(query, nil), do: query
  defp maybe_filter_name(query, name) do
    where(query, [u], like(u.name, ^"%#{name}%")) # ** (Ecto.QueryError) ilike is not supported by SQLite3
  end

  def get_subject!(id) do
    Repo.get!(Subject, id)
  end

  # deleting in this manner will ensure changeset validations, callbacks, contraints are not skipped.
  def delete(id) do
    record = Repo.get(Subject, id)
    case record do
      nil ->
        {:error, :not_found}
      record ->
        case Repo.delete(record) do
          {:ok, _struct} -> {:ok, :deleted}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  def update_subject(id, attrs) do
    case Repo.get(Subject, id) do
      nil -> {:error, :not_found}
      subject ->
        subject
        |> Subject.changeset(attrs)
        |> Repo.update()
    end
  end

  def create_subject(attrs) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end


  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end
end
