
Manual: language
================


What is it?
-----------

*uit-thesis* embeds a language package called **babel**. It allows to alter the typesetting and typography of the document
based on different language preferences. Many of the default typography behaviour within LaTeX were designed for *USenglish* taste.

The default UiT frontpage contains two logos naming the university - these come in three variants: English, Norwegian and Sami.
If any of these three languages are used, the appropriate logos will also be used on the frontpage, given that the default frontpage is
used. The default language is English, meaning if any other language is provided to **babel** for appropriate typography, 
the frontpage will use English logos.

It has language definitions for all aspects of a document, which is automatically resolved upon use. 
For example, the yellow marked name in the following figure is defined by
the selected language. In this case, the selected language is *USenglish*.

![figure example image](images/language/language-figure.png?raw=true)



How to use it
-------------

Supply the desired language as a classoption to the document class. Consult the **babel** documentation for your language of choice.
The specific languages supported by *uit-thesis* are:

+ **USenglish** *(default)*
+ **norsk**
+ **samin**

Each class option is only recognized once. The last, first-occurrence, option in this comma separated list of options will be the 
selected language. In the following example, *samin* will be the selected language.

```
\documentclass[
    norsk,
	USenglish,
	samin,
	]{uit-thesis}

\begin{document}

  ...

\end{document}
```


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
+ **equation**
+ **FancyVerbLine**
+ **figure**
+ **footnote**
+ **item**
+ **lstlisting**
+ **paragraph**
+ **section**
+ **subsection**
+ **subparagraph**
+ **page**
+ **table**

#### Example

```
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


| defname             | USenglish        | norsk          | samin                 |
| ------------------- | :--------------- | :------------- | :-------------------- |
| abstract            | Abstract         | Sammendrag     | *undefined/unknown*   |
| ack                 | Acknowledgements | Takksigelser   | *undefined/unknown*   |
| bib                 | Bibliography     | Biliografi     | *undefined/unknown*   |
| figure              | Figure           | Figur          | *undefined/unknown*   |
| lstlisting          | Listing          | Listing        | *undefined/unknown*   |
| page                | Page             | Side           | *undefined/unknown*   |
| table               | Table            | Tabell         | *undefined/unknown*   |
