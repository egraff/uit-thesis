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

% Support text copy and text search in LaTex pdf documents with ligatures (e.g. ff, fi, ...)
\RequirePackage[resetfonts]{cmap}

% Correct font encoding / language support in output (hyphenations, etc.)
\RequirePackage[T1]{fontenc}

% American patterns
\RequirePackage[english=usenglishmax]{hyphsubst}
\RequirePackage[USenglish]{babel}

% To modify the heading styles more thoroughly use the titlesec package
\RequirePackage{titlesec}
\RequirePackage{sectsty}

% Scalable Computer Modern font support
\RequirePackage{lmodern}
\RequirePackage{type1cm}

% Support for subscript and superscript using \textsuperscript{} and \textsubscript{}
\RequirePackage{fixltx2e}

%:-------------------------- LaTeX control flow macros -----------------------

% Used to provide if-then-else macros
\usepackage{ifthen}

% Used to provide \ifpdf macro
\usepackage{ifpdf}

% Allow calculations in \vspace*
\usepackage{calc}

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
% Retain spaces in URLs, and allow line break at hyphens
\usepackage[obeyspaces,hyphens]{url}

% Define a new 'leo' style for the package that will use a smaller font.
\def\url@leostyle{%
  \@ifundefined{select}{\def\UrlFont{\sf}}{\def\UrlFont{\small\ttfamily}}%
}
% Now actually use the newly defined style.
\urlstyle{leo}

%:-------------------------- Figures, graphics, includes, etc.  -----------------------


\ifpdf
  
  \usepackage[pdftex,plainpages=false,pdfpagelabels,pdfpagemode={UseOutlines},bookmarks,pagebackref,hyperindex,hyperfigures]{hyperref}
  
  % Used for adding figures in thesis
  \usepackage[pdftex]{graphicx}
  
  % Make it easy to include PDFs using \includepdf macro. Note that PDF links will be lost when including!
  \usepackage{pdfpages}
  
\else
  
  \usepackage[dvips,bookmarks,pagebackref,hyperindex,hyperfigures]{hyperref}

  % Used for adding figures in thesis
  \usepackage{graphicx}
  
\fi

\usepackage[all]{hypcap} % Correct a problem with hyperref

