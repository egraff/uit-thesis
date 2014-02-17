\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{uit-thesis}[2014/16/02 v0.1a UiT thesis class]

%:-------------------------- Basic class options -----------------------

% We're based on the standard 'book' class
\def\baseclass{book}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\baseclass}}

\def\@checkoptions#1#2{
  \edef\@curroptions{\@ptionlist{\@currname.\@currext}}
  \@tempswafalse
  \@tfor\@this:=#2\do{
    \@expandtwoargs\in@{,\@this,}{,\@curroptions,}
    \ifin@ \@tempswatrue \@break@tfor \fi}
  \let\@this\@empty
  \if@tempswa \else \PassOptionsToClass{#1}{\baseclass}\fi
}

\@checkoptions{11pt}{{10pt}{11pt}{12pt}}

% Option overrides
\PassOptionsToClass{a4paper}{\baseclass}
\PassOptionsToClass{twoside}{\baseclass}

% DVI of PDF?
\ifx\pdfoutput\undefined
  \PassOptionsToClass{dvips}{\baseclass}
\else
  \PassOptionsToClass{pdftex}{\baseclass}
\fi

% Now, process!
\ProcessOptions\relax
\LoadClass{\baseclass}

% Fix compatibility issues. A4 dimensions hard coded.
\special{papersize=210mm,297mm}

%:-------------------------- Require packages -----------------------

% Allow UTF-8 characters in .tex source files (e.g. so we don't have to escape Norwegian characters)
\RequirePackage[utf8]{inputenc}

% Correct font encoding / language support in output (hyphenations, etc.)
\RequirePackage[T1]{fontenc}

% Support text copy and text search in LaTex pdf documents with ligatures (e.g. ff, fi, ...)
\RequirePackage[resetfonts]{cmap}

% American patterns
\RequirePackage[english=usenglishmax]{hyphsubst}
\RequirePackage[USenglish]{babel}

% To modify the heading styles more thoroughly use the titlesec package
\RequirePackage{titlesec}
\RequirePackage{sectsty}

% Scalable Computer Modern font support
\RequirePackage{lmodern}
\RequirePackage{type1cm}

% Begin paragraphs with an empty line rather than an indent
\RequirePackage[parfill]{parskip}

% Support for subscript and superscript using \textsuperscript{} and \textsubscript{}
\RequirePackage{fixltx2e}

%:-------------------------- LaTeX control flow macros -----------------------

% Used to provide if-then-else macros
\usepackage{ifthen}

% Used to provide \ifpdf macro
\usepackage{ifpdf}

%:-------------------------- Colors -----------------------

% Text coloring with support for 68 standard color names
\usepackage[usenames,dvipsnames]{color}

% Table colors
\usepackage[table]{xcolor}

% Text highlighting
\usepackage{soul}

%% UiT colors (from http://uit.no/ansatte/grafiskprofil/artikkel?p_document_id=150304)
\definecolor{pms7707}{cmyk}{0.96,0,0.06,0.42}
\definecolor{pms633}{cmyk}{0.99,0.03,0.16,0.19}
\definecolor{pms2229}{cmyk}{0.98,0,0.29,0}
\definecolor{pms2227}{cmyk}{0.60,0,0.20,0}
\definecolor{pms1797}{cmyk}{0.01,0.87,0.89,0.04}
\definecolor{pms138}{cmyk}{0.02,0.39,0.96,0.07}
\definecolor{pms130}{cmyk}{0,0.31,0.90,0}

% Support-color
\definecolor{pms5435}{cmyk}{0.32,0.09,0.08,0.07}

\colorlet{chapnumcol}{pms633}

%:-------------------------- URLs -----------------------

% Nicely formatted URLs
\usepackage[obeyspaces]{url}

% Define a new 'leo' style for the package that will use a smaller font.
\def\url@leostyle{%
  \@ifundefined{selectfont}{\def\UrlFont{\sf}}{\def\UrlFont{\small\ttfamily}}%
}
% Now actually use the newly defined style.
\urlstyle{leo}

%:-------------------------- Figures, graphics, includes, etc.  -----------------------

\ifpdf
  
  \usepackage[ pdftex, plainpages = false, pdfpagelabels, 
               pdfpagelayout = useoutlines,
               bookmarks,
               bookmarksopen = true,
               bookmarksnumbered = true,
               breaklinks = true,
               linktocpage,
               pagebackref,
               colorlinks = false,  % was true
               linkcolor = blue,
               urlcolor  = blue,
               citecolor = red,
               anchorcolor = green,
               hyperindex = true,
               hyperfigures
               ]{hyperref}
  
  % Used for adding figures in thesis
  \usepackage[pdftex]{graphicx}
  
  % Make it easy to include PDFs using \includepdf macro. Note that PDF links will be lost when including!
  \usepackage{pdfpages}
  
\else
  
  \usepackage[ dvips, 
               bookmarks,
               bookmarksopen = true,
               bookmarksnumbered = true,
               breaklinks = true,
               linktocpage,
               pagebackref,
               colorlinks = false,  % was true
               linkcolor = blue,
               urlcolor  = blue,
               citecolor = red,
               anchorcolor = green,
               hyperindex = true,
               hyperfigures
               ]{hyperref}

  % Used for adding figures in thesis
  \usepackage{graphicx}
  
\fi

\usepackage[all]{hypcap} % Correct a problem with hyperref
\hypersetup{
    bookmarksnumbered,
    pdfstartview={FitH},
    colorlinks=false,%
    citecolor=black,%
    filecolor=black,%
    linkcolor=black,%
    urlcolor=black,%
    pdfpagemode={UseOutlines}
}

% Enables adding figures and tables side by side
\usepackage{subfigure}

%:-------------------------- Things we need to do magic -----------------------

% For sweet-ass drawings and transformations and shit
\usepackage{tikz}

% Needed by our black magic hacks below
\usepackage{l3regex}
\usepackage{xparse}

%:-------------------------- Fonts -----------------------

\usepackage{opensans}
\usepackage[osf]{XCharter}

%:-------------------------- Symbols -----------------------

% AMS
\usepackage{amsfonts, amsmath, amssymb, amsthm, amscd, xspace}

\usepackage{mathtools}
\usepackage{wasysym} % Math symbols
\usepackage{ifsym}
\usepackage{bm}

%:-------------------------- Page layout -----------------------

% Used to modify layout
\usepackage{layout}

%A4 settings
\ifpdf
   \pdfpageheight=297mm
   \pdfpagewidth=210mm
\else
   \setlength{\paperheight}{297mm}
   \setlength{\paperwidth}{210mm}
\fi

% WTF?
\setlength{\hoffset}{0.00cm}
\setlength{\voffset}{0.00cm}

%:-------------------------- Header/footer -----------------------

% Used to modify header/footer of pages
\usepackage{fancyhdr}

% Macro to create empty page so that chapters always start on even page number
% Note that we use pagestyle "empty" to let the blank pages be blank folios (no page numbers)
% It can be changed to "plain" if page number is desired on blank pages
\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
    \hbox{}
    \thispagestyle{empty}
    \newpage
    \if@twocolumn\hbox{}\newpage\fi\fi\fi%
}
\clearpage{\pagestyle{empty}\cleardoublepage}

% Define pagestyle
\pagestyle{fancy}

% Reset all header settings
\fancyhf{}

% Set pagenumber in the header.
% RO = Right Odd: Page number is set to the right in the header on odd pages
% LE = Left Even: Page number is set to the left in the header on even pages
\fancyhead[RO,LE]{\thepage}

% Set \leftmark to show to the right in header on even pages. Only upper case on first letter of chapter name
\fancyhead[RE]{\nouppercase{\leftmark}}

% Redefine what is in \sectionmark so that \rightmark contains section number and section name (e.g. "2.1 My Sections Name")
\renewcommand{\sectionmark}[1]{\markright{\thesection\ #1}{}}

%:-------------------------- Black magic hacks -----------------------

% I haven't deleted the below in case someone needs it later. The charter
% extention, XCharter, provides emphasized smallcaps, however, so it is
% superfluous here. - EIN
% Used together with small caps to achieve fake emphasized (actually slanted) small caps
%\newcommand{\faketextsl}[1]{%
%   \tikz[baseline=(N.base)]%
%   % The transform says:
%   % x' = 1x + 0.22y + 0pt
%   % y' = 0x + 1y    + 0pt
%   % This gives a slant - adjust the value for each font!
%   \pgfsys@transformcm{1}{0}{0.18}{1}{0pt}{0pt}% This is adjusted to look good with Charter BT
%   \node[inner sep=0pt] (N) {#1};%
%}

% Magic to define \upsc{} command that replaces upper-case letters with lower-case small-caps
\ExplSyntaxOn
\cs_generate_variant:Nn \tl_rescan:nn { nV } 
\NewDocumentCommand \upsc { m }
  {
    \tl_set:Nx \l_tmpa_tl {#1}
    \regex_replace_all:nnN { ([A-Z]+) }
      { \c{textsc} \cB\{ \c{lowercase} \cB\{ \1 \cE\} \cE\} } \l_tmpa_tl
    \tl_use:N \l_tmpa_tl
  }
\ExplSyntaxOff

%:-------------------------- Glossaries -----------------------

% Used for abreviations and list of abreviations
% Don't use 'toc' option because it doesn't print '\acronymname' in table of contents (TOC)
% Instead, we override manually later
\usepackage[acronym,shortcuts,nomain,nonumberlist]{glossaries}

% Use smallcaps-magic!!! _o/ \o/ \o_
% Must be used to support ACR-commands that are not aliased to GLS-commands
\renewcommand*{\firstacronymfont}[1]{\upsc{#1}}
\renewcommand*{\acronymfont}[1]{\upsc{#1}}

% Customize glossary abbreviations to replace upper-case letters with lower-case small-caps
\renewcommand*{\CustomAcronymFields}{%
  name={\the\glsshorttok},% name is abbreviated form (how it appears in 'List of Abbreviations')
  description={\the\glslongtok},% description is long form
}
\renewcommand*{\SetCustomDisplayStyle}[1]{%
  \defglsentryfmt[#1]{%
    \ifdefempty\glscustomtext
    {% no custom text supplied (\glsdisp not used)
      \ifglsused{\glslabel}%
      {% Subsequent use
        \glsifplural
        {% plural subsequent use
           \glscapscase
           {% no case change
             \upsc{\glsentryshortpl{\glslabel}}\glsinsert 
           }%
           {% first letter upper case
             \upsc{\Glsentryshortpl{\glslabel}}\glsinsert 
           }%
           {% all caps
             \MakeTextUppercase{\upsc{\glsentryshortpl{\glslabel}}\glsinsert}% XXX
           }%
        }%
        {% singular subsequent use
           \glscapscase
           {% no case change
             \upsc{\glsentryshort{\glslabel}}\glsinsert 
           }%
           {% first letter upper case
             \upsc{\Glsentryshort{\glslabel}}\glsinsert 
           }%
           {% all caps
             \MakeTextUppercase{\upsc{\glsentryshort{\glslabel}}\glsinsert}%  XXX
           }%
        }%
      }%
      {% First use
        \glsifplural
        {% plural first use
          \glscapscase
          {% no case change
            \glsentrylongpl{\glslabel}\glsinsert\space
               (\upsc{\glsentryshortpl{\glslabel}})%
          }%
          {% first letter upper case
            \Glsentrylongpl{\glslabel}\glsinsert\space
               (\upsc{\glsentryshortpl{\glslabel}})%
          }%
          {% All caps
            \MakeTextUppercase{%
               \glsentrylongpl{\glslabel}\glsinsert\space
               (\upsc{\glsentryshortpl{\glslabel}})}%
          }%
        }%
        {% singular first use
          \glscapscase
          {% no case change
            \glsentrylong{\glslabel}\glsinsert\space
               (\upsc{\glsentryshort{\glslabel}})%
          }%
          {% first letter upper case
            \Glsentrylong{\glslabel}\glsinsert\space
               (\upsc{\glsentryshort{\glslabel}})%
          }%
          {% All caps
            \MakeTextUppercase{%
               \glsentrylong{\glslabel}\glsinsert\space
               (\upsc{\glsentryshort{\glslabel}})}%
          }%
        }%
      }%
   }%
   {% custom text provided by \glsdisp
      \ifglsused{\glslabel}%
      {% subsequent use
        \glscustomtext
      }%
      {% first use
        \glscustomtext % When using ACR-style, e.g. \acl, \acs
      }%
   }%
  }%
}
\SetCustomStyle % Apply magic smallcaps glossaries style

%:-------------------------- Chapter and section style -----------------------

% Alias sectsty internals
\newcommand{\chapnumfont}{\SS@chapnumfont}     % use \chapternumberfont{} to change
\newcommand{\chaptitlefont}{\SS@chaptitlefont} % use \chaptertitlefont{} to change

% Use Open Sans (fos) instead of Charter BT (bch) as section title font
\allsectionsfont{\rmfamily\upshape\bfseries\usefont{OT1}{fos}{bx}{n}\selectfont}

% Change font for chapter number
\chapternumberfont{%
  \usefont{T1}{fos}{b}{n}%      % Use Open Sans as chapter number font
  \fontsize{60}{60}%            % font size 60pt, baselineskip 60pt
  \selectfont%                  % activate font
}

% Define how chapter number is drawn
\newcommand{\printchapternum}{
  \begin{tikzpicture}
    %\tikzstyle{every rectangle node}=[draw]                                               % Just for debugging, not used!
    %\draw[fill,color=black] (0,0) rectangle (2cm,2cm);                                    % Just for debugging, not used!
    \draw[fill,color=chapnumcol] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;  % Draw UiT "slash"
    \draw[color=black] (1.81,1.28) node[rectangle] { \chapnumfont\thechapter };            % Draw chapter number
  \end{tikzpicture}
}

% Now, use our supahdupah chapter style! YEEEEEEAAAAHHHHHH!
\titleformat{\chapter}[display]
  {\vspace*{8pt}\Huge\bfseries\chaptitlefont}
  {\printchapternum}
  {9pt} % Vertical distance between chapter number and chapter title
  {\Huge\bfseries\chaptitlefont}

%:-------------------------- Book class overrides -----------------------

\renewcommand\frontmatter{%
  % Froom book.cls:
    \cleardoublepage
  \@mainmatterfalse
  \pagenumbering{roman}
  
  %% Our additions:
  
  % Set \leftmark to the left on odd pages
  \fancyhead[LO]{\nouppercase{\leftmark}}
  
  % Redefine what is in \chaptermark so that \leftmark contains chapter name. Thus "Abstract" and "Acknowledgements" will be written in header
  \renewcommand{\chaptermark}[1]{\markboth{##1}{}} % Note: we use two number signs (#) because we have renewcommand within renewcommand
}

\renewcommand\mainmatter{%
  %% Froom book.cls:
    \cleardoublepage
  \@mainmattertrue
  \pagenumbering{arabic}
  
  %% Our additions:
  
  % Redefine \chaptermark, so it contains chapter number in front of chapter name (e.g. "2 My Chapers Name")
  \renewcommand{\chaptermark}[1]{\markboth{\thechapter\ ##1}{}} % Note: we use two number signs (#) because we have renewcommand within renewcommand
  
  % Set odd pages to have have \rightmark instead of \leftmark
  \fancyhead[LO]{\nouppercase{\rightmark}}
  
  % Reset glossaries
  \glsresetall
}

\renewcommand\backmatter{%
  %% Froom book.cls:
  \if@openright
    \cleardoublepage
  \else
    \clearpage
  \fi
  \@mainmatterfalse
  
  %% Our additions:
  
  % Redefine headers for appendices
  \pagestyle{empty}
}

% That's all, folks!
\endinput
