defmodule Ptolemy.QueryParserTest do
  use ExUnit.Case, async: true

  alias Ptolemy.QueryParser

  test "empty string" do
    result = QueryParser.parse("")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [], "", _, _, _} = result
  end

  test "only whitespace" do
    result = QueryParser.parse("  \t  \n   ")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [], "", _, _, _} = result
  end

  test "full-text search single term" do
    result = QueryParser.parse("systems")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [word: "systems"], "", _, _, _} = result
  end

  test "leading whitespace" do
    result = QueryParser.parse("  systems")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [word: "systems"], "", _, _, _} = result
  end

  test "full-text search multiple terms (implicit and)" do
    result = QueryParser.parse("particular systems knowledge base")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok,
     [
       and: [
         word: "particular",
         and: [word: "systems", and: [word: "knowledge", word: "base"]]
       ]
     ], "", _, _, _} = result
  end

  test "full-text search multiple terms (explicit and)" do
    result = QueryParser.parse("particular and systems and knowledge and base")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok,
     [
       and: [
         word: "particular",
         and: [word: "systems", and: [word: "knowledge", word: "base"]]
       ]
     ], "", _, _, _} = result
  end

  test "full-text search negated term" do
    result = QueryParser.parse("not linux")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [not: {:word, "linux"}], "", _, _, _} = result
  end

  test "full-text search escaped term" do
    result = QueryParser.parse("\"or\"")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [word: "or"], "", _, _, _} = result
  end

  test "single tag shorthand" do
    result = QueryParser.parse("#programming")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [tag: "programming"], "", _, _, _} = result
  end

  test "single tag facet" do
    result = QueryParser.parse("tag:programming")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [tag: "programming"], "", _, _, _} = result
  end

  test "multiple tags" do
    result = QueryParser.parse("#transcoding #gpu #realtime")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [and: [tag: "transcoding", and: [tag: "gpu", tag: "realtime"]]], "", _, _, _} = result
  end

  test "fts and tag" do
    result = QueryParser.parse("cluster provisionning #kubernetes")
    # IO.puts("\n#{Kernel.inspect(result)}\n")
    {:ok, [and: [word: "cluster", and: [word: "provisionning", tag: "kubernetes"]]], "", _, _, _} =
      result
  end

  test "subqueries" do
    result = QueryParser.parse("(coredump #linux) or (pdb #windows)")

    {:ok, [or: [and: [word: "coredump", tag: "linux"], and: [word: "pdb", tag: "windows"]]], "",
     _, _, _} = result
  end
end