\hypersetup{%
  bookmarksopen = true,
  bookmarksnumbered = true,
  breaklinks = true,
  linktocpage,
  colorlinks = false,% was true
  linkcolor = blue,
  urlcolor  = blue,
  citecolor = red,
  anchorcolor = green
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
\usepackage{charter}

%:-------------------------- Bibliography etc. -----------------------

% Citation numbering not starting on table of contents 
\usepackage{notoccite} 

%:-------------------------- Symbols -----------------------

% AMS
\usepackage{amsfonts, amsmath, amssymb, amsthm, amscd, xspace}

\usepackage{mathtools}
\usepackage{wasysym} % Math symbols
\usepackage{ifsym}
\usepackage{bm}

%:-------------------------- Page layout -----------------------

% Geometry is needed to set frontpage layout
\usepackage[pass]{geometry}

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


% Begin paragraphs with an empty line rather than an indent
\usepackage[parfill]{parskip}

% Set indent at new paragraph to 0
\setlength{\parindent}{\z@} 

% Set paragraph skip length to two lines
% Note: this reads the current value of \baselineskip for the normal font and font size, and stores it in parskip.
% Chaning \baselineskip will NOT change \parskip
\setlength{\parskip}{\baselineskip}

%\typeout{Old paragraph definition: \meaning\paragraph}

% Renew paragraph spacing to make sure we are strict about white space between paragraphs
% Lines should always align to baseline grid, i.e. we do not allow "rubber" lengths
% See http://en.wikibooks.org/wiki/LaTeX/Paragraph_Formatting and http://tex.stackexchange.com/questions/53008/align-baseline-in-multicol
\renewcommand\paragraph{%
    \@startsection{paragraph}{4}{\z@}%
       {2\baselineskip}%  default is "3.25ex \@plus1ex \@minus.2ex"
       {-1em}{\normalfont\normalsize\bfseries \SS@parafont}%
}

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

% Fix head height
\setlength{\headheight}{15pt}

%:-------------------------- Black magic hacks -----------------------

% Used together with small caps to achieve fake emphasized (actually slanted) small caps
\newcommand{\faketextsl}[1]{%
   \tikz[baseline=(N.base)]%
   % The transform says:
   % x' = 1x + 0.22y + 0pt
   % y' = 0x + 1y    + 0pt
   % This gives a slant - adjust the value for each font!
   \pgfsys@transformcm{1}{0}{0.18}{1}{0pt}{0pt}% This is adjusted to look good with Charter BT
   \node[inner sep=0pt] (N) {#1};%
}

% Redeﬁne the macro \textsc that switches to small capitals.
% If the actual font is italic or slanted, switch to a fake slanted small caps, otherwise switch to ordinary small caps.
% Note: this macro is based on a similar macro from the "slantsc" package.
\DeclareRobustCommand\textsc[1]{%
    \ifthenelse{\equal{\f@shape}{\scdefault}}{% If text already has small caps shape
        % Do nothing
        {#1}%
    }{% Else
        \ifthenelse{\equal{\f@shape}{\itdefault}\or\equal{\f@shape}{\sldefault}}{% If text is italicized or slanted
            {\fontshape\scdefault\selectfont\faketextsl{#1}}%
        }{%
            {\fontshape\scdefault\selectfont{#1}}%
        }%
    }%
}

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
\usepackage[acronym,shortcuts,nomain,nonumberlist,nopostdot]{glossaries}

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
    %\tikzstyle{every rectangle node}=[draw]                                                                                     % Just for debugging, not used!
    %\draw[fill,color=red] (0,0) rectangle (3.15cm,3.15cm);                                                                % Just for debugging, not used!
    \draw[fill,color=chapnumcol] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;                       % Draw UiT "slash"
    \draw[color=black] (1.81,1.28) node[rectangle] { \Huge\bfseries\chapnumfont\thechapter };     % Draw chapter number
  \end{tikzpicture}
}
\newlength{\chapterheadalign}
\setlength{\chapterheadalign}{\z@}
\setlength{\chapterheadalign}{\z@ - 3.15cm + 1em + 7\baselineskip} % Align bottom of UiT slash with bottom of baseline (therefore, we subtract 1em)

% Align chapter num
\newlength{\chapternumalign}
\setlength{\chapternumalign}{\z@} % Align bottom of UiT slash with bottom of baseline
\setlength{\chapternumalign}{1.28cm - 20pt - \baselineskip} % Align bottom of chapter number with bottom of baseline

% Align chapter name
\newlength{\chapternamealign}
\setlength{\chapternamealign}{\z@}
\setlength{\chapternamealign}{\z@ - \chapternumalign}

% Extra vertical spacing that is added by book.cls in addition to the default 50\p@ (I think it is \vspace* that does it)
% See https://groups.google.com/forum/#!topic/comp.text.tex/tIoCvZWpF7U
\newlength{\chapterheadtopvspace}
\setlength{\chapterheadtopvspace}{\parskip + \baselineskip}

%%%%%%%%%%%%%%% THESE CAN BE CHANGED!!!!! %%%%%%%%%%%%%%%
\def\baselinesbeforechaphead{6} % Approximate same distance as would be with standard 50\p@ vspace
\def\baselinesafterchapnum{4}
\def\baselinesafterchaptitle{4}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\def\chaptitlefontsize {\normalsize}
\def\chaptitlefontsize {\Huge}
%\def\chaptitlefontsize {\fontsize{50}{60}}

% Now, use our supahdupah chapter style! YEEEEEEAAAAHHHHHH!
\titleformat{\chapter}[display]
  {}
  {\printchapternum}
  {\z@ - \parskip + \chapternamealign + \baselinesafterchapnum\baselineskip} % Vertical distance between chapter number and chapter title
  {% Make sure Chapter title aligns to baseline
    \chaptitlefont\chaptitlefontsize\selectfont
    \vspace*{-\baselineskip}}
  [% Make sure that normal text following chapter title aligns to baseline
    \vspace*{-1ex}
    \vspace*{-\baselineskip}
    \normalsize\normalfont\selectfont
    \vspace*{1ex}
    \vspace*{\parskip}]

% Adjust spacing around chapter title
\titlespacing{\chapter}
  {\z@}          % Left margin = 0
  {\z@ - \chapterheadtopvspace + \chapterheadalign + \chapternumalign + \baselinesbeforechaphead\baselineskip} % Vertical space before chapter head (50\p@ is standard from book.cls)
  {\z@ - \parskip + \baselinesafterchaptitle\baselineskip}        % Vertical space after title, before text (\ttl@chapafter is default)


%:-------------------------- TOC and lists -----------------------

\renewcommand{\acronymname}{List of Abbreviations}



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


%:-------------------------- Frontpage stuffs -----------------------

\usepackage{eso-pic}
\usepackage{setspace}



% Custom variables for the frontpage
\def\thesissubtitle#1{\def\@thesissubtitle{#1}}
\def\thesisfaculty#1{\def\@thesisfaculty{#1}}
\def\thesisprogramme#1{\def\@thesisprogramme{#1}}
\def\ThesisFrontpageImage#1{\def\@ThesisFrontpageImage{#1}}
\def\ThesisFrontpageLogo#1{\def\@ThesisFrontpageLogo{#1}}

\ThesisFrontpageImage{frontpage_image.pdf}
\ThesisFrontpageLogo{frontpage_overlay_logo.pdf}
%\ThesisFrontpageLogo{original_frontpage_ref.pdf} % Use this to check title alignment

\renewcommand\maketitle{
  % Set custom geometry for the frontpage text
  \newgeometry{top=16.5mm,bottom=10mm,right=7mm,left=59mm}
  
  \begin{titlepage}%
  
  \AddToShipoutPicture*{
    \put(-3,-110.5){  % This is the correct position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \includegraphics[width=199.5mm,height=199.5mm,
        keepaspectratio]{\@ThesisFrontpageImage}%
        \vfill
  }}}
  
  \AddToShipoutPicture*{
    \put(-3,0){   % For some reason, (-3, 0) is the magic position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \includegraphics[width=\paperwidth,height=\paperheight,
        keepaspectratio]{\@ThesisFrontpageLogo}%
        \vfill
  }}}
  
  % Text
  \begingroup\begin{spacing}{0.9}
  \fontsize{10.3pt}{13pt}\usefont{OT1}{fos}{l}{n}\selectfont
  \@thesisfaculty
  \end{spacing}\endgroup
  
  \begingroup\begin{spacing}{0.85}
  \fontsize{12.5pt}{15pt}\usefont{OT1}{fos}{b}{n}\selectfont
  \@title
  \end{spacing}\endgroup
  
  \ifdefined\@thesissubtitle
    \begingroup\begin{spacing}{0.5}
    \fontsize{12.5pt}{19pt}\usefont{OT1}{fos}{l}{it}\selectfont
    \@thesissubtitle
    \end{spacing}\endgroup
  \fi
  
  \begingroup\begin{spacing}{0.32}
  \fontsize{12.5pt}{15pt}\usefont{OT1}{fos}{l}{it}\selectfont
  —
  \end{spacing}\endgroup
  
  \begingroup\begin{spacing}{0.32}
  \fontsize{10.3pt}{13pt}\usefont{OT1}{fos}{sb}{n}\selectfont
  \@author
  \end{spacing}\endgroup
  
  \begingroup\begin{spacing}{0.5}
  \fontsize{10.3pt}{13pt}\usefont{OT1}{fos}{l}{it}\selectfont
  \@thesisprogramme
  \end{spacing}\endgroup
  
  \end{titlepage}%
  
  % Restore original geometry
  \restoregeometry
  
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\@thesissubtitle\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
  \global\let\thesissubtitle\relax
}


%:-------------------------- Convenient macros and definitions -----------------------

\def \const #1{\penalty 100 \hbox{\texttt{#1}}}

% That's all, folks!
\endinput
