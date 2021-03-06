defmodule Core.Replica.ReplicasTest do
  @moduledoc false

  use Core.DataCase, async: true
  import Core.Factory
  alias Core.Replica.Replicas

  describe "Replicas API" do
    setup do
      declarations = for _ <- 0..14, do: make_declaration_with_all()
      %{declarations: declarations}
    end

    test "list_declarations/0" do
      declarations = Replicas.list_declarations()
      assert length(declarations) == 15
    end

    test "get_oldest_declaration_date/0", %{declarations: declarations} do
      assert List.first(declarations).inserted_at == Replicas.get_oldest_declaration_date()
    end
  end
end
