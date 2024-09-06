defmodule SimpleCluster.Utils.FileTest do
  use ExUnit.Case

  test "get dirs tree for file" do
    base_path = "/tmp/111"
    file_name = "/tmp/111/222/333/111.txt"
    assert ["222", "333"] == SimpleCluster.Utils.File.get_dirs_tree(base_path, file_name)
    assert [] == SimpleCluster.Utils.File.get_dirs_tree(base_path, base_path)
  end

  test "create full file path with sub dirs" do
    base_dir = "/tmp/111"
    file_name = "/tmp/somedir/anotherdir/333/111.txt"
    sub_dirs = ["222", "555"]

    assert "/tmp/111/222/555/111.txt" =
             SimpleCluster.Utils.File.create_full_path(base_dir, file_name, sub_dirs)

    sub_dirs = []

    assert "/tmp/111/111.txt" =
             SimpleCluster.Utils.File.create_full_path(base_dir, file_name, sub_dirs)
  end
end
