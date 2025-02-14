#!/bin/bash -e
# ----------------------------------------------------------------------------
# Check the pull command.
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


REPO=https://github.com/seeraven/gitcache.git

# Initial clone
gitcache_ok  git clone $REPO ${TMP_WORKDIR}/gitcache

# Pull updates the mirror
gitcache_ok  git -C ${TMP_WORKDIR}/gitcache pull
assert_db_field mirror-updates of $REPO is 1
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 1

# Pull with multiple -C options updates the mirror as well
gitcache_ok  git -C ${TMP_WORKDIR} -C gitcache pull
assert_db_field mirror-updates of $REPO is 2
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 2

# Pull inside the checked out repository updates the mirror as well
pushd ${TMP_WORKDIR}/gitcache
gitcache_ok  git pull
assert_db_field mirror-updates of $REPO is 3
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 3
popd

# Pull without updating the mirror due to update interval
export GITCACHE_UPDATE_INTERVAL=3600
gitcache_ok  git -C ${TMP_WORKDIR}/gitcache pull
assert_db_field mirror-updates of $REPO is 3
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 4
export GITCACHE_UPDATE_INTERVAL=0

# Pull with repository specification
gitcache_ok  git -C ${TMP_WORKDIR}/gitcache pull origin
assert_db_field mirror-updates of $REPO is 4
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 5

# Pull with repository and ref specification
gitcache_ok  git -C ${TMP_WORKDIR}/gitcache pull origin master
assert_db_field mirror-updates of $REPO is 5
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 6

# Do not update mirror if repository does not use the mirror
git -C ${TMP_WORKDIR}/gitcache remote set-url origin $REPO
gitcache_ok  git -C ${TMP_WORKDIR}/gitcache pull
assert_db_field mirror-updates of $REPO is 5
assert_db_field clones of $REPO is 1
assert_db_field updates of $REPO is 6


# -----------------------------------------------------------------------------
# EOF
# -----------------------------------------------------------------------------
