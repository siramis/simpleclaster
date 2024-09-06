defmodule SimpleCluster.Utils.File do
  @moduledoc """
  Utils module to manage file settings and utilities.
  """

  @doc """
  Get recursive full path list of files.
  """
  def list_files(dir, ignore_path) do
    if File.dir?(dir) do
      {:ok, ignore} = get_ignore_files(dir, ignore_path)
      {:ok, %{files: list_files(dir, ignore, []), ignore: ignore}}
    else
      {:error, "#{dir} is not correct dir"}
    end
  end

  defp list_files(path, ignore, acc) do
    cond do
      File.regular?(path) ->
        if Enum.member?(ignore, path) do
          acc
        else
          [path | acc]
        end

      File.dir?(path) ->
        {:ok, items} = File.ls(path)
        browse_items(items, path, ignore, acc)
    end
  end

  defp browse_items([], _parent, _ignore, acc), do: acc

  defp browse_items([item | items], parent, ignore, acc) do
    full_path = Path.join(parent, item)
    acc = list_files(full_path, ignore, acc)
    browse_items(items, parent, ignore, acc)
  end

  def get_ignore_files(parent, ignore_path) do
    skip_file_path = Path.join(parent, ignore_path)

    case File.read(skip_file_path) do
      {:ok, contents} ->
        {:ok, contents |> String.split("\n", trim: true)}

      {:error, :enoent} ->
        File.write(skip_file_path, skip_file_path)
        get_ignore_files(parent, ignore_path)
    end
  end

  def perform_file(state, skip_file_name) do
    [file | rest] = state.files
    skip_files = state.skipped
    # Add to ignore
    skip_file_full_path = Path.join(state.src, skip_file_name)
    File.write!(skip_file_full_path, "\n#{file}", [:append])
    new_state = Map.merge(state, %{files: rest, skipped: [file | skip_files]})
    data = File.read(file)
    dirs = SimpleCluster.Utils.File.get_dirs_tree(state.src, file)
    %{state: new_state, data: data, name: file, dirs: dirs}
  end

  @doc """
  Dirs tree of the file
  """
  def get_dirs_tree(base_path, file_name) do
    file_dir =
      Path.dirname(file_name)
      |> Path.split()

    file_dir -- Path.split(base_path)
  end

  def create_full_path(base_dir, file_name, sub_dirs) do
    if length(sub_dirs) > 0 do
      sd = Path.join(sub_dirs)

      Path.join(base_dir, sd)
      |> Path.join(Path.basename(file_name))
    else
      Path.join(base_dir, Path.basename(file_name))
    end
  end
end
