#!/bin/bash
set -euo pipefail

exec forgejo-runner daemon -c /runner.yaml
