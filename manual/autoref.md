
Manual: autoref
===============

What is it?
-----------

**autoref** allows to cross-reference objects named with `\label{}`, prepended with the name given to this object.

An object can be any environment within your document; chapter, section, subsection, figure, equation, table, etc.
Each object is named based upon the selected [language](language.md) supplied to **babel**, which is uniquely named for
**autoref** and does not collide with other names.

**autoref** enables cross-referencing within your LaTeX similar to the built-in `\ref`


How to use it
-------------

The API is as follows
> \autorefname{**LABEL**}
> \Autorefname{**LABEL**}

Example
```
\documentclass[norsk]{uit-thesis}

\begin{document}

\section{Eksempel seksjon}
\label{sec:example}

\autoref{sec:example}.

\Autoref{sec:example}.

\end{document}
```

which results in the following to be generated.
![autoref renamed figure](images/autoref/autoref-demonstration.png?raw=true)

Note that `\Autoref{}` capitalizes the autorefname. This is not evident in USenglish, since they are all 
capitalized by default.


Details
-------

The **autoref** name given to each object is internally known as *autorefname*, which are by default defined
in the three primarily supported languages as follows:

| autorefname         | USenglish        | norsk          | samin                 |
| ------------------- | :--------------- | :------------- | :-------------------- |
| chapter             | Chapter          | kapittel       | *undefined/unknown*   |
| equation            | Equation         | formel         | *undefined/unknown*   |
| FancyVerbLine       | Line             | Line           | *undefined/unknown*   |
| figure              | Figure           | figur          | *undefined/unknown*   |
| footnote            | Footnote         | fotnote        | *undefined/unknown*   |
| item                | Item             | element        | *undefined/unknown*   |
| lstlisting          | Listing          | listing        | *undefined/unknown*   |
| page                | Page             | side           | *undefined/unknown*   |
| paragraph           | Paragraph        | avsnitt        | *undefined/unknown*   |
| section             | Section          | seksjon        | *undefined/unknown*   |
| subsection          | Subsection       | underseksjon   | *undefined/unknown*   |
| table               | Table            | tabell         | *undefined/unknown*   |

Each of these can be renamed through the following API
> \renameautorefname[**LANGUAGE**]{**AUTOREFNAME**}{**NEWNAME**}

The language in brackets are optional, and will default to the currently selected language.

Best illustrated by an example:
```
\documentclass{uit-thesis}

%rename the section object for USenglish
\renameautorefname[USenglish]{section}{MyFancySectionName}

\begin{document}

\section{Example Section}
\label{sec:example}

A sentence referencing \autoref{sec:example}.

\end{document}
```

which results in 
![autoref renamed figure](images/autoref/autoref-rename-section.png?raw=true)

