Installation
============

The following installation methods are provided:

* a self-contained executable generated using PyInstaller_


Installation as the Self-Contained Executable
---------------------------------------------

Installation of the self-contained executable allows you to install
gitcache on systems even if they do not provide python themselfes.
However, the usage of gitcache is limited to the command line tool
itself, so the integration in other scripts won't be possible::

    $ wget https://github.com/seeraven/gitcache/releases/download/v1.0.8/gitcache_v1.0.8_Ubuntu18.04_amd64
    $ mv gitcache_v1.0.8_Ubuntu18.04_amd64 /usr/local/bin/gitcache
    $ chmod +x /usr/local/bin/gitcache
    $ ln -s /usr/local/bin/gitcache /usr/local/bin/git


.. _PyInstaller: http://www.pyinstaller.org/
