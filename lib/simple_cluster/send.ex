defmodule SimpleCluster.Send do
  use GenServer
  require Logger

  @skip_files ".skip_files"
  @source "/files/to/download"
  @destination "/path/to/save"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set_source(dir \\ @source) do
    [tuple | _] =
      Node.list()
      |> Enum.map(&GenServer.call({__MODULE__, &1}, {:setsource, dir}))

    state = elem(tuple, 2)
    Logger.info("src - #{state.src}\nfiles - #{length(state.files)}")
  end

  def set_destination(dir \\ @destination) do
    case GenServer.call(__MODULE__, {:setdestination, dir}) do
      :ok -> "destination dir set to #{dir}"
      error -> error
    end
    |> Logger.info()
  end

  def download(number \\ 1) do
    cond do
      number <= 0 ->
        Logger.info("Performed downloading")

      true ->
        [tuple | _] =
          Node.list()
          |> Enum.map(&GenServer.call({__MODULE__, &1}, {:download, number}, :infinity))

        result = elem(tuple, 2)

        if Map.has_key?(result, :data) do
          GenServer.call(__MODULE__, {:save, result})
          download(number - 1)
        else
          Logger.info(result.no_file)
        end
    end
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  @impl GenServer
  def handle_call({:save, result}, _from, state) do
    {:ok, data} = result.data
    path = SimpleCluster.Utils.File.create_full_path(state.dest, result.name, result.dirs)
    # create dirs tree
    File.mkdir_p(Path.dirname(path))
    # create file
    File.write!(path, data)
    Logger.info("-> #{path}")
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:setdestination, dir}, _from, state) do
    if File.dir?(dir) do
      new_state = Map.merge(state, %{dest: dir})
      {:reply, :ok, new_state}
    else
      {:reply, "#{dir} is not correct dir", state}
    end
  end

  @impl GenServer
  def handle_call({:setsource, dir}, _from, state) do
    case SimpleCluster.Utils.File.list_files(dir, @skip_files) do
      {:error, msg} ->
        {:reply, {:ok, node(), msg}, state}

      {:ok, data} ->
        new_state = Map.merge(state, %{files: data.files, src: dir, skipped: data.ignore})
        {:reply, {:ok, node(), %{files: data.files, src: dir, skipped: data.ignore}}, new_state}
    end
  end

  @impl GenServer
  def handle_call({:download, _number}, _from, state) do
    if length(state.files) < 1 do
      {:reply, {:ok, node(), %{no_file: "No more files"}}, state}
    else
      result = SimpleCluster.Utils.File.perform_file(state, @skip_files)

      data =
        if Map.has_key?(result, :data) do
          %{data: result.data, name: result.name, dirs: result.dirs}
        else
          %{no_file: "Skip files"}
        end

      {:reply, {:ok, node(), data}, result.state}
    end
  end
end
