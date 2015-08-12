uit-thesis [![Build Status](https://magnum.travis-ci.com/egraff/uit-thesis.svg?token=TSQTyShVBGYYU4qnLNR9&branch=master)](https://magnum.travis-ci.com/egraff/uit-thesis)
==========

LaTeX document class for writing theses

How to install?
--
Simply clone and run ``make install``

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
