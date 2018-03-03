defmodule Report.Web.EmployeeControllerTest do
  @moduledoc false

  use Report.Web.ConnCase

  describe "employees list" do
    test "no employees found", %{conn: conn} do
      conn = get(conn, employee_path(conn, :index))
      assert resp = json_response(conn, 200)
      assert [] = resp["data"]
    end

    test "success search no filters", %{conn: conn} do
      party =
        insert(
          :party,
          educations: [
            %{
              city: "Київ",
              degree: "MASTER",
              country: "UA",
              speciality: "Педіатр",
              issued_date: "2017-08-05",
              diploma_number: "DD123543",
              institution_name: "Академія Богомольця"
            }
          ],
          qualifications: [
            %{
              type: "STAZHUVANNYA",
              speciality: "Педіатр",
              issued_date: "2017-08-05",
              institution_name: "Академія Богомольця",
              certificate_number: "2017-08-05"
            }
          ],
          specialities: [
            %{
              level: "FIRST",
              speciality: "PHARMACIST2",
              valid_to_date: "2017-08-05",
              attestation_date: "2017-08-05",
              attestation_name: "Академія Богомольця",
              certificate_number: "AB/21331",
              qualification_type: "AWARDING"
            }
          ],
          science_degree: %{
            city: "Київ",
            degree: "DOCTOR_OF_SCIENCE",
            country: "UA",
            speciality: "THERAPIST",
            issued_date: "2017-08-05",
            diploma_number: "DD123543",
            institution_name: "Академія Богомольця"
          }
        )

      insert(
        :employee,
        party: party,
        speciality: %{
          level: "FIRST",
          speciality: "PEDIATRICIAN",
          valid_to_date: "2017-08-05",
          attestation_date: "2017-08-05",
          attestation_name: "Академія Богомольця",
          certificate_number: "AB/21331",
          qualification_type: "AWARDING",
          speciality_officio: true
        }
      )

      conn = get(conn, employee_path(conn, :index))
      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
      assert 2 == Enum.count(hd(resp["data"])["speciality"])
    end

    test "search by first_name, last_name, second_name", %{conn: conn} do
      party =
        insert(:party, first_name: "test first name", last_name: "test last name", second_name: "test second name")

      insert(:employee, party: party)

      conn =
        get(conn, employee_path(conn, :index), %{first_name: "First", second_name: "SECOND", last_name: "last name"})

      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
    end

    test "search by speciality", %{conn: conn} do
      party = insert(:party)
      insert(:employee, party: party)

      employee =
        insert(
          :employee,
          party: party,
          speciality: %{
            level: "FIRST",
            speciality: "PEDIATRICIAN",
            valid_to_date: "2017-08-05",
            attestation_date: "2017-08-05",
            attestation_name: "Академія Богомольця",
            certificate_number: "AB/21331",
            qualification_type: "AWARDING",
            speciality_officio: true
          }
        )

      conn = get(conn, employee_path(conn, :index), %{speciality: "PEDIATRICIAN"})
      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
      assert employee.id == hd(resp["data"])["id"]
    end

    test "search by division fields", %{conn: conn} do
      division =
        insert(
          :division,
          addresses: [
            %{
              zip: "02090",
              area: "ЧЕРКАСЬКА",
              type: "RESIDENCE",
              region: "УМАНСЬКИЙ",
              street: "вул. Ніжинська",
              country: "UA",
              building: "15",
              apartment: "23",
              settlement: "УМАНЬ",
              street_type: "STREET",
              settlement_id: "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
              settlement_type: "CITY"
            }
          ]
        )

      employee = insert(:employee, division: division)
      insert(:employee)

      conn =
        get(conn, employee_path(conn, :index), %{
          region: "УМАНСЬКИЙ",
          area: "ЧЕРКАСЬКА",
          settlement: "УМАНЬ"
        })

      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
      assert employee.id == hd(resp["data"])["id"]
    end

    test "search by division_name", %{conn: conn} do
      division = insert(:division, name: "custom name")
      employee = insert(:employee, division: division)
      insert(:employee)

      conn = get(conn, employee_path(conn, :index), %{division_name: "custom"})

      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
      assert employee.id == hd(resp["data"])["id"]
    end
  end
end
