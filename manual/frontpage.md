---
layout: manual
title: thesis front page
---
## What is it?
The UiT thesis LaTeX template has built-in support for typesetting the standardized front pages for
[master theses](https://uit.no/ansatte/grafiskprofil/artikkel?p_document_id=349513) and
[PhD dissertations](https://uit.no/ansatte/grafiskprofil/artikkel?p_document_id=350648)
as defined by UiT's current graphical profile.
The UiT logos and the default graphical patterns are included as vector graphics (unlike the Microsoft Word templates that are
available from UiT's web pages) to ensure the highest quality result both in print and when published electronically as PDF.

In addition, the UiT thesis LaTeX template allows you to customize the front page by replacing either of the graphical patterns
with your own image(s).

## How to use it?

The uit-thesis template uses the familiar ```\maketitle``` command (from the standard LaTeX book class) to typeset the front page.

The following macros are used to specify the front page text:

| Macro                     | Meaning                                   |  Required?    |
|---------------------------|-------------------------------------------|---------------|
| ```\title```              | Main title of thesis                      | Yes           |
| ```\subtitle```           | Subtitle (shown below main title)         | No, optional  |
| ```\author```             | Name of author                            | Yes           |
| ```\thesisfaculty```      | Specify faculty and/or department         | Yes           |
| ```\thesisprogramme```    | Specify type of thesis / study programme  | Yes           |

Note that the macros above must be specified *before* ```\maketitle```.
Moreover, they should be specified right after ```\begin{document}```, and before ```\frontmatter``` and ```\mainmatter```.

#### Example

```latex
\documentclass{uit-thesis}

\begin{document}

\title{Title of the master thesis}
\subtitle{Subtitle}% Note: this is optional, and may be commented out
\author{Name of author}
\thesisfaculty{Faculty of Science and Technology \\ Department of Computer Science}
\thesisprogramme{INF-3990 Master's thesis in Computer Science May 2015}

\maketitle

...

\end{document}
```

which results in the following:

![simple front page](images/frontpage/simple-example.png?raw=true)

### Custom images

The standard graphical pattern on the front page is divided by a diagonal white line into two parts: a triangle (left part) and a trapezoid (right part).
The uit-thesis template has support for replacing either both parts by a single image, or replacing either of the parts by a separate image.

The following image customization commands are available:

| Command                               | Meaning                                               |
|---------------------------------------|-------------------------------------------------------|
| ```\ThesisFrontpageImage```           | Replace both patterns by single (rectangular) image   |
| ```\ThesisLeftFrontpageImage```       | Replace left pattern (triangle) with image            |
| ```\ThesisRightFrontpageImage```      | Replace right pattern (trapezoid) with image          |

#### Example

```latex
\documentclass[phd]{uit-thesis}

\begin{document}

\title{Title}
\author{Name of author}
\thesisfaculty{Faculty of Science and Technology \\ Department of Computer Science}
\thesisprogramme{A dissertation for the degree of Philosophiae Doctor -- June 2015}

\ThesisLeftFrontpageImage{Focusing_example_image.jpg}

\maketitle

\end{document}
```

which results in the following:

![custom front page image](images/frontpage/custom-image.png?raw=true)
