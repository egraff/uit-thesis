---
layout: manual
title: language
---
What is it?
-----------

The UiT thesis LaTeX template provides multilingual support through the use of
the standard LaTeX package [`babel`](https://www.ctan.org/pkg/babel).
Most of the default typography behaviour within LaTeX is adapted to conventions
for typesetting English literature.
`babel` makes it possible to alter the typesetting and typography of a document
based on different language preferences.

The default UiT front page contains two different types of logos that embed the
name of the university (UiT) as textual elements.
Different sets of logos are available for three different languages: English,
Norwegian, and (Northern) Sami.
If any of these three languages is selected as the main language for the thesis
document, the appropriate logos will automatically be displayed on the front
page, given that the default front page is used.
The default language is English, and if any other language is provided to
`babel` for appropriate typography, the front page will default to the use of
English logos.

The `babel` package contains language definitions for all aspects of a
document, which is automatically resolved upon use.
For example, the yellow marked name in the following figure is defined by the
selected language.
In this case, the selected language is *USenglish*.

![figure example image](images/language/language-figure.png?raw=true)



How to use it
-------------

Supply the desired language as a class option to the UiT thesis document class.
Consult the [`babel` documentation](http://ctan.uib.no/macros/latex/required/babel/base/babel.pdf)
for your language of choice.
The specific languages supported by *uit-thesis* are:

| Language            | Class option            |
| ------------------- | :---------------------- |
| American English    | `USenglish` (default)   |
| Norwegian           | `norsk`                 |
| Northern Sami       | `samin`                 |

Each class option is only recognized once.
The last, first-occurrence option in this comma-separated list of options will
be the selected language.
In the following example, Northern Sami will be the selected language.

```latex
\documentclass[
    norsk,
    USenglish,
    samin,
    ]{uit-thesis}

\begin{document}

  ...

\end{document}
```

As shown in the example above, it is possible to supply multiple languages as
class options to the UiT thesis document class.
The benefit of doing so, is that `babel` allows you to change the active
language anywhere in the document, from the preloaded languages that was
supplied as class options.
The easiest way to do this is to use `babel`'s `\selectlanguage` macro, which
takes the language option name as parameter.

For example:

```latex
\documentclass[USenglish,norsk]{uit-thesis}
\begin{document}
``Figure'' in Norwegian is ``\figurename''.

\selectlanguage{USenglish}

«Figur» på engelsk er «\figurename».

\end{document}
```

produces the following

![example of switching languages](images/language/select-language.png?raw=true)

### Definition names

Each language defines the name used to reference each element. For instance, the **Figure** text in the example above is defined
to be the text used when referencing a figure element in the document. One may override the default text of each language with
the following macro:

> \renamedefname[**LANGUAGE**]{**DEFNAME**}{**TEXTNAME**}

Note that the bracketed **LANGUAGE** parameter is optional, and will default to the language supplied to **babel**.

The following list of **DEFNAME**s contain the most common ones:

+ **abstract** - The abstract header.
+ **ack** - the acknowledgements header.
+ **bib** - The bibliography header.
+ **contents** - The table of contents header.
+ **chapter**
+ **figure**
+ **lstlisting**
+ **page**
+ **table**

#### Example

```latex
\documentclass{uit-thesis}

\renamedefname{figure}{MyFancyFigure}

\begin{document}

...

\end{document}
```

results in the following figure name

![renamed figure example image](images/language/language-figure-renamed.png?raw=true)


Details
-------

Each **defname** is stored in a macro with the **defname** itself appended with `name`, e.g., the table of contents **defame** `contents`
is stored in the macro `\contentsname`.

The following common **defname** definitions are employed for the default supported languages:


| defname             | USenglish              | norsk          | samin                 |
| ------------------- | :----------------------| :------------- | :-------------------- |
| abstract            | Abstract               | Sammendrag     | Čoahkkáigeassu        |
| acronym             | List of Abbreviations  | Forkortelser   | Oanádusat             |
| appendix            | Appendix               | Tillegg        | Čuovus                |
| ack                 | Acknowledgements       | Takksigelser   | Giitosat              |
| bib                 | Bibliography           | Biliografi     | Girjjálašvuohta       |
| chapter             | Chapter                | Kapittel       | Kapihttal             |
| contents            | Contents               | Innhold        | Sisdoallu             |
| figure              | Figure                 | Figur          | Govus                 |
| glossary            | Glossary               | Ordliste       | Sátnelistu            |
| index               | Index                  | Register       | Registtar             |
| listfigure          | List of Figures        | Figurer        | Govvosat              |
| listtable           | List of Tables         | Tabeller       | Tabeallat             |
| lstlisting          | Listing                | Listing        | *undefined/unknown*   |
| lstlistlisting      | List of Listings       | Listinger      | *undefined/unknown*   |
| page                | Page                   | Side           | Siidu                 |
| part                | Part                   | Del            | Oassi                 |
| preface             | Preface                | Forord         | Ovdasátni             |
| proof               | Proof                  | Bevis          | Duođaštus             |
| ref                 | References             | Referanser     | Čujuhusat             |
| see                 | see                    | se             | geahča                |
| table               | Table                  | Tabell         | Tabealla              |
