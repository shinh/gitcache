# -*- coding: utf-8 -*-
"""
Handler for the git clone command.

Copyright:
    2020 by Clemens Rabe <clemens.rabe@clemensrabe.de>

    All rights reserved.

    This file is part of gitcache (https://github.com/seeraven/gitcache)
    and is released under the "BSD 3-Clause License". Please see the ``LICENSE`` file
    that is included as part of this package.
"""


# -----------------------------------------------------------------------------
# Module Import
# -----------------------------------------------------------------------------
import logging

from .helpers import use_mirror_for_remote_url
from ..command_execution import simple_call_command
from ..git_mirror import GitMirror


# -----------------------------------------------------------------------------
# Logger
# -----------------------------------------------------------------------------
LOG = logging.getLogger(__name__)


# -----------------------------------------------------------------------------
# Function Definitions
# -----------------------------------------------------------------------------
def git_clone(git_options):
    """Handle a git clone command.

    Args:
        git_options (obj):     The GitOptions object.

    Return:
        Returns 0 on success, otherwise the return code of the last failed
        command.
    """
    remote_url = None
    if git_options.command_args:
        remote_url = git_options.command_args[0]

    supported_prefixes = ['http://', 'https://', 'ssh://', 'git@']
    if remote_url and any(remote_url.startswith(prefix) for prefix in supported_prefixes):
        if use_mirror_for_remote_url(remote_url):
            mirror = GitMirror(url=remote_url)
            return mirror.clone_from_mirror(git_options)

        LOG.debug("Remote URL does not match the UrlPatterns. Using original git command.")
    else:
        LOG.debug("No remote URL found. Falling back to orginal git command.")

    return simple_call_command(git_options.get_real_git_all_args())


# -----------------------------------------------------------------------------
# EOF
# -----------------------------------------------------------------------------
