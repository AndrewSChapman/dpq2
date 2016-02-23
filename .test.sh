#!/bin/bash
set -ev

dub test

dub run dpq2:integration_tests --build=unittest-cov -- --conninfo="${1}"

if [ "$DC" == "dmd" ]; then dub run dscanner -- -s; fi
#if [ "$DC" == "dmd" ]; then dub run dscanner -- -S; fi #disabled due to assertion failure in dsymbol

if [ "$DC" == "dmd" ]; then dub run dpq2:example --build=release -- --conninfo="${1}"; fi