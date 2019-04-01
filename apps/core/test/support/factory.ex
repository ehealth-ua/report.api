defmodule Core.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Core.Repo
  alias Core.CapitationReport
  alias Core.CapitationReportDetail
  alias Core.Replica.Declaration
  alias Core.Replica.DeclarationStatusHistory
  alias Core.Replica.MedicationRequestStatusHistory
  alias Core.Replica.Employee
  alias Core.Replica.Person
  alias Core.Replica.LegalEntity
  alias Core.Replica.RelatedLegalEntity
  alias Core.Replica.MSP
  alias Core.Replica.Division
  alias Core.Replica.DivisionAddress
  alias Core.Replica.Region
  alias Core.Replica.Party
  alias Core.Replica.PartyUser
  alias Core.Replica.MedicationRequest
  alias Core.Replica.MedicationDispense
  alias Core.Replica.MedicalProgram
  alias Core.Replica.Medication
  alias Core.Replica.MedicationDispense.Details
  alias Core.Replica.INNM
  alias Core.Replica.INNMDosageIngredient
  alias Core.Replica.Contract
  alias Core.Replica.ContractDivision
  alias Core.Replica.ContractEmployee
  alias Ecto.UUID

  def capitation_report_factory do
    %CapitationReport{
      billing_date: Map.put(Date.utc_today(), :day, 1)
    }
  end

  def capitation_report_detail_factory do
    %CapitationReportDetail{
      declaration_count: Enum.random(1..4),
      age_group: Enum.random(["0-18", "19-39", "40-60"]),
      mountain_group: Enum.random([true, false]),
      contract_id: UUID.generate(),
      legal_entity_id: UUID.generate(),
      capitation_report_id: UUID.generate()
    }
  end

  def declaration_factory do
    start_date = Date.add(Date.utc_today(), 1)
    end_date = Date.add(start_date, 365)
    signed_at = NaiveDateTime.from_erl!({Date.to_erl(start_date), {0, 0, 0}})

    %Declaration{
      declaration_request_id: UUID.generate(),
      person_id: UUID.generate(),
      legal_entity_id: UUID.generate(),
      start_date: start_date,
      end_date: end_date,
      status: "active",
      signed_at: signed_at,
      created_by: UUID.generate(),
      updated_by: UUID.generate(),
      is_active: true,
      scope: "",
      declaration_number: "1111",
      overlimit: false,
      reason_description: "some description"
    }
  end

  def declaration_status_hstr_factory do
    %DeclarationStatusHistory{}
  end

  def medication_request_status_hstr_factory do
    %MedicationRequestStatusHistory{}
  end

  def make_declaration_with_all do
    :declaration
    |> build()
    |> declaration_with_employee
    |> declaration_with_person
    |> declaration_with_legal_entity
    |> insert
  end

  defp declaration_with_employee(%Declaration{} = declaration) do
    %{declaration | employee_id: insert(:employee, legal_entity: nil).id}
  end

  defp declaration_with_person(%Declaration{} = declaration) do
    %{declaration | person_id: insert(:person).id}
  end

  defp declaration_with_legal_entity(%Declaration{} = declaration) do
    division =
      :division
      |> build()
      |> division_with_legal_entity
      |> insert()

    %{declaration | legal_entity_id: division.legal_entity_id, division_id: division.id}
  end

  defp division_with_legal_entity(%Division{} = divison) do
    %{divison | legal_entity_id: insert(:legal_entity).id}
  end

  def employee_factory do
    start_date = Date.add(Date.utc_today(), -2)
    end_date = Date.add(Date.utc_today(), 365)

    %Employee{
      employee_type: "DOCTOR",
      position: "some position",
      start_date: start_date,
      end_date: end_date,
      status_reason: "",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      status: "APPROVED",
      is_active: true,
      party: build(:party),
      legal_entity: build(:legal_entity),
      division: build(:division),
      additional_info: %{},
      speciality_officio: "some speciality",
      speciality_officio_valid_to_date: NaiveDateTime.utc_now()
    }
  end

  def division_factory do
    bool_list = [true, false]

    %Division{
      email: sequence(:email, &"division-#{&1}@example.com"),
      name: "foo",
      status: "ACTIVE",
      is_active: true,
      type: "CLINIC",
      addresses: [build(:division_address), build(:division_address, type: "REGISTRATION")],
      phones: [%{type: "MOBILE", number: "+380503410870"}],
      mountain_group: Enum.at(bool_list, :rand.uniform(2) - 1),
      location: %Geo.Point{
        coordinates: {50.12332, 30.12332}
      },
      legal_entity_id: nil,
      dls_id: UUID.generate(),
      dls_verified: true
    }
  end

  def division_address_factory do
    %DivisionAddress{
      zip: "02090",
      area: "ЛЬВІВСЬКА",
      type: "RESIDENCE",
      region: "ПУСТОМИТІВСЬКИЙ",
      street: "Ніжинська",
      country: "UA",
      building: "115",
      apartment: "3",
      settlement: "СОРОКИ-ЛЬВІВСЬКІ",
      street_type: "STREET",
      settlement_id: "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
      settlement_type: "CITY",
      division_id: UUID.generate()
    }
  end

  def person_factory do
    birth_date = Date.utc_today()
    year = Enum.random((birth_date.year - 60)..birth_date.year)
    birth_date = %{birth_date | year: year}

    %Person{
      birth_date: birth_date,
      addresses: [
        %{
          zip: "02090",
          area: "ЛЬВІВСЬКА",
          type: "REGISTRATION",
          region: "ПУСТОМИТІВСЬКИЙ",
          street: "Ніжинська",
          country: "UA",
          building: "15",
          apartment: "23",
          settlement: "СОРОКИ-ЛЬВІВСЬКІ",
          street_type: "STREET",
          settlement_id: "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
          settlement_type: "CITY"
        },
        %{
          zip: "02090",
          area: "ЛЬВІВСЬКА",
          type: "RESIDENCE",
          region: "ПУСТОМИТІВСЬКИЙ",
          street: "Ніжинська",
          country: "UA",
          building: "15",
          apartment: "23",
          settlement: "СОРОКИ-ЛЬВІВСЬКІ",
          street_type: "STREET",
          settlement_id: "707dbc55-cb6b-4aaa-97c1-2a1e03476100",
          settlement_type: "CITY"
        }
      ]
    }
  end

  def legal_entity_factory do
    %LegalEntity{
      edrpou: sequence(:edrpou, &"2007772#{&1}"),
      email: sequence(:email, &"legal-entity-#{&1}@example.com"),
      kveds: ["test"],
      name: "Клініка Борис",
      public_name: "some public_name",
      short_name: "some short_name",
      legal_form: "240",
      owner_property_type: "STATE",
      status: "ACTIVE",
      type: "MSP",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      created_by_mis_client_id: UUID.generate(),
      medical_service_provider: build(:msp),
      is_active: true,
      addresses: [%{}],
      phones: [],
      mis_verified: "VERIFIED",
      nhs_verified: true,
      capitation_contract_id: UUID.generate(),
      archive: %{},
      website: "some website",
      beneficiary: "some beneficiary",
      receiver_funds_code: "some code",
      nhs_reviewed: true,
      nhs_comment: "some comment",
      edr_verified: true,
      registration_country: "some country",
      registration_area: "some area",
      registration_region: "some region",
      registration_settlement: "some settlement",
      registration_settlement_type: "some settlement type",
      registration_settlement_id: UUID.generate(),
      registration_street_type: "some street type",
      registration_street: "some street",
      registration_building: "1",
      registration_zip: "12345",
      residence_country: "some country",
      residence_area: "some area",
      residence_region: "some region",
      residence_settlement: "some settlement",
      residence_settlement_type: "some settlement type",
      residence_settlement_id: UUID.generate(),
      residence_street_type: "some street type",
      residence_street: "some street",
      residence_building: "1",
      residence_zip: "12345",
      mobile_phone: "+380503410870",
      land_line_phone: "+380503410870"
    }
  end

  def related_legal_entity_factory do
    %RelatedLegalEntity{
      merged_from_id: UUID.generate(),
      merged_to_id: UUID.generate(),
      inserted_by: UUID.generate(),
      is_active: false,
      reason: "related legal entity"
    }
  end

  def msp_factory do
    %MSP{
      accreditation: %{test: "test"},
      licenses: [%{test: "test"}]
    }
  end

  def msp_with_legal_entity(%MSP{} = msp) do
    insert(:legal_entity, medical_service_provider: msp)
  end

  def region_factory do
    %Region{
      name: "ЛЬВІВСЬКА"
    }
  end

  def party_factory do
    %Party{
      first_name: "some first_name",
      last_name: "some last_name",
      second_name: "some second_name",
      declaration_limit: 2000,
      gender: "some gender",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      no_tax_id: false,
      educations_qty: 0,
      qualifications_qty: 0,
      specialities_qty: 0
    }
  end

  def party_user_factory do
    %PartyUser{party: build(:party), user_id: UUID.generate()}
  end

  def medical_program_factory do
    %MedicalProgram{
      id: UUID.generate(),
      is_active: true,
      name: "test",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate()
    }
  end

  def medication_dispense_factory do
    %MedicationDispense{
      id: UUID.generate(),
      status: "NEW",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      is_active: true,
      dispensed_at: to_string(Date.utc_today()),
      party: build(:party),
      legal_entity: build(:legal_entity),
      payment_id: UUID.generate(),
      payment_amount: 20.5,
      division: build(:division),
      medical_program: build(:medical_program),
      medication_request: build(:medication_request)
    }
  end

  def medication_request_factory do
    %MedicationRequest{
      id: UUID.generate(),
      status: "ACTIVE",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      is_active: true,
      person_id: UUID.generate(),
      employee: build(:employee),
      division: build(:division),
      medication: build(:medication),
      created_at: NaiveDateTime.utc_now(),
      started_at: NaiveDateTime.utc_now(),
      ended_at: NaiveDateTime.utc_now(),
      dispense_valid_from: Date.utc_today(),
      dispense_valid_to: Date.utc_today(),
      medication_qty: 0,
      medication_request_requests_id: UUID.generate(),
      request_number: "",
      medical_program: build(:medical_program),
      legal_entity_id: UUID.generate(),
      rejected_at: Date.utc_today(),
      rejected_by: UUID.generate(),
      intent: "order",
      category: "community",
      context: build(:medical_events_context),
      dosage_instruction: medical_events_dosage_instruction()
    }
  end

  def medication_factory do
    %Medication{
      name: "Prednisolonum Forte",
      type: "BRAND",
      form: "Pill",
      container: %{
        numerator_unit: "pill",
        numerator_value: 1,
        denumerator_unit: "pill",
        denumerator_value: 1
      },
      manufacturer: %{
        name: "ПАТ `Київський вітамінний завод`",
        country: "UA"
      },
      package_qty: 30,
      package_min_qty: 10,
      certificate: to_string(3_300_000_000 + :rand.uniform(99_999_999)),
      certificate_expired_at: ~D[2012-04-17],
      is_active: true,
      code_atc: ["C08CA0"],
      updated_by: UUID.generate(),
      inserted_by: UUID.generate()
    }
  end

  def medication_dispense_details_factory do
    %Details{
      medication_id: UUID.generate(),
      medication_qty: 5.45,
      sell_price: 6.66,
      reimbursement_amount: 4.5,
      medication_dispense_id: UUID.generate(),
      sell_amount: 5,
      discount_amount: 10
    }
  end

  def innm_factory do
    %INNM{
      name: "test",
      name_original: "test",
      inserted_by: UUID.generate(),
      updated_by: UUID.generate()
    }
  end

  def innm_dosage_ingredient_factory do
    %INNMDosageIngredient{
      dosage: %{},
      is_primary: true,
      parent_id: UUID.generate(),
      innm: build(:innm)
    }
  end

  def contract_factory do
    %Contract{
      id: UUID.generate(),
      start_date: Date.utc_today(),
      end_date: Date.utc_today(),
      status: Contract.status(:verified),
      contractor_legal_entity_id: UUID.generate(),
      contractor_owner_id: UUID.generate(),
      contractor_base: "на підставі закону про Медичне обслуговування населення",
      contractor_payment_details: %{
        bank_name: "Банк номер 1",
        MFO: "351005",
        payer_account: "32009102701026"
      },
      contractor_rmsp_amount: Enum.random(50_000..100_000),
      external_contractor_flag: true,
      external_contractors: [
        %{
          legal_entity: %{
            id: UUID.generate(),
            name: "Клініка Ноунейм"
          },
          contract: %{
            number: "1234567",
            issued_at: NaiveDateTime.utc_now(),
            expires_at: NaiveDateTime.add(NaiveDateTime.utc_now(), days_to_seconds(365), :second)
          },
          divisions: [
            %{
              id: UUID.generate(),
              name: "Бориспільське відділення Клініки Ноунейм",
              medical_service: "Послуга ПМД"
            }
          ]
        }
      ],
      nhs_legal_entity_id: UUID.generate(),
      nhs_signer_id: UUID.generate(),
      nhs_payment_method: "prepayment",
      nhs_signer_base: "на підставі наказу",
      issue_city: "Київ",
      nhs_contract_price: to_float(Enum.random(100_000..200_000)),
      contract_number: "0000-9EAX-XT7X-3115",
      contract_request_id: UUID.generate(),
      is_active: true,
      is_suspended: false,
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      type: "CAPITATION",
      medical_program_id: UUID.generate(),
      reason: "some reason",
      contractor_payment_details_mfo: "some details",
      contractor_payment_details_bank_name: "some bank name",
      contractor_payment_details_payer_account: "some account"
    }
  end

  def contract_employee_factory do
    %ContractEmployee{
      contract_id: UUID.generate(),
      employee_id: UUID.generate(),
      division_id: UUID.generate(),
      staff_units: to_float(Enum.random(100_000..200_000)),
      declaration_limit: 2000,
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      start_date: NaiveDateTime.utc_now()
    }
  end

  def contract_division_factory do
    %ContractDivision{
      contract_id: UUID.generate(),
      division_id: UUID.generate(),
      inserted_by: UUID.generate(),
      updated_by: UUID.generate()
    }
  end

  def contracts_factory do
    %Contract{
      id: UUID.generate(),
      start_date: NaiveDateTime.utc_now(),
      end_date: NaiveDateTime.utc_now(),
      status: Enum.random(["ACTIVE", "PENDING", "EXPIRED", "ANYRANDOM"]),
      contractor_legal_entity_id: UUID.generate(),
      contractor_owner_id: UUID.generate(),
      contractor_base: "на підставі закону про Медичне обслуговування населення",
      contractor_payment_details: %{a: 1},
      contractor_rmsp_amount: Enum.random(1..100),
      external_contractor_flag: Enum.random([true, false]),
      nhs_signer_id: UUID.generate(),
      nhs_signer_base: "на підставі наказу",
      nhs_legal_entity_id: UUID.generate(),
      nhs_payment_method: "prepayment",
      is_active: Enum.random([true, false]),
      is_suspended: Enum.random([true, false]),
      issue_city: "Київ",
      nhs_contract_price: Enum.random(1..9) / 10 + Enum.random(1..99),
      contract_number: "contract-number-#{Enum.random(1000..10000)}",
      contract_request_id: UUID.generate(),
      inserted_by: UUID.generate(),
      updated_by: UUID.generate(),
      status_reason: Enum.random(["BECAUSE", "ITDEPENDSONMANYREASONS", "ANYRANDOM"]),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
  end

  defp days_to_seconds(days_count), do: days_count * 24 * 60 * 60
  defp to_float(number) when is_integer(number), do: number + 0.0

  def medical_events_context_factory do
    %{
      identifier: %{
        type: %{
          coding: [
            %{
              system: "eHealth/resources",
              code: "encounter"
            }
          ]
        },
        value: UUID.generate()
      }
    }
  end

  defp medical_events_dosage_instruction do
    [
      %{
        "sequence" => 1,
        "text" =>
          "0.25mg PO every 6-12 hours as needed for menses from Jan 15-20, 2015.  Do not exceed more than 4mg per day",
        "additional_instruction" => [
          %{
            "coding" => [
              %{
                "system" => "eHealth/SNOMED/additional_dosage_instructions",
                "code" => "311504000"
              }
            ]
          }
        ],
        "patient_instruction" =>
          "0.25mg PO every 6-12 hours as needed for menses from Jan 15-20, 2015.  Do not exceed more than 4mg per day",
        "timing" => %{
          "event" => [
            "2017-04-20T19:14:13Z"
          ],
          "repeat" => %{
            "bounds_duration" => %{
              "value" => 10,
              "unit" => "days",
              "system" => "http://unitsofmeasure.org",
              "code" => "d"
            },
            "count" => 2,
            "count_max" => 4,
            "duration" => 4,
            "duration_max" => 6,
            "duration_unit" => "d",
            "frequency" => 1,
            "frequency_max" => 2,
            "period" => 4,
            "period_max" => 6,
            "period_unit" => "d",
            "day_of_week" => [
              "mon"
            ],
            "time_of_day" => [
              "2017-04-20T19:14:13Z"
            ],
            "when" => [
              "WAKE"
            ],
            "offset" => 4
          },
          "code" => %{
            "coding" => [
              %{
                "system" => "eHealth/timing_abbreviation",
                "code" => "patient"
              }
            ]
          }
        },
        "as_needed_boolean" => true,
        "site" => %{
          "coding" => [
            %{
              "system" => "eHealth/SNOMED/anatomical_structure_administration_site_codes",
              "code" => "344001"
            }
          ]
        },
        "route" => %{
          "coding" => [
            %{
              "system" => "eHealth/SNOMED/route_codes",
              "code" => "46713006"
            }
          ]
        },
        "method" => %{
          "coding" => [
            %{
              "system" => "eHealth/SNOMED/administration_methods",
              "code" => "419747000"
            }
          ]
        },
        "dose_and_rate" => %{
          "type" => %{
            "coding" => [
              %{
                "system" => "eHealth/dose_and_rate",
                "code" => "'ordered'"
              }
            ]
          },
          "dose_range" => %{
            "low" => %{
              "value" => 13,
              "comparator" => ">",
              "unit" => "mg",
              "system" => "eHealth/units",
              "code" => "mg"
            },
            "high" => %{
              "value" => 13,
              "comparator" => ">",
              "unit" => "mg",
              "system" => "eHealth/units",
              "code" => "mg"
            }
          },
          "rate_ratio" => %{
            "numerator" => %{
              "value" => 13,
              "comparator" => ">",
              "unit" => "mg",
              "system" => "eHealth/units",
              "code" => "mg"
            },
            "denominator" => %{
              "value" => 13,
              "comparator" => ">",
              "unit" => "mg",
              "system" => "eHealth/units",
              "code" => "mg"
            }
          }
        },
        "max_dose_per_period" => %{
          "numerator" => %{
            "value" => 13,
            "comparator" => ">",
            "unit" => "mg",
            "system" => "eHealth/units",
            "code" => "mg"
          },
          "denominator" => %{
            "value" => 13,
            "comparator" => ">",
            "unit" => "mg",
            "system" => "eHealth/units",
            "code" => "mg"
          }
        },
        "max_dose_per_administration" => %{
          "value" => 13,
          "unit" => "mg",
          "system" => "eHealth/units",
          "code" => "mg"
        },
        "max_dose_per_lifetime" => %{
          "value" => 13,
          "unit" => "mg",
          "system" => "eHealth/units",
          "code" => "mg"
        }
      }
    ]
  end
end
