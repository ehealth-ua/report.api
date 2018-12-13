#!/bin/sh

if [[ "${DB_MIGRATE}" == "true" && -f "./bin/report_api" ]]; then
  echo "[WARNING] Migrating database!"
  ./bin/report_api command Elixir.Report.ReleaseTasks migrate
fi;
