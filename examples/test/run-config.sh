#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__proj_dir="$(cd $__dir && cd ../../ && pwd)"
__proj_name="$(basename $__proj_dir)"

export PLUGIN_SRC="${__proj_dir}"

# source the common bash script 
. "${__proj_dir}/scripts/common.sh"

# verifies dependencies and starts graphite
. "${__proj_dir}/examples/test/.setup.sh"

# downloads plugins, starts snap, load plugins and start a task
cd "${__proj_dir}/examples/test" && docker-compose exec main bash -c "PLUGIN_PATH=/etc/snap/plugins /${__proj_name}/examples/test/config.sh && printf \"\n\nhint: type 'snaptel task list'\ntype 'exit' when your done\n\n\" && bash"