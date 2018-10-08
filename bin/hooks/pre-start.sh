#!/bin/sh
# `pwd` should be /opt/report

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/report_api command Elixir.Report.ReleaseTasks migrate
fi;
