# Simple Cluster

The project is started for training purposes in Elixir programming. It is under developing, see TODO section of planned
further features.

Sending files over network from one node to another.

### Tests running

```shell
mix test
```

### Usage

Starting node 1:

```shell
iex --name n1@127.0.0.1 --cookie my_fantastic_cookie --erl "-config sys.config" -S mix
```

Starting node 2:

```shell
iex --name n2@127.0.0.1 --cookie my_fantastic_cookie --erl "-config sys.config" -S mix
```

#### Working on node 2

Setting up source dir:

```shell
SimpleCluster.Send.set_source("/tmp/111")
```

Setting up target dir:

```shell
SimpleCluster.Send.set_destination("/tmp/222")
```

Downloading 3 files:

```shell
SimpleCluster.Send.download(3)
```

### TODO

- test coverage
- `:erlang.binary_to_term`, `:erlang.term_to_binary`
- `cast`-request
- sending files over tcp socket
- ignoring after sent