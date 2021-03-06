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
      specialities = [
        %{
          "level" => "FIRST",
          "speciality" => "PHARMACIST2",
          "valid_to_date" => "2017-08-05",
          "attestation_date" => "2017-08-05",
          "attestation_name" => "Академія Богомольця",
          "certificate_number" => "AB/21331",
          "qualification_type" => "AWARDING",
          "speciality_officio" => false
        }
      ]

      party =
        insert(
          :party,
          qualifications: [
            %{
              type: "STAZHUVANNYA",
              speciality: "Педіатр",
              issued_date: "2017-08-05",
              institution_name: "Академія Богомольця",
              certificate_number: "2017-08-05"
            }
          ],
          specialities: specialities,
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

      conn = get(conn, employee_path(conn, :index))
      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])

      schema =
        "test/data/stats/employee_stats_response.json"
        |> File.read!()
        |> Jason.decode!()

      :ok = NExJsonSchema.Validator.validate(schema, resp)

      assert [
               %{
                 "division" => %{
                   "id" => employee.division.id,
                   "name" => employee.division.name,
                   "addresses" => %{
                     "apartment" => "3",
                     "area" => "ЛЬВІВСЬКА",
                     "building" => "115",
                     "country" => "UA",
                     "region" => "ПУСТОМИТІВСЬКИЙ",
                     "settlement" => "СОРОКИ-ЛЬВІВСЬКІ",
                     "settlement_id" => "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
                     "settlement_type" => "CITY",
                     "street" => "Ніжинська",
                     "street_type" => "STREET",
                     "type" => "RESIDENCE",
                     "zip" => "02090"
                   }
                 },
                 "id" => employee.id,
                 "legal_entity" => %{
                   "id" => employee.legal_entity.id,
                   "name" => employee.legal_entity.name
                 },
                 "party" => %{
                   "first_name" => "some first_name",
                   "id" => party.id,
                   "last_name" => "some last_name",
                   "second_name" => "some second_name",
                   "specialities" => [
                     Map.put(employee.speciality |> Jason.encode!() |> Jason.decode!(), "speciality_officio", true)
                     | specialities
                   ],
                   "gender" => "some gender",
                   "no_tax_id" => false
                 }
               }
             ] == resp["data"]
    end

    test "search by division_id", %{conn: conn} do
      division = insert(:division)
      insert(:employee, division: division)

      conn = get(conn, employee_path(conn, :index), %{division_id: division.id})
      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
    end

    test "search by first_name, last_name, second_name", %{conn: conn} do
      party =
        insert(:party, first_name: "test first name", last_name: "test last name", second_name: "test second name")

      insert(:employee, party: party)

      resp =
        conn
        |> get(employee_path(conn, :index), %{full_name: "First SECOND last name"})
        |> json_response(200)

      assert 1 == Enum.count(resp["data"])

      resp =
        conn
        |> get(employee_path(conn, :index), %{full_name: "first"})
        |> json_response(200)

      assert 1 == Enum.count(resp["data"])

      resp =
        conn
        |> get(employee_path(conn, :index), %{full_name: "LAST"})
        |> json_response(200)

      assert 1 == Enum.count(resp["data"])

      resp =
        conn
        |> get(employee_path(conn, :index), %{full_name: "fir Sec lA"})
        |> json_response(200)

      assert 1 == Enum.count(resp["data"])

      resp =
        conn
        |> get(employee_path(conn, :index), %{full_name: "rst cond ast"})
        |> json_response(200)

      assert Enum.empty?(resp["data"])
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

    test "search by id", %{conn: conn} do
      employee = insert(:employee)
      insert(:employee)

      conn = get(conn, employee_path(conn, :index), %{id: employee.id})

      assert resp = json_response(conn, 200)
      assert 1 == Enum.count(resp["data"])
      assert employee.id == hd(resp["data"])["id"]
    end
  end

  describe "emplyoee show" do
    test "success get employee by id", %{conn: conn} do
      educations = [
        %{
          "city" => "Київ",
          "degree" => "MASTER",
          "country" => "UA",
          "speciality" => "Педіатр",
          "issued_date" => "2017-08-05",
          "diploma_number" => "DD123543",
          "institution_name" => "Академія Богомольця"
        }
      ]

      specialities = [
        %{
          "level" => "FIRST",
          "speciality" => "PHARMACIST2",
          "valid_to_date" => "2017-08-05",
          "attestation_date" => "2017-08-05",
          "attestation_name" => "Академія Богомольця",
          "certificate_number" => "AB/21331",
          "qualification_type" => "AWARDING",
          "speciality_officio" => false
        }
      ]

      qualifications = [
        %{
          type: "STAZHUVANNYA",
          speciality: "Педіатр",
          issued_date: "2017-08-05",
          institution_name: "Академія Богомольця",
          certificate_number: "2017-08-05"
        }
      ]

      science_degree = %{
        city: "Київ",
        degree: "DOCTOR_OF_SCIENCE",
        country: "UA",
        speciality: "THERAPIST",
        issued_date: "2017-08-05",
        diploma_number: "DD123543",
        institution_name: "Академія Богомольця"
      }

      party =
        insert(
          :party,
          educations: educations,
          qualifications: qualifications,
          specialities: specialities,
          science_degree: science_degree
        )

      legal_entity = insert(:legal_entity)
      division = insert(:division, legal_entity_id: legal_entity.id)

      employee =
        insert(
          :employee,
          party: party,
          division: division,
          speciality: Map.put(hd(specialities), "speciality_officio", true)
        )

      insert(:employee)

      conn = get(conn, employee_path(conn, :show, employee.id))
      assert resp = json_response(conn, 200)

      schema =
        "test/data/stats/employee_stats_details_response.json"
        |> File.read!()
        |> Jason.decode!()

      :ok = NExJsonSchema.Validator.validate(schema, resp)

      assert %{
               "division" => %{
                 "id" => employee.division.id,
                 "legal_entity" => %{
                   "id" => legal_entity.id,
                   "name" => legal_entity.name
                 },
                 "name" => employee.division.name,
                 "type" => "CLINIC",
                 "addresses" => %{
                   "apartment" => "3",
                   "area" => "ЛЬВІВСЬКА",
                   "building" => "115",
                   "country" => "UA",
                   "region" => "ПУСТОМИТІВСЬКИЙ",
                   "settlement" => "СОРОКИ-ЛЬВІВСЬКІ",
                   "settlement_id" => "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
                   "settlement_type" => "CITY",
                   "street" => "Ніжинська",
                   "street_type" => "STREET",
                   "type" => "RESIDENCE",
                   "zip" => "02090"
                 }
               },
               "employee_type" => "DOCTOR",
               "end_date" => to_string(employee.end_date),
               "id" => employee.id,
               "party" => %{
                 "about_myself" => nil,
                 "first_name" => employee.party.first_name,
                 "id" => employee.party.id,
                 "last_name" => employee.party.last_name,
                 "second_name" => employee.party.second_name,
                 "working_experience" => nil,
                 "educations" => educations,
                 "specialities" => [
                   Map.put(employee.speciality |> Jason.encode!() |> Jason.decode!(), "speciality_officio", true)
                 ],
                 "qualifications" => qualifications |> Jason.encode!() |> Jason.decode!(),
                 "science_degree" => science_degree |> Jason.encode!() |> Jason.decode!(),
                 "gender" => "some gender",
                 "no_tax_id" => false
               },
               "position" => employee.position,
               "legal_entity" => %{
                 "id" => employee.legal_entity.id,
                 "name" => employee.legal_entity.name
               },
               "start_date" => to_string(employee.start_date),
               "status" => "APPROVED"
             } == resp["data"]
    end
  end
end
