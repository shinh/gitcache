#!/bin/bash -e
# ----------------------------------------------------------------------------
# Check the settings output.
#
# Copyright (c) 2020 by Clemens Rabe <clemens.rabe@clemensrabe.de>
# All rights reserved.
# This file is part of gitcache (https://github.com/seeraven/gitcache)
# and is released under the "BSD 3-Clause License". Please see the LICENSE file
# that is included as part of this package.
# ----------------------------------------------------------------------------


EXPECTED_OUTPUT_PREFIX=$(basename $0 .sh)
source $TEST_BASE_DIR/helpers/output_helpers.sh
source $TEST_BASE_DIR/helpers/test_helpers.sh


# -----------------------------------------------------------------------------
#  Test 'gitcache' without arguments that prints the settings
# -----------------------------------------------------------------------------
capture_output_success settings
assert_gitcache_dir_exists
assert_gitcache_config_exists
assert_gitcache_db_does_not_exist


# -----------------------------------------------------------------------------
# EOF
# -----------------------------------------------------------------------------
