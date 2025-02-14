# ----------------------------------------------------------------------------
# Helper functions for the functional tests.
#
# Copyright (c) 2020 by Clemens Rabe <clemens.rabe@clemensrabe.de>
# All rights reserved.
# This file is part of gitcache (https://github.com/seeraven/gitcache)
# and is released under the "BSD 3-Clause License". Please see the LICENSE file
# that is included as part of this package.
# ----------------------------------------------------------------------------

# Usage: run_gitcache <expected return code> <cmd> <args>
function run_gitcache()
{
    echo "---------------------------------------------------------------------"
    echo "INFO: Function run_gitcache called with arguments $@"

    STDOUT_FILE=$(mktemp)
    STDERR_FILE=$(mktemp)

    EXPECTED_RETVAL=$1
    shift

    set +e
    echo "INFO: Executing command: $GITCACHE_BIN $@"
    $GITCACHE_BIN "$@" > $STDOUT_FILE 2> $STDERR_FILE
    RETVAL=$?
    set -e

    if [ $RETVAL != $EXPECTED_RETVAL ]; then
        echo "ERROR: Command gitcache $@ gave unexpected return value $RETVAL (expected ${EXPECTED_RETVAL})"
        RETVAL=10
    else
        echo "INFO:  Command return code: $RETVAL (as expected)"
        RETVAL=0
    fi
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo "Stdout:"
    cat ${STDOUT_FILE}
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo "Stderr:"
    cat ${STDERR_FILE}
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

    rm -f $STDOUT_FILE $STDERR_FILE
    echo "---------------------------------------------------------------------"

    return $RETVAL
}

# Usage: gitcache_ok <cmd> <args>
function gitcache_ok()
{
    run_gitcache 0 "$@"
}

# Usage: gitcache_error <cmd> <args>
function gitcache_error()
{
    run_gitcache 1 "$@"
}

