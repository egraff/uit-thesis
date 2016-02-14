uit-thesis [![Build Status](https://magnum.travis-ci.com/egraff/uit-thesis.svg?token=TSQTyShVBGYYU4qnLNR9&branch=master)](https://magnum.travis-ci.com/egraff/uit-thesis)
==========

LaTeX document class for writing theses

How to install?
--
Simply clone with
```
git clone --recursive https://github.com/egraff/uit-thesis.git
```
and then run ``make install``.

If you're running Windows, and don't have a POSIX-like environment installed, you could try to use the [Net Installer](https://github.com/egraff/uit-thesis-installer/raw/master/uit-thesis-install.exe) instead.


It won't compile!
--
Try updating your LaTeX installation. If you use MiKTeX, also try running one or several of the following commands in a *standard* command line (cmd.exe):
```
texhash
initexmf --admin -u
initexmf --admin --mkmaps
initexmf -u
initexmf --mkmaps
```
