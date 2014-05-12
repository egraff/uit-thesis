uit-thesis
==========

LaTeX document class for writing theses


TODO:
 - Use cite.sty?
   - Supposed to automatically sort and compress citations.
   - Does newest version support hyperlinks if used with hyperref?
 - Use autoref / add macros for referencing Figure, Chapter, Section, Listing, etc.
 - Add class option for color on UiT line?
 - Add class option for font? (Vil Jan-Ove bruke CM, eller klare vi å overtale han til å bruke Charter?)
 - Fix TOC stuff
   - Class option for list of abbreviations?
   - How to handle additional "List of..." / custom listings in ToC?
 - Use \AtBeginDocument{} to make class patches more stable (make sure that packages loaded in preamble do not fuck up our modifications)?
