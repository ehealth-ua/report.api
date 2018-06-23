defmodule Report.CapitationTest do
  @moduledoc false

  use Report.DataCase
  alias Report.Capitation
  alias Report.Capitation.CapitationReport
  alias Report.Capitation.CapitationReportDetail
  alias Report.Replica.Contract
  alias Report.Repo
  import Report.Factory
  import Mox

  setup :set_mox_global

  describe "run capitation" do
    test "success" do
      billing_date = Map.put(Date.utc_today(), :day, 1)

      expect(MediaStorageMock, :create_signed_url, 100, fn _, _, _, _ ->
        {:ok, %{"data" => %{"secret_url" => "http://localhost/secret_url"}}}
      end)

      expect(MediaStorageMock, :validate_signed_entity, 100, fn _, _ ->
        {:ok, %{"data" => %{"is_valid" => true}}}
      end)

      contract =
        insert(
          :contract,
          start_date: Date.add(billing_date, -1),
          end_date: Date.add(billing_date, 1),
          status: Contract.status(:verified)
        )

      billing_datetime = NaiveDateTime.from_erl!({Date.to_erl(billing_date), {0, 0, 0}})
      division = insert(:division)

      contract_employee =
        insert(
          :contract_employee,
          division_id: division.id,
          contract_id: contract.id,
          start_date: NaiveDateTime.add(billing_datetime, -1000)
        )

      for _ <- 1..2 do
        %{id: legal_entity_id} = insert(:legal_entity)

        for _ <- 1..50 do
          insert_declaration(contract_employee, legal_entity_id, billing_datetime)
        end
      end

      Capitation.run()
      :timer.sleep(1000)
      assert [%CapitationReport{id: report_id, billing_date: ^billing_date}] = Repo.all(CapitationReport)
      details = Repo.all(CapitationReportDetail)
      assert Enum.count(details) >= 2
      assert Enum.all?(details, &(Map.get(&1, :contract_id) == contract.id))
      assert Enum.all?(details, &(Map.get(&1, :capitation_report_id) == report_id))
    end
  end

  defp insert_declaration(contract_employee, legal_entity_id, billing_datetime) do
    person = insert(:person)

    declaration =
      insert(
        :declaration,
        employee_id: contract_employee.employee_id,
        division_id: contract_employee.division_id,
        legal_entity_id: legal_entity_id,
        person_id: person.id
      )

    insert(
      :declaration_status_hstr,
      declaration_id: declaration.id,
      status: "pending_verification",
      inserted_at: NaiveDateTime.add(billing_datetime, -60 * 60)
    )

    insert(
      :declaration_status_hstr,
      declaration_id: declaration.id,
      status: "active",
      inserted_at: NaiveDateTime.add(billing_datetime, -60)
    )

    insert(
      :declaration_status_hstr,
      declaration_id: declaration.id,
      status: "terminated",
      inserted_at: NaiveDateTime.add(billing_datetime, 60 * 60 * 24)
    )
  end
end