uit-thesis
==========

LaTeX document class for writing theses


TODO:
 - Fix frontpage dependencies (ask Magnus)
 - Create a LaTeX "CTAN-ready" distribution package?
   - Local texmf tree?
   - Allows us to resolve e.g. pdf dependencies?
     - See http://stackoverflow.com/questions/3374174/including-graphics-in-latex-classfile
 - Fix kerning and protrusion
   - Add microtype
   - Turn off protrusion in frontmatter
   - Re-enable protrusion in mainmatter
 - Use cite.sty?
   - Supposed to automatically sort and compress citations.
   - Does newest version support hyperlinks if used with hyperref?
 - Use autoref / add macros for referencing Figure, Chapter, Section, Listing, etc.
 - Add class option for color on UiT line?
 - Add class option for font? (Vil Jan-Ove bruke CM, eller klare vi å overtale han til å bruke Charter?)
 - Fix spacing for section header, subsection header, sub-paragraph
   - Make sure that lines "line up".
   - If we are going to support both 10pt, 11pt, and 12pt, then we should make sure this is correct for all font sizes.
 - Fix TOC stuff?
   - Would it be possible to auto-detect if we need List of Figures, List of Abbreviations, etc.?
   - Re-define \tableofcontents?
   - Re-define other list macros to automagically add \cleardoublepage and TOC entry?
 - Use \AtBeginDocument{} to make class patches more stable (make sure that packages loaded in preamble do not fuck up our modifications)?