# Usage: capture_output <expected retval> <name> <args>
function capture_output()
{
    echo "---------------------------------------------------------------------"
    echo "INFO: Function capture_output called with arguments $@"

    STDOUT_FILE=$(mktemp)
    STDERR_FILE=$(mktemp)

    EXPECTED_RETVAL=$1
    shift

    EXPECTED_STDOUT_FILE=${EXPECTED_OUTPUT_DIR}/${EXPECTED_OUTPUT_PREFIX}_$1_stdout.txt
    EXPECTED_STDERR_FILE=${EXPECTED_OUTPUT_DIR}/${EXPECTED_OUTPUT_PREFIX}_$1_stderr.txt
    shift

    set +e
    echo "INFO: Executing command: $GITCACHE_BIN $@"
    $GITCACHE_BIN "$@" > $STDOUT_FILE 2> $STDERR_FILE
    RETVAL=$?
    echo "INFO: Command return code: $RETVAL (expected ${EXPECTED_RETVAL})"
    set -e

    if [ $RETVAL != $EXPECTED_RETVAL ]; then
        echo "ERROR: Command gitcache $@ gave unexpected return value $RETVAL (expected ${EXPECTED_RETVAL})"
        RETVAL=10
    else
        RETVAL=0
    fi

    # Replace substitutions of the variables
    sed -i "s#${GITCACHE_DIR}#GITCACHE_DIR#g" $STDOUT_FILE $STDERR_FILE
    sed -i "s#${TMP_WORKDIR}#TMP_WORKDIR#g"   $STDOUT_FILE $STDERR_FILE
    sed -i 's# [0-9][0-9.]* seconds# TIME#g'  $STDOUT_FILE $STDERR_FILE
    sed -i '/^remote: .*$/d'                  $STDOUT_FILE $STDERR_FILE
    sed -i '/^Receiving objects: .*$/d'       $STDOUT_FILE $STDERR_FILE
    sed -i '/^Resolving deltas: .*$/d'        $STDOUT_FILE $STDERR_FILE
    sed -i '/^Unpacking objects: .*$/d'       $STDOUT_FILE $STDERR_FILE
    sed -i '/^Checking connectivity..*$/d'    $STDOUT_FILE $STDERR_FILE
    sed -i '/^Coverage.py warning.*$/d'       $STDOUT_FILE $STDERR_FILE
    sed -i '/Git LFS: .[0-9]* of .*/d'        $STDOUT_FILE $STDERR_FILE
    sed -i '/Downloading LFS objects: .*/d'   $STDOUT_FILE $STDERR_FILE

    # Support for different git versions...
    sed -i 's#fetch: Fetching reference refs/heads/#Fetching #g'  $STDOUT_FILE $STDERR_FILE
    sed -i 's#fetch: Fetching reference refs/tags/#Fetching #g'   $STDOUT_FILE $STDERR_FILE
    sed -i 's#git version [0-9.]*#git version VERSION#g'          $STDOUT_FILE $STDERR_FILE
    sed -i 's#Already up-to-date.#Already up to date.#g'          $STDOUT_FILE $STDERR_FILE
    sed -i 's#Note: switching to #Note: checking out #g'          $STDOUT_FILE $STDERR_FILE
    sed -i "s#fatal: could not read Username for 'https://github.com': No such device or address#fatal: repository 'https://github.com/seeraven/nonexistant/' not found#g"          $STDOUT_FILE $STDERR_FILE
    sed -i 's#state without impacting any branches by switching back to a branch.#state without impacting any branches by performing another checkout.#g'          $STDOUT_FILE $STDERR_FILE
    sed -i 's#do so (now or later) by using -c with the switch command. Example:#do so (now or later) by using -b with the checkout command again. Example:#g'     $STDOUT_FILE $STDERR_FILE
    sed -i 's#git switch -c <new-branch-name>#git checkout -b <new-branch-name>#g' $STDOUT_FILE $STDERR_FILE
    sed -i '/advice.detachedHead to false/{n;d}'                  $STDOUT_FILE $STDERR_FILE
    sed -i '/^Or undo this operation with:/,/to false/d'          $STDOUT_FILE $STDERR_FILE

    if [ "$SAVE_REFERENCE" == "1" ]; then
        cp $STDOUT_FILE $EXPECTED_STDOUT_FILE
        cp $STDERR_FILE $EXPECTED_STDERR_FILE
        echo "INFO: Saved reference"
    else
        if ! cmp -s $STDOUT_FILE $EXPECTED_STDOUT_FILE; then
            echo "ERROR: Command gitcache $@ gave unexpected stdout output:"
            cat $STDOUT_FILE
            echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            if [ -e $EXPECTED_STDOUT_FILE ]; then
                echo "Stdout diff:"
                diff $STDOUT_FILE $EXPECTED_STDOUT_FILE
                echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            fi
            RETVAL=10
        else
            echo "INFO: Stdout output as expected in $EXPECTED_STDOUT_FILE"
        fi
        if ! cmp -s $STDERR_FILE $EXPECTED_STDERR_FILE; then
            echo "ERROR: Command gitcache $@ gave unexpected sterr output:"
            cat $STDERR_FILE
            echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            if [ -e $EXPECTED_STDERR_FILE ]; then
                echo "Stderr diff:"
                diff $STDERR_FILE $EXPECTED_STDERR_FILE
                echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            fi
            RETVAL=10
        else
            echo "INFO: Stderr output as expected in $EXPECTED_STDERR_FILE"
        fi
    fi

    rm -f $STDOUT_FILE $STDERR_FILE
    echo "---------------------------------------------------------------------"

    return $RETVAL
}

# Usage: capture_output_success <name> <args>
function capture_output_success()
{
    capture_output 0 "$@"
}

# Usage: capture_output_failure <name> <args>
function capture_output_failure()
{
    capture_output 1 "$@"
}

# -----------------------------------------------------------------------------
# EOF
# -----------------------------------------------------------------------------
