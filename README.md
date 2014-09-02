uit-thesis
==========

LaTeX document class for writing theses


TODO:
 - Use cite.sty?
   - Supposed to automatically sort and compress citations.
   - Does newest version support hyperlinks if used with hyperref?
 - Use autoref / add macros for referencing Figure, Chapter, Section, Listing, etc.
 - Add class option for color on UiT line?
 - Use \AtBeginDocument{} to make class patches more stable (make sure that packages loaded in preamble do not fuck up our modifications)?
 - Add PhD color scheme

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
