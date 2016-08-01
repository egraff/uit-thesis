---
layout: manual
title: code listings
---
## What is it?
The UiT thesis LaTeX template includes the [`listings`](https://www.ctan.org/pkg/listings) package, which provides functionality for typesetting source code listings, and also implements additional macros that extend the existing functionality of the `listings` package to overcome some limitations related to the use of multiple listing environments.

For a comprehensive overview of how to use the `listings` package, please read the official [package documentation](http://mirrors.ctan.org/macros/latex/contrib/listings/listings.pdf).
Here, we give a brief overview of some of the common use cases for the `listings` package, and detail the extensions added by the UiT thesis LaTeX template.

## How to use it?

The `listings` package is already included from the class file of the UiT thesis LaTeX template, so there is no need to add `\usepackage{listings}` to your preamble.

The two most common ways to add code listings to your thesis document is to either inline the listed code directly in your LaTeX source, by wrapping it in an `lstlisting` environment, or to include the code from a stand-alone file, using the `\lstinputlisting` macro.

#### Example

The following is a complete MWE (minimal working example) demonstrating the use of the `lstlisting` environment and the `\listinputlisting` macro:
{% raw %}
```latex
\documentclass{uit-thesis}

\usepackage{filecontents}

\begin{filecontents*}{samplecode.c}
#include <stdio.h>

int main(void)
{
  printf("Hello world!\n");
  return 0;
}
\end{filecontents*}

\begin{document}
\mainmatter
\chapter{A chapter}

\begin{lstlisting}[
  caption={Implementation of a Fibonacci number generator.},
  label=code:fib,
  language=python
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    return b
\end{lstlisting}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\lstinputlisting[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Ansi]C}
]{samplecode.c}

\end{document}
```
{% endraw %}

Note that the use of the `filecontents` package above is only for the purpose of the example itself.

When compiled, the example above will produce output that looks similar to this:

![Basic example of using code listings](images/listings/basic-example.png?raw=true)

### Captions and labels

Captions and labels are specified using optional arguments to the `listings` environment and the `\listinputlisting` macro, rather than using the standard `\caption` and `\label` commands (as you would e.g. when including images using `\includegraphics`).
You may optionally specify a short caption that will be displayed in the List of Listings and is different from the long caption that is shown above the listing itself, using the syntax `caption={[⟨short⟩]⟨long⟩}`.
Note that it is typically a good idea to use a short summary of the listing as both the short caption and the first sentence of the long caption.

#### Example

The following is an MWE that demonstrates the use of the optional short caption:
{% raw %}
```latex
\documentclass{uit-thesis}
\begin{document}

\frontmatter
\tableofcontents
\listoflistings

\mainmatter

\chapter{A chapter}

\begin{lstlisting}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib,
  language=python
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    return b
\end{lstlisting}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\lstinputlisting[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Ansi]C}
]{samplecode.c}

\end{document}
```
{% endraw %}

This will make the listings look like:

![Example of listing using short caption](images/listings/caption-listing.png?raw=true)

and the List of Listings will look like:

![Example of List of Listings for a listing using short caption](images/listings/caption-lol.png?raw=true)

Note that we use the macro `\listoflistings` to output the List of Listings. This is a macro provided by the UiT thesis LaTeX template, and which can be used interchangeably with the `\lstlistoflistings` macro from the `listings` package.

### Styling and language definitions

The styling of code listings can be changed using the `\lstset` macro from the `listings` package.
This will affect the "global" style that is used by all listings by default.
It is also possible to define different styles using the `\lstdefinestyle` macro, which may then be applied separately to any listing.
Similarly, it is possible to create your own programming language definitions (optionally based on existing definitions) using the `\lstdefinelanguage` macro.
Among other things, language definitions may include both new keywords for syntax highlighting, and language-specific styling rules.

#### Example

The following is an MWE that demonstrates the use of styling using `\lstset` and `\lstdefinestyle`, and language-specific styling and syntax rules using `\lstdefinelanguage`:
{% raw %}
```latex
\documentclass{uit-thesis}

\usepackage{filecontents}

\begin{filecontents*}{samplecode.c}
#include <stdio.h>

/** A small docstring.
 */
int main(void)
{
  // This is a comment
  printf("Hello world!\n");
  return 0;
}
\end{filecontents*}

\lstset{
  xleftmargin=0pt,
  xrightmargin=0pt,
  framexleftmargin=0pt,
  framexrightmargin=0pt,
  basicstyle={\fontsize{10pt}{12pt}\ttfamily},
  columns=flexible,
  keepspaces=true,
  showstringspaces=false,
  identifierstyle=\color[rgb]{0.1,0.1,0.1},
  keywordstyle=\color{blue},
  commentstyle=\color[rgb]{0,0.3,0},
}

\lstdefinestyle{frame}
{
  framextopmargin=2pt,
  framexbottommargin=2pt,
  aboveskip=1em,
  belowskip=0em,
  frame=tb,
}

\lstdefinestyle{linenumbers}
{
  xleftmargin=20pt,
  framexleftmargin=20pt,
  numbers=left,
  numbersep=10pt,
  numberstyle={\fontsize{9pt}{11pt}\selectfont\color{gray}},
}

\lstdefinelanguage
  [Custom]{C}
  [Ansi]{C}
{
  morekeywords={},
  morekeywords=[2]{printf},
  morecomment=[s][keywordstyle3]{/**}{*/},
  keywordstyle=\color{RoyalBlue},
  directivestyle=\color{Maroon},
  stringstyle=\color{OliveGreen},
  keywordstyle=[2]{\color[rgb]{0.4,0.4,0.1}},
  keywordstyle=[3]{\bfseries\color[rgb]{0,0.3,0.2}},
}

\begin{document}
\mainmatter
\chapter{A chapter}

\begin{lstlisting}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib,
  language=python,
  style=frame,
  style=linenumbers
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    # This is a comment
    return b
\end{lstlisting}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\lstinputlisting[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Custom]C},
  style=frame
]{samplecode.c}

\end{document}
```
{% endraw %}

This will produce output that looks like this:

![Example of styling of code listings](images/listings/styling.png?raw=true)


### Customizing caption style and listing name

The [`caption`](https://www.ctan.org/pkg/caption) package, which is already included from the UiT thesis LaTeX template class file, provides the `\captionsetup` command as a convenient way to customize captions for various environments.
Applying customizations to captions used by listing environments is done simply by adding `\captionsetup[lstlisting]{⟨options⟩}` to your preamble, where `⟨options⟩` is replaced by a list of desired options from those provided by the `caption` package or one of its extensions.

The UiT thesis LaTeX template also provides the commands `\renamedefname` and `\renameautorefname` (see the manual pages for [autoref](autoref) and [language](language)), which can be used to change the definition names and autoref reference names associated with particular environments or document items.
To rename definition and reference names of listing environments, the above commands are used with `lstlisting` as definition key (first parameter).
Finally, to rename the title of the List of Listings, the `\renamedefname` command is used with `lstlistlisting` as key.

The following is an MWE demonstrating how to customize the caption style and names associated with lstlisting environments:
{% raw %}
```latex
\documentclass{uit-thesis}

\usepackage{filecontents}

\begin{filecontents*}{samplecode.c}
#include <stdio.h>

int main(void)
{
  // This is a comment
  printf("Hello world!\n");
  return 0;
}
\end{filecontents*}

\definecolor{mycolor}{rgb}{0.8,0.8,0.8}

\lstset{
  xleftmargin=20pt,
  xrightmargin=0pt,
  framexleftmargin=20pt,
  framexrightmargin=0pt,
  framexbottommargin=2pt,
  basicstyle={\fontsize{10pt}{12pt}\ttfamily},
  columns=flexible,
  keepspaces=true,
  showstringspaces=false,
  identifierstyle=\color[rgb]{0.1,0.1,0.1},
  keywordstyle=\color{blue},
  commentstyle=\color[rgb]{0,0.3,0},
  aboveskip=1em,
  belowskip=0em,
  frame=b,
  rulecolor=\color{mycolor},
  numbers=left,
  numbersep=10pt,
  numberstyle={\fontsize{9pt}{11pt}\selectfont\color{gray}},
}

\renamedefname{lstlistlisting}{List of Code Listings}
\renamedefname{lstlisting}{Code Listing}
\renameautorefname{lstlisting}{code listing}
\captionsetup[lstlisting]{
  box=colorbox,
  boxcolor={mycolor},
  skip=2pt,
  margin=4pt
}

\begin{document}

\frontmatter
\tableofcontents
\listoflistings

\mainmatter

\chapter{A chapter}

\begin{lstlisting}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib,
  language=python
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    # This is a comment
    return b
\end{lstlisting}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\lstinputlisting[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Ansi]C}
]{samplecode.c}

\end{document}
```
{% endraw %}

This will make the listings look like:

![Example of listing using custom names](images/listings/custom-name-listing.png?raw=true)

and the List of Listings will look like:

![Example of List of Listings with custom name](images/listings/custom-name-lol.png?raw=true)


### Listings as floating environments

By default, code listings follow the normal paragraphs of text, and can wrap over multiple pages (similarly to images included with `\includegraphics`).
It is also possible to use listing environments as *floating* environments.
This may be done by using the `float` option to `\lstset`, the `lstlisting` environment, or the `\listinputlisting` macro.
However, this approach does not allow for the use of advanced float placement specifiers from the `float` package.
Another possibility is therefore to define a custom new float type, and wrap it around your code listings.


The following is an MWE demonstrating how to float listing environments, by using both the built-in float support of the listings package, and a custom float:
{% raw %}
```latex
\documentclass{uit-thesis}

\usepackage{filecontents}

\begin{filecontents*}{samplecode.c}
#include <stdio.h>

int main(void)
{
  // This is a comment
  printf("Hello world!\n");
  return 0;
}
\end{filecontents*}

\lstset{
  basicstyle={\fontsize{10pt}{12pt}\ttfamily},
  columns=flexible,
  keepspaces=true,
  showstringspaces=false,
  identifierstyle=\color[rgb]{0.1,0.1,0.1},
  keywordstyle=\color{blue},
  commentstyle=\color[rgb]{0,0.3,0},
  frame=tb,
}


\floatstyle{plaintop}
\newfloat{mycode}{!tbph}{myc}

\begin{document}
\mainmatter
\chapter{A chapter}

\begin{mycode}[b]
\begin{lstlisting}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib,
  language=python
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    # This is a comment
    return b
\end{lstlisting}
\end{mycode}

\lstinputlisting[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Ansi]C},
  float=!h
]{samplecode.c}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\end{document}
```
{% endraw %}

This will produce output that looks like this:

![Example of floating code listings](images/listings/float.png?raw=true)

### Multiple listing environments

The `listings` package provides the `\lstnewenvironment` command as a way to define multiple listing environments.
However, all environments defined using this command share the same definition name, autoref reference name, and counters (which also means they will be listed in the same List of Listings).
Moreover, there is no equivalent mechanism for defining a custom version of the `\lstinputlisting` command.

The problems are demonstrated in the following example:
{% raw %}
```latex
\documentclass{uit-thesis}

\lstset{
  basicstyle={\fontsize{10pt}{12pt}\ttfamily},
  columns=flexible,
  keepspaces=true,
  showstringspaces=false,
  identifierstyle=\color[rgb]{0.1,0.1,0.1},
  keywordstyle=\color{blue},
  commentstyle=\color[rgb]{0,0.3,0},
  frame=tb,
}

\renamedefname{lstlistlisting}{List of Code Listings}
\renamedefname{lstlisting}{Code Listing}
\renameautorefname{lstlisting}{Code Listing}

\lstnewenvironment{codeenv_A}[1][]
  {%
    \lstset{#1}%
    \csname lst@SetFirstNumber\endcsname
  }
  {%
    \csname lst@SaveFirstNumber\endcsname
  }

\lstnewenvironment{codeenv_B}[1][]
  {%
    \lstset{#1}%
    \csname lst@SetFirstNumber\endcsname
  }
  {%
    \csname lst@SaveFirstNumber\endcsname
  }

\begin{document}

\frontmatter
\tableofcontents
\listoflistings

\mainmatter

\chapter{A chapter}

\begin{codeenv_A}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib,
  language=python
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    # This is a comment
    return b
\end{codeenv_A}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\begin{codeenv_B}[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello,
  language={[Ansi]C},
]
#include <stdio.h>

int main(void)
{
  // This is a comment
  printf("Hello world!\n");
  return 0;
}
\end{codeenv_B}

\end{document}
```
{% endraw %}

This will make the listings look like:

![Example of listing using multiple environments](images/listings/multiple-problem-listing.png?raw=true)

and the List of Listings will look like:

![Example of List of Listings with multiple environments](images/listings/multiple-problem-lol.png?raw=true)

To overcome these shortcomings, the UiT thesis LaTeX template provides a command `\newcustomlstenvironment` as an alternative to the `\lstnewenvironment` command. A formal definition of this command is as follows:

> \newcustomlstenvironment{⟨Environment name⟩}{⟨Aux extension⟩}{⟨Caption/autoref name⟩}
>                         [⟨number⟩][⟨opt. default arg.⟩]{⟨starting code⟩}{⟨ending code⟩}

This defines both a new environment named `⟨Environment name⟩`, as well as a command named `\lstinput⟨Environment name⟩` (the latter corresponding to `\lstinputlisting`).
The `⟨Aux extension⟩` argument specifies the file extension of the auxiliary file used to generate the List of Listings for the new listing environment, and the `⟨Caption/autoref name⟩` argument specifies its definition name and autoref reference name (these can be customized further using `\renamedefname{⟨Environment name⟩}{...}` and `\renameautorefname{⟨Environment name⟩}{...}`).
Finally, the last four arguments are the same as the corresponding arguments to (and are in fact passed directly to) the `\lstnewenvironment` command.

#### Example

The following example demonstrates the use of `\newcustomlstenvironment`:
{% raw %}
```latex
\documentclass{uit-thesis}

\usepackage{filecontents}

\begin{filecontents*}{samplecode.c}
#include <stdio.h>

int main(void)
{
  // This is a comment
  printf("Hello world!\n");
  return 0;
}
\end{filecontents*}

\lstset{
  basicstyle={\fontsize{10pt}{12pt}\ttfamily},
  columns=flexible,
  keepspaces=true,
  showstringspaces=false,
  identifierstyle=\color[rgb]{0.1,0.1,0.1},
  keywordstyle=\color{blue},
  commentstyle=\color[rgb]{0,0.3,0},
  frame=tb,
}

\definecolor{mycolor}{rgb}{0.8,0.8,0.8}

\newcustomlstenvironment{codeenvA}{locodea}{Code Snippet}[1][]
  {%
    \lstset{language=python}%
    \lstset{#1}%
    \csname lst@SetFirstNumber\endcsname
  }
  {%
    \csname lst@SaveFirstNumber\endcsname
  }

\newcustomlstenvironment{codeenvB}{locodeb}{Algorithm}[1][]
  {%
    \lstset{%
      language={[Ansi]C},
      frame=b,
      rulecolor=\color{mycolor},
    }%
    \lstset{#1}%
    \csname lst@SetFirstNumber\endcsname
  }
  {%
    \csname lst@SaveFirstNumber\endcsname
  }

\newlistof{codeenvA}{locodea}{List of Code Snippets}

\captionsetup[codeenvB]{box=colorbox,boxcolor={mycolor}}

\begin{document}

\frontmatter
\tableofcontents
\listofcodeenvA
\listof{codeenvB}{List of Algorithms}

\mainmatter

\chapter{A chapter}

\begin{codeenvA}[
  caption={%
    [Implementation of a Fibonacci number generator.]%
    Implementation of a Fibonacci number generator.
    This implementation uses the iterative approach with complexity
    $O(n)$, and is thus faster than the even simpler recursive
    variant with complexity $O\left(\phi^n\right)$.%
  },
  label=code:fib
]
def fib(n):
    a = b = 1
    for _ in range(n):
        a, b = a + b, a

    # This is a comment
    return b
\end{codeenvA}

Some dummy text referencing \autoref{code:fib} and
\autoref{code:hello}.

\lstinputcodeenvB[
  caption={C implementation of ``Hello world'' sample program.},
  label=code:hello
]{samplecode.c}

\end{document}
```
{% endraw %}

This will make the listings look like:

![Example of listing using multiple custom environments](images/listings/multiple-fixed-listing.png?raw=true)

and the list of listings for the custom environments will look like:

![Example of List of Listings with multiple custom environments](images/listings/multiple-fixed-lol-a.png?raw=true)

and

![Example of List of Listings with multiple custom environments](images/listings/multiple-fixed-lol-b.png?raw=true)

