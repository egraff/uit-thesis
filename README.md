uit-thesis [![Travis build status][travis-badge]][travis-url] [![AppVeyor build status][appveyor-badge]][appveyor-url]
==========

[travis-badge]: https://travis-ci.org/egraff/uit-thesis.svg?branch=master
[travis-url]: https://travis-ci.org/egraff/uit-thesis
[appveyor-badge]: https://ci.appveyor.com/api/projects/status/geocvslth4hd2xl2/branch/master?svg=true
[appveyor-url]: https://ci.appveyor.com/project/egraff/uit-thesis/branch/master

LaTeX document class for writing theses

Documentation is found at http://egraff.github.io/uit-thesis/manual/.


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

## License
The contents of this GitHub repository is licensed under the CC BY-NC-ND
license.  Among other things, this means that **you are not allowed to
redistribute any derivatives of the contents of this repository.**  This is to
prevent ending up with several different, specialized versions of the thesis
template floating around.  Instead, we want all improvements or new
functionality to be made available from one place—this repository—thus making
it easier for everyone to benefit from such changes.

Note that **we do NOT impose any restrictions on the licensing or redistribution
of your thesi**s—either in its source code form (excluding any parts of the UiT
Thesis LaTeX template) or as a compiled document (i.e. PDF file).

**We require you to add an attribution to all documents that use the UiT
Thesis LaTeX template.** By default, the template automatically adds a small
attribution notice at the bottom of the first verso page of any document using
it.  Note that although it is easy to disable this, you are not allowed to do
so, unless special permission has been granted.

Finally, although we provide this template as a form of public service, all
contributors are volunteers. We are busy people and you can't expect much by
way of tech support. We have worked hard to make this template
install and work painlessly for as many people as possible. We have continuous
integration for three different platforms. That said, we provide this template
as-is. **If you are unable to install the template or compile your document,
you are pretty much on your own.** However, if you believe you have discovered
a bug, we will be grateful if you post it as an issue to this repo. If you do
so, please provide a minimal example that reproduces your error as per 
[these guidelines](https://sqa.stackexchange.com/questions/1920/best-guidelines-for-bug-reporting).


### Does this mean that I'm not allowed to fork this repository?

No, in accordance with the GitHub Terms of Service, you are allowed to fork this repository.
You are allowed to make changes to your fork to produce pull requests against this repository (i.e. for improvements or new functionality).

However, to the extent permittable by the GitHub Terms of Service, we do not allow you to fork this repository as a means of redistributing a derivative of the UiT Thesis LaTeX template.
