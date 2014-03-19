uit-thesis
==========

LaTeX document class for writing theses


TODO:
 - Fix frontpage dependencies (ask Magnus)
 - Create a LaTeX "CTAN-ready" distribution package?
   - Local texmf tree?
   - Allows us to resolve e.g. pdf dependencies?
     - See http://stackoverflow.com/questions/3374174/including-graphics-in-latex-classfile
 - Use cite.sty?
   - Supposed to automatically sort and compress citations.
   - Does newest version support hyperlinks if used with hyperref?
 - Use autoref / add macros for referencing Figure, Chapter, Section, Listing, etc.
 - Add class option for color on UiT line?
 - Add class option for font? (Vil Jan-Ove bruke CM, eller klare vi å overtale han til å bruke Charter?)
 - Fix TOC stuff
   - Class option for list of abbreviations?
   - How to handle additional "List of..." / custom listings?
     - Override \newlistof and \newlistentry?
       - To make sure correct font is used...
     - Override \@chapter?
       - To control calls to \addtocontents and \addcontentsline.
 - Use \AtBeginDocument{} to make class patches more stable (make sure that packages loaded in preamble do not fuck up our modifications)?
