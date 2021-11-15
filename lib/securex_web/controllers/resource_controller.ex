defmodule SecureXWeb.ResourceController do
  @moduledoc false

  import Macro, only: [camelize: 1]
  use SecureXWeb, :controller
  alias SecureX.Common
  alias SecureX.SecureXContext, as: Context

  @doc """
  Get list of Resources,

  ## Examples

      iex> list_resources()
      [
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      },
      %Resource{
        id: "users",
        name: "Users"
      },
      ...
    ]
  """
  @spec list_resources() :: nonempty_list()
  def list_resources() do
    Context.list_resources()
  end

  @doc """
  Get a Resource,

  ## Examples

      iex> get(%{"res" => "person_farm"})
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      }
  """
  @spec get(map()) :: struct()
  def get(params) when params !== %{} do
    case params do
      %{res: res_id} -> get_resource_sage(res_id)
      %{"res" => res_id} -> get_resource_sage(res_id)
      _-> {:error, :bad_input}
    end
  end
  def get(_), do: {:error, :bad_input}

  defp get_resource_sage(params) do
    case Context.get_resource(params) do
      nil -> {:error, :no_role_found}
      res -> {:ok, res}
    end
  end

  @doc """
  Create a resource,

  ##example
      iex> create(%{"res" => "Person Farm"})
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      }
  """
  @spec create(map()) :: struct()
  def create(params) when params !== %{} do
    case params do
      %{res: res} -> create_res_sage(res)
      %{"res" => res} -> create_res_sage(res)
      _-> {:error, :bad_input}
    end
  end
  def create(_), do: {:error, :bad_input}

  defp create_res_sage(res) do
    with nil <- Context.get_resource_by(res),
         {:ok, res} <- create_res(res) do
      {:ok, res}
    else
      %{__struct__: _} -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp create_res(res) do
    name = res |> String.trim
    res_id = name
           |> String.downcase
           |> String.replace(" ", "_")
    Context.create_resource(%{id: res_id, name: camelize(name)})
  end

  @doc """
  Update a resource,

  ##example
      iex> update(%{"res" => "person_farm", name: "Person Organization"})
      %Resource{
        id: "person_organization",
        name: "Person Organization"
      }
  """
  @spec update(map()) :: struct()
  def update(params) when params !== %{} do
    case params do
      %{res: res_id} -> update_res_sage(res_id, params)
      %{"res" => res_id} ->
        params = Common.keys_to_atoms(params)
        update_res_sage(res_id, params)
      _-> {:error, :bad_input}
    end
  end
  def update(_), do: {:error, :bad_input}

  defp update_res_sage(res_id, params) do
    with %{__struct__: _} = prev_res <- Context.get_resource(res_id),
         {:ok, new_res} <- update_res(prev_res, params) do
      {:ok, new_res}
    else
      nil -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp update_res(prev_res, %{res: new_res}) do
    name = new_res |> String.trim
    updated_res = name
                   |> String.downcase
                   |> String.replace(" ", "_")
    if(prev_res.id !== updated_res) do
      {:ok, new_res} = Context.create_resource(%{id: updated_res, name: camelize(name)})
      case Context.get_permissions_by_res_id(prev_res.id) do
        [] -> :nothing
        permissions -> Enum.map(permissions, fn per -> Context.update_permission(per, %{resource_id: updated_res}) end)
      end
      Context.delete_resource(prev_res)
      {:ok, Map.merge(new_res, %{permissions: :successfully_updated_permissions})}
    else
      {:ok, prev_res}
    end
  end

  @doc """
  Delete a Resource,

  ## Examples

      iex> delete(%{"res" => "person_organization")
      %Resource{
        id: "person_organization",
        name: "Person Organization",
        permissions: :successfully_removed_permissions
      }
  """
  @spec delete(map()) :: struct()
  def delete(params) when params !== %{} do
    case params do
      %{res: res_id} -> delete_res_sage(res_id)
      %{"res" => res_id} -> delete_res_sage(res_id)
      _-> {:error, :bad_input}
    end
  end
  def delete(_), do: {:error, :bad_input}

  defp delete_res_sage(res_id) do
    with %{__struct__: _} = res <- Context.get_resource(res_id),
         {:ok, permission} <- remove_permissions(res),
         {:ok, res} <- delete_res(res) do
      {:ok, Map.merge(res, %{permissions: permission})}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp remove_permissions(%{id: res_id}) do
    case Context.get_permissions_by_res_id(res_id) do
      [] -> {:ok, :already_removed}
      permissions ->
        Enum.map(permissions, fn per -> Context.delete_permission(per) end)
        {:ok, :successfully_removed_permissions}
    end
  end
  defp remove_permissions(_), do: {:ok, :invalid_resource_id}

  defp delete_res(res) do
    case Context.delete_resource(res) do
      {:error, error} -> {:error, error}
      {:ok, res} -> {:ok, res}
    end
  end
end
