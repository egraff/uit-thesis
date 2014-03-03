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
\DeclareOption{openany}{}

% DVI of PDF?
\ifx\pdfoutput\undefined
  \PassOptionsToClass{dvips}{\baseclass}
\else
  \PassOptionsToClass{pdftex}{\baseclass}
\fi

% Option for drawing baseline grid
\newif\ifult@drawbaselinegrid
\ult@drawbaselinegridfalse % Default to false
\DeclareOption{baselinegrid}{\ult@drawbaselinegridtrue}

% Option for using indented paragraphs instead of vertical skip between paragraphs
\newif\ifult@parindent
\ult@parindentfalse % Default to false
\DeclareOption{parindent}{\ult@parindenttrue}

% Option for adding Preface
\newif\ifult@preface
\ult@prefacefalse % Default to false
\DeclareOption{preface}{\ult@prefacetrue}

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

%:-------------------------- DEBUG -----------------------

% Used to halt LaTeX compilation
\def\debughalt#1{%
  \PackageError{uit-thesis}{DEBUG}{#1}}

% Used to output definition of a LaTeX macro in console
\def\debugdef#1{%
  \typeout{[DEBUG] Definition of \@backslashchar #1: \expandafter\meaning\csname#1\endcsname ^^J ^^J}}

%:-------------------------- LaTeX control flow macros -----------------------

% Used to provide if-then-else macros
\usepackage{ifthen}

% Used to provide \ifpdf macro
\usepackage{ifpdf}

% Allow calculations in \vspace*
\usepackage{calc}

% Used to prevent given LaTeX macro from being called more than once
\newcommand\ult@once[1]{%
  % Save original macro
  \expandafter\let\csname ult@once@save\expandafter\@gobble\string#1\endcsname#1
  %
  % DEBUG
  %\typeout{DEBUG \expandafter\meaning\csname ult@once@savelistoffigures\endcsname}
  %\debughalt{}
  %
  % Re-define macro
  \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
    % Invoke original macro
    \csname ult@once@save\expandafter\@gobble\string#1\endcsname%
    % Re-define macro
    \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
      % Warn on second usage
      \@latex@warning{Call to \@backslashchar\expandafter\@gobble\string#1\space was ignored, because it was called previously}%
      % Re-define macro
      \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
        % Error on third usage
        \@latex@error{Duplicate call to \@backslashchar\expandafter\@gobble\string#1}\@ehd
      }%
    }%
  }%
}

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

%\colorlet{chapnumcol}{pms2229}
\definecolor{chapnumcol}{cmyk}{0.77,0.09,0.32,0}

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

%:-------------------------- Footnotes ----------------------------

\debugdef{@makefnmark}
\debugdef{@makefntext}
\debugdef{@footnotemark} % Uses \@makefnmark
\debugdef{@thefnmark}
\debugdef{footnote}
\debugdef{@footnotetext}
\debugdef{@mpfootnotetext}
\debugdef{@xfootnotemark}

\typeout{^^J ^^J ============================================= ^^J ^^J}

\usepackage[splitrule,% % If a footnote is split, draw a full width rule above the continued part of the footnote as a visual cue to readers
            bottom%    % Make sure footnotes are pushed to the bottom of the page (instead of being placed after the actual page break)
           ]{footmisc}

\debugdef{footnote}
\debugdef{@footnotetext}
\debugdef{@mpfootnotetext}
\debugdef{@xfootnotemark}

%\debughalt{}

%\usepackage{fnpct}
%\usepackage{footnotebackref}

\debugdef{@makefnmark}
\debugdef{@makefntext}
\debugdef{@footnotemark} % Uses \@makefnmark
\debugdef{@thefnmark}

\debugdef{par}
\debugdef{@par}
\debugdef{@@par}
\debugdef{@setpar}
\debugdef{parshape}

\debugdef{hangfootparskip}
\debugdef{hangfootparindent}


% The actual marker symbol (per footnote)
\providecommand*{\thefootnotemark}{\@thefnmark}

% Footnote marker font
\newcommand*{\ftnm@font}{\normalfont}

% Footnote text font
\newcommand*{\ftn@font}{\normalfont}

% Definition of footnote mark in actual footnote
% Currently set to adapt to Chicago style footnotes with non-superior footnote labels and single dot after label.
\def\@@makefnmark{%
    \hbox{{\ftnm@font{\@thefnmark .\space}}}%
}

% Footnote paragraph skip
\def\hangfootparskip{\z@}

% Footnote paragraph indentation
\def\hangfootparindent{2.5em}%

% Width of footnote label box
\def\ult@footnotemarkwidth{2.4em}

% Horizontal space between footnotemark and start of text
\def\footnotemargin{\z@}

% Redefine footnote with hanging style, based on above parameters
\long\def\@makefntext#1{%
  \bgroup
  \setbox\@tempboxa\hbox{%
    \ifdim\footnotemargin>\z@
      \hb@xt@\z@{\hb@xt@-\footnotemargin{\hss\@@makefnmark}\hss}%
    \else
      \@@makefnmark
    \fi
  }%
  \@tempdima = \hsize
  \addtolength{\@tempdima}{-\ult@footnotemarkwidth}%
  \addtolength{\@tempdima}{-\footnotemargin}%
  \@tempdimb = \ult@footnotemarkwidth
  \addtolength{\@tempdimb}{\footnotemargin}%
  \parshape \@ne \@tempdimb \@tempdima
  \@setpar{{\@@par}}%
  \leavevmode
  \llap{\box\@tempboxa}%
  \parskip\hangfootparskip\relax
  \parindent\hangfootparindent\relax
  \ftn@font#1%
  \par\egroup
}

%:-------------------------- Figures, graphics, includes, etc.  -----------------------


\ifpdf
  
  \usepackage[pdftex,%                       %
              plainpages=false,%             %
              pdfpagelabels,%                %
              pdfpagemode={UseOutlines},%    % Show bookmarks
              pdfstartview={FitV},%          % Fit height of page to PDF viewer window
              pdfpagelayout={TwoPageRight},% % Display two pages, odd-numbered pages to the right
              pdfdisplaydoctitle,%           % Display document title instead of filename in title bar
              bookmarks,%                    % Show bookmarks bar when displaying document
              pagebackref,%                  % Allow back references inside bibilography.
              hyperindex,%                   %
              hyperfigures%                  %
             ]{hyperref}
  
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
  bookmarksopen=true,
  bookmarksnumbered=true,
  breaklinks=true,
  linktocpage,
  colorlinks=false,% Should never be set to true, as it reduces quality of print...
  linkcolor=blue,
  urlcolor =blue,
  citecolor=red,
  anchorcolor=green,
  hidelinks% Remove color and border
}

% Enables adding figures and tables side by side
\usepackage{subfigure}

% Listings
\usepackage{listings}

% Override \title to update pdftitle
\let\ult@savetitle\title
\def\title#1{%
  \ult@savetitle{#1}%
  \hypersetup{pdftitle={#1}}%
}

% Override \author to update pdfauthor
\let\ult@saveauthor\author
\def\author#1{%
  \ult@saveauthor{#1}%
  \hypersetup{pdfauthor={#1}}%
}

% Add macro for subtitle
\def\subtitle#1{\gdef\@subtitle{#1}}

%:-------------------------- Table of Contents (TOC) -----------------------C

% ToC support for list of figures, list of tables, bibliography, index, etc.
\usepackage[nottoc%     % No entry for ToC in ToC
           ]{tocbibind}

% Styling of actual Table of Contents
\usepackage[subfigure,% % Needed to be compatible with subfigure package
            titles%     % Retain chapter headers
           ]{tocloft}

%:-------------------------- Things we need to do magic -----------------------

% For sweet-ass drawings and transformations and shit
\usepackage{tikz}

% Needed by our black magic hacks below
\usepackage{l3regex}
\usepackage{xparse}

%:-------------------------- Fonts -----------------------

\usepackage{opensans}
\usepackage{charter}


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

\ifult@parindent
  % No skip between paragraphs when using indentation
  \setlength{\parskip}{\z@}

  % NOTE: We retain the default \parindent
\else
  % Begin paragraphs with an empty line rather than an indent
  \usepackage[parfill]{parskip}

  % Set indent at new paragraph to 0
  \setlength{\parindent}{\z@}

  % Set paragraph skip length to two lines
  % Note: this reads the current value of \baselineskip for the normal font and font size, and stores it in parskip.
  % Changing \baselineskip later will NOT change \parskip
  \setlength{\parskip}{\baselineskip}
\fi


\linespread{1.0}

% Strict linespacing, don't allow LaTeX to put extra spacing between lines
\lineskip=0pt

\renewcommand{\baselinestretch}{1.0}\normalsize

%\typeout{Old paragraph definition: \meaning\paragraph}

%%% NOTE
%%% The \@startsection macro is defined as follows:
%%%  \@startsection{<name>}{<level>}{<indent>}{<beforeskip>}{<afterskip>}{<style>}*[<altheading>]{<heading>}
%%% where the part after the *, including the * is optional.
%%% See http://tex.stackexchange.com/questions/31780/where-can-i-find-help-files-or-documentation-for-commands-like-startsection-fo
%%% and http://www.tug.org/texlive/Contents/live/texmf-dist/doc/latex/base/source2e.pdf

% Renew paragraph spacing to make sure we are strict about white space between paragraphs
% Lines should always align to baseline grid, i.e. we do not allow "rubber" lengths
% See http://en.wikibooks.org/wiki/LaTeX/Paragraph_Formatting and http://tex.stackexchange.com/questions/53008/align-baseline-in-multicol
\renewcommand\paragraph{%
    \@startsection{paragraph}{4}% Paragraph = level 4
                  {\z@}% No left indentation of heading
                  % Absolute value = skip to leave above the heading. Positive value means that text following heading retains indentation.
                  {2\baselineskip}% Default is "3.25ex \@plus1ex \@minus.2ex"
                  % If positive, then skip to leave below heading, else negative of skip to leave to right of run-in heading.
                  {-1em}
                  {\normalfont\normalsize\bfseries \SS@parafont}% Style
}

%\gridSetup[pt]{\p@}{2}{12}{20}{2}
%\renewcommand*\ESO@gridcolor{red!20}
%\renewcommand*\ESO@subgridcolor{blue!20}

% BASELINE GRID
\usepackage{atbegshi,picture}
\ifult@drawbaselinegrid
\AtBeginShipout{%
  \AtBeginShipoutUpperLeft{%
    \color{red}%
    \put(\dimexpr 1in+\oddsidemargin,
         -\dimexpr 1in+\topmargin+\headheight+\headsep+\topskip)%
      {%
       \vtop to\dimexpr\vsize+\baselineskip{
         \hrule
         \leaders\vbox to\baselineskip{\hrule width\hsize\vfill}\vfill
       }%
      }%
  }%
}
\fi

%:-------------------------- Bibliography etc. -----------------------

% Citation numbering not starting on table of contents
% Note: we do not use notoccite package, since it overwrites changes that
% parskip does to \@starttoc
\renewcommand*{\@starttoc}[1]{%
  \begingroup
    \@fileswfalse  % Add modification from notoccite
    \makeatletter
    \parskip\z@    % Retain modification from parskip
    \@input{\jobname.#1}%
  \endgroup
  \if@filesw
    \expandafter\newwrite\csname tf@#1\endcsname
    \immediate\openout \csname tf@#1\endcsname \jobname.#1\relax
  \fi
  \@nobreakfalse
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
% Translate=false because package 'babel' reverts renaming of the default glossary-/acronymnames
\usepackage[toc,acronym,shortcuts,nonumberlist,nopostdot,translate=false]{glossaries}

% Apparently, no problem running makegloss here
\makeglossaries

% Make glossarylistings start with Caps (This is for regular glossary entries, not acronyms)
\renewcommand{\glsnamefont}[1]{\makefirstuc{#1}}

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


% Prevent grouping together abbreviations starting on same letter in list of
% abbreviations.
% See http://tex.stackexchange.com/questions/4183/package-glossaries-single-spaced-printglossaries
\glsnogroupskiptrue
\renewcommand*{\glsgroupskip}{}

%:-------------------------- Chapter and section style -----------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        DEBUG         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
\debugdef{@startsection}
\debugdef{@makechapterhead}
\debugdef{@chapter}
\debugdef{chapter}
\debugdef{secdef}
\debugdef{section}
\debugdef{sectfont}
\debugdef{SS@sectfont}

% Alias sectsty internals
\newcommand{\chapnumfont}{\SS@chapnumfont}     % use \chapternumberfont{} to change
\newcommand{\chaptitlefont}{\SS@chaptitlefont} % use \chaptertitlefont{} to change
\newcommand{\sectfont}{\SS@sectfont} % use \sectionfont{} to change

% Use Open Sans (fos) instead of Charter BT (bch) as chapter and section title font
\allsectionsfont{\rmfamily\upshape\bfseries\usefont{OT1}{fos}{bx}{n}\selectfont}

% Change font for chapter number
\chapternumberfont{%
  \usefont{T1}{fos}{b}{n}%      % Use Open Sans as chapter number font
  \fontsize{56}{56}%            % font size 60pt, baselineskip 60pt
  \selectfont%                  % activate font
}

% Define how chapter number is drawn
\newcommand{\printchapternum}{
  \begin{tikzpicture}
    %\tikzstyle{every rectangle node}=[draw]                                                      % Just for debugging, not used!
    %\draw[fill,color=red] (0,0) rectangle (3.15cm,3.15cm);                                       % Just for debugging, not used!
    \draw[fill,color=chapnumcol] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;         % Draw UiT "slash"
    \draw[color=black] (1.78,1.18) node[rectangle] { \Huge\bfseries\chapnumfont\thechapter };     % Draw chapter number
  \end{tikzpicture}
}
\newlength{\chapterheadalign}
\setlength{\chapterheadalign}{\z@}
\setlength{\chapterheadalign}{\z@ - 3.15cm - 0.0142cm + 7\baselineskip} % Align bottom of UiT slash with bottom of baseline % XXX: The 0.0142cm magic constant really bothers me....

% Align chapter num
\newlength{\chapternumalign}
\setlength{\chapternumalign}{\z@} % Align bottom of UiT slash with bottom of baseline
%\setlength{\chapternumalign}{1.28cm - 20\p@ - \baselineskip} % Align bottom of chapter number with bottom of baseline

% Align chapter name
\newlength{\chapternamealign}
\setlength{\chapternamealign}{\z@}
\setlength{\chapternamealign}{\z@ - \chapternumalign}

% Extra vertical spacing that is added by book.cls in addition to the default 50\p@ (I think it is \vspace* that does it)
% See https://groups.google.com/forum/#!topic/comp.text.tex/tIoCvZWpF7U
\newlength{\chapterheadtopvspace}
\setlength{\chapterheadtopvspace}{\parskip + \baselineskip}

%%%%%%%%%%%%%%% THESE CAN BE CHANGED!!!!! %%%%%%%%%%%%%%%
\def\baselinesbeforefrontchaphead{8} % Approximate same distance as would be with standard 50\p@ vspace
\def\baselinesbeforemainchaphead{6} % Approximate same distance as would be with standard 50\p@ vspace
\def\baselinesafterchapnum{3}
\def\baselinesafterchaptitle{2}

\def\baselinesbeforesection{3}
\def\baselinesaftersection{0}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%
%\renewcommand{\chaptitlefont}{\normalfont\selectfont}
%\def\chaptitlefontsize {\normalsize}
%\def\chaptitlefontsize {\fontsize{10}{3}}
%\def\chaptitlefontsize {\fontsize{10}{30}}
%\def\chaptitlefontsize {\fontsize{10}{60}}
%\def\chaptitlefontsize {\Huge}
%\def\chaptitlefontsize {\fontsize{24}{60}}
%\def\chaptitlefontsize {\fontsize{24}{72}}
%\def\chaptitlefontsize {\fontsize{24}{128}}
%\def\chaptitlefontsize {\fontsize{28}{10}}

% Pretty size that spans two baselines. Height is approx. \baselineskip + \fontcharht\font`B
\def\chaptitlefontsize {\fontsize{26}{32}}

% XXX: Should create a better strut that accomodates possibility of \baselineskip < 1em
% Should use \vspace*{-\fontchardp\font`q} and \vspace*{-\fontcharht\font`B}
% instead of \baselineskip...
\def\fixedstrutbox{\strutbox}
\def\fixedstrut{\relax\unhcopy\fixedstrutbox}

% Now, use our supahdupah chapter style! YEEEEEEAAAAHHHHHH!
\titleformat{\chapter}[display]
  {}
  {\vspace*{-\baselinesbeforefrontchaphead\baselineskip} \vspace*{\baselinesbeforemainchaphead\baselineskip} \vspace*{\chapterheadalign} \vspace*{\chapternumalign} \printchapternum}
  {\z@ - \parskip + \chapternamealign + \baselinesafterchapnum\baselineskip} % Vertical distance between chapter number and chapter title
  {% Make sure Chapter title aligns to baseline
    \chaptitlefont\chaptitlefontsize\selectfont
    \vspace*{-\baselineskip} % XXX: This does not work when \baselineskip < 1em
  }%
  [% Make sure that normal text following chapter title aligns to baseline
    %
    % The titlesec package inserts something like
    %  \kern \z@ \strut \@@par \nobreak
    % before this.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  NOTE: This is black magic!!! It was infinitely hard to figure out!!  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % You should see:
    % --------------------------
    % http://tex.stackexchange.com/questions/40977/confused-with-tex-terminology-height-depth-width
    % http://tex.stackexchange.com/questions/21832/definition-of-strut-explained
    % http://en.wikibooks.org/wiki/LaTeX/Rules_and_Struts
    % http://tex.stackexchange.com/questions/41185/whats-the-difference-between-strut-mathstrut-and-vphantom
    % http://tex.stackexchange.com/questions/121627/why-is-strut-working-in-these-scenarios
    % http://tex.stackexchange.com/questions/4239/which-measurement-units-should-one-use-in-latex
    % http://tex.stackexchange.com/questions/22225/determine-height-and-depth-of-letters-relative-to-the-font-size
    % --------------------------
    %
    % The criteria for determining whether this "works" or not, is if the text lines following the
    % chapter title are positioned equally, regardless of the baseline skip of the chapter title font.
    % To test this, I have varied the font between these definitions:
    %  \def\chaptitlefontsize {\normalsize}
    %  \def\chaptitlefontsize {\fontsize{10}{60}}
    %  \def\chaptitlefontsize {\Huge}
    %  \def\chaptitlefontsize {\fontsize{24}{60}}
    %  \def\chaptitlefontsize {\fontsize{24}{72}}
    %  \def\chaptitlefontsize {\fontsize{24}{128}}
    %
    %
    % Sooo, here it is:
    %
    % Note: we have confirmed that this is needed (try changing value of \parskip right before \@@par).
    % It's probably \@@par that inserts a \parskip. Also note that \parskip does not change when changing font size...
    \vspace*{-\parskip}
    %
    % Compensate for 'depth' of strut that was added
    % Note: \dp\strutbox === 0.3\baselineskip
    % Also note that \dimen0 may sometimes be equal to \dp\strutbox, but most often it is not!
    \vspace*{-\dp\fixedstrutbox}
    %
    % Now, compensate for entire line
    \vspace*{-\baselineskip}
    %
    % Simulate strut of previous line
    \kern \z@ \fixedstrut \@@par \nobreak
    %
    % But remove parskip
    \vspace*{-\parskip}
    %
    % So far, so good!
    %
    % Now, switch to normal font
    \normalsize\normalfont\selectfont
    %
    % Simulate that chapter title was one line with normal font
    \vspace*{-\baselineskip}
    %
    % But compensate for 'depth' of strut that was removed
    \vspace*{\dp\fixedstrutbox}
    %
    % Aaaand... add our own strut
    \kern \z@ \strut
  ]

% Adjust spacing around chapter title
\titlespacing*{\chapter}
  {\z@}          % Left margin = 0
  {\z@ - \chapterheadtopvspace + \baselinesbeforefrontchaphead\baselineskip} % Vertical space before chapter head (50\p@ is standard from book.cls)
  {\z@ - \parskip + \baselinesafterchaptitle\baselineskip}        % Vertical space after title, before text (\ttl@chapafter is default)


% The titlesec package overrides definition of \section, but sectsty overrides that definition in turn.
% Re-define \section using titlesec's macros
% NOTE: We do this instead of renewing \section definition manually
% using \@startsection, because it allows a higher degree of flexibility.
\titleclass{\section}{straight}

% Now, define how \section is formatted.
\titleformat{\section}[hang]
  {\normalfont \vspace*{\baselineskip} \Large \bfseries \sectfont \selectfont \vspace*{-\baselineskip}}% Format
  {\thesection\space}% Label
  {\z@}% Sep
  {}% Before-code
  []% After-code

% Starred version makes sure we suppress indentation of text following section title
\titlespacing*{\section}
  {\z@}% % Left margin = 0
  {\z@ + \baselinesbeforesection\baselineskip}% % Vertical space before
  {\z@ + \baselinesaftersection\baselineskip}%  % Vertical space after





% NOTE: chapter head is printed as:
%   #4{#8}\kern \z@ \strut \@@par \nobreak #5\@@par
% where #4 = before, #8 = title, #5 = after
% 'before' and 'after' are arguments from \titleformat
% (defined in \ttlh@display).


%%% From titlesec.sty:
%%% ----------------------------------
%%% The following tags are used:
%%% ttl@  : the generic tag used through the style
%%% ttlh@ : a shape definition
%%% ttlf@ : a macro containing the title format
%%% ttls@ : id. the title space
%%% ttlp@ : page key related macros
%%% ttll@ : level number
%%% ----------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        DEBUG         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
\typeout{[DEBUG] After re-definition of chapter stuff... ^^J ===================================================== ^^J ^^J}
%\debugdef{@startsection}
\debugdef{@makechapterhead}
\debugdef{ttl@startargs}
\debugdef{ttl@mkchap}
\debugdef{ttl@mkchap@i}
\debugdef{ttl@save@mkchap}

% \ttl@mkchap has following arguments:
% 1: left        --- 1st \ttls@chapter arg == \z@
% 2: right       --- 2nd \ttls@chapter arg == \z@
% 3: before      --- 3rd \ttls@chapter arg == 2nd \titlespacing arg
% 4: after       --- 4th \ttls@chapter arg == 3rd \titlespacing arg
% 5: afterindent --- 5th \ttls@chapter arg == \@ne
% 6: name  == {chapter}
% 7: title

% \ttl@select has following arguments:
% 1: {chapter}   --- 6th \ttl@mkchap arg
% 2: left        --- 1st \ttl@mkchap arg == 1st \ttls@chapter arg == \z@
% 3: right       --- 2nd \ttl@mkchap arg == 2nd \ttls@chapter arg == \z@
% 4: title       --- 7th \ttl@mkchap arg

% Contains arguments from \titlespacing
%%% From titlesec.sty:
%%% -------------------------------------------
% % The surrounding space is stored in a macro
% % named \ttls@<section> whose content is
% % {left}{right}{before}{after}{afterindent}.
%%% -------------------------------------------
%%% 'before' is 2nd argument from \titlespacing, and 'after' is 3rd argument
%%% 'left' and 'right are zero (\z@), and 'afterindent' is \@ne
\debugdef{ttls@chapter}

% \ttlh@<shape> defines the \titleformat shape
% We use the 'display' shape above to place title label in separate paragraph
% (see http://ctan.mackichan.com/macros/latex/contrib/titlesec/titlesec.pdf section 3.1)
%%% From titlesec.sty:
%%% -------------------------------------------
%%% % 1:global 2:label 3:sep 4:style 5:after 6:left 7:right 8:title
%%% \ttl@<shape> and \ttlh@<shape> take the following eight
%%% arguments:
%%% {format}{label}{sep}{before}{after}{left}{right}{title}
%%% where before and after refer to the format.
%%% With the option explicit, #4 contains the title and #8 is
%%% empty.
%%% -------------------------------------------
% Note: this macro contains the actual definition of what \@makechapterhead outputs!!
\debugdef{ttlh@display}

% Macro for invoking \ttlh@display with arguments from \titleformat{\chapter}
\debugdef{ttlf@chapter}

\debugdef{section}

% DEBUG: Uncomment this to halt LaTeX compilation
%\debughalt{Debug halt.}


%:-------------------------- ToC lists -----------------------

% Used to determine if document contains figures, tables, listings, etc.
\usepackage[figure,table,lstlisting]{totalcount}

% List of figures
\let\ult@savelistoffigures\listoffigures
\renewcommand\listoffigures{%
  \iftotalfigures% Only output list if count > 0
    \cleardoublepage
    \ult@savelistoffigures
  \fi
}
% Make sure \listoffigures has effect at most once!
\ult@once{\listoffigures}

% List of tables
\let\ult@savelistoftables\listoftables
\renewcommand\listoftables{%
  \iftotaltables% Only output list if count > 0
    \cleardoublepage
    \ult@savelistoftables
  \fi
}
% Make sure \listoftables has effect at most once!
\ult@once{\listoftables}


% Register listings with tocloft
\begingroup\let\newcounter\@gobble\let\setcounter\@gobbletwo
  \globaldefs\@ne \let\c@loldepth\@ne
  \newlistof{listings}{lol}{\lstlistlistingname}
\endgroup
\let\l@lstlisting\l@listings
\AtBeginDocument{\addtocontents{lol}{\protect\addvspace{10\p@}}}
\setlength{\cftlistingsindent}{1.5em}
\setlength{\cftlistingsnumwidth}{2.3em}

% Use tocbibind to generate list of listings
\renewcommand{\lstlistoflistings}{%
  \begingroup
    \tocfile{\lstlistlistingname}{lol}
  \endgroup%
}

% List of Listings
\renewcommand{\lstlistlistingname}{List of Listings}
\let\ult@lstlistoflistings\lstlistoflistings
\renewcommand\lstlistoflistings{%
  \iftotallstlistings% Only output list if count > 0
    \cleardoublepage
    \ult@lstlistoflistings
  \fi
}
% Make sure \listoflistings has effect at most once!
\ult@once{\lstlistoflistings}

% List of Abbreviations
\renewcommand{\acronymname}{List of Abbreviations}
% Make sure \printacronyms has effect at most once!
\AtBeginDocument{%
  \ifglsacronym
    \ult@once{\printacronyms}
  \fi%
}

% Prevent \printglossaries
\renewcommand*{\printglossaries}{%
  \@latex@warning{Call to \@backslashchar printglossaries was ignored.}%
}

%:-------------------------- Book class overrides -----------------------

\let\ult@savefrontmatter\frontmatter
\renewcommand\frontmatter{%
  \ult@savefrontmatter
  
  % Set \leftmark to the left on odd pages
  \fancyhead[LO]{\nouppercase{\leftmark}}

  % Redefine what is in \chaptermark so that \leftmark contains chapter name. Thus "Abstract" and "Acknowledgements" will be written in header
  \renewcommand{\chaptermark}[1]{\markboth{##1}{}} % Note: we use two number signs (#) because we have renewcommand within renewcommand

  % Make sure that abbreviations are not expanded
  \glsunsetall
}

% Table of Contents
\let\ult@savetableofcontents\tableofcontents
\renewcommand\tableofcontents{%
  \ult@savetableofcontents

  \renewcommand\tableofcontents{%
    \@latex@error{Duplicate \@backslashchar tableofcontents}\@ehd
  }

  % LISTS
  % 1: Figures/illustrations
  % 2: Tables
  % 3: Abbreviations
  % 4: Symbols
  % 5: Preface

  \listoffigures

  \listoftables

  \lstlistoflistings

  % List of Abbreviations
  \printacronyms

  % Preface (Acknowledgements per haps)
  \ifult@preface
    \cleardoublepage
    % TODO: PREFACE
    \addcontentsline{toc}{chapter}{Preface}
  \fi

  % Abstract
}

\let\ult@savemainmatter\mainmatter
\renewcommand\mainmatter{%
  \ult@savemainmatter
  
  % Redefine \chaptermark, so it contains chapter number in front of chapter name (e.g. "2 My Chapers Name")
  \renewcommand{\chaptermark}[1]{\markboth{\thechapter\ ##1}{}} % Note: we use two number signs (#) because we have renewcommand within renewcommand
  
  % Set odd pages to have have \rightmark instead of \leftmark
  \fancyhead[LO]{\nouppercase{\rightmark}}
  
  % Reset glossaries so every abbreviation will expand on first use
  \glsresetall
}

\let\ult@savebackmatter\backmatter
\renewcommand\backmatter{%
  \ult@savebackmatter
  
  % Redefine headers for appendices
  \pagestyle{empty}

  % Print glossary and add to toc (regular glossary, and only if it has been used)
  \printglossary

  % Empty back cover
  \cleardoublepage
}


%:-------------------------- Frontpage stuffs -----------------------

\usepackage{eso-pic}

% \begin{egg}
\usepackage{xstring}
 \usetikzlibrary{arrows}
\newcommand{\printthed}{
\begin{tikzpicture}
\draw [o-*] plot[smooth, tension=.7] coordinates {(-12,-8) (-12,1) (-8,1) (-8,-8)};
\draw [o-*] plot[smooth, tension=.7] coordinates {(-12,1)};
\draw [o-*] plot[smooth, tension=.7] coordinates {(-12,1) (-13,4) (-10,7) (-7,4) (-8,1)};
\draw [o-*] plot[smooth, tension=.7] coordinates {(-10,6) (-10,7)};
\draw [o-*] (-13,-11) ellipse (3 and 3);
\draw [o-*] (-7,-11) ellipse (3 and 3);
\end{tikzpicture}
}
% \end{egg}

% Custom variables for the frontpage
\def\thesisfaculty#1{\def\@thesisfaculty{#1}}
\def\thesisprogramme#1{\def\@thesisprogramme{#1}}
\def\ThesisFrontpageImage#1{\def\@ThesisFrontpageImage{#1}}
\def\ThesisFrontpageLogo#1{\def\@ThesisFrontpageLogo{#1}}

\ThesisFrontpageImage{frontpage_image.pdf}
\ThesisFrontpageLogo{frontpage_overlay_logo.pdf}
%\ThesisFrontpageLogo{original_frontpage_ref.pdf} % Use this to check title alignment

\if@titlepage
\renewcommand\maketitle{
  % Set custom geometry for the frontpage text
  \newgeometry{top=16.5mm,bottom=10mm,right=7mm,left=59mm}
  %
  \begin{titlepage}%
  \AddToShipoutPicture*{%
    \put(-3,-110.5){% This is the correct position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill%
        \centering%
        \includegraphics[width=199.5mm,height=199.5mm,keepaspectratio]{\@ThesisFrontpageImage}%
        \vfill%
      }%
    }%
  }
  \AddToShipoutPicture*{%
    \put(-3,0){% For some reason, (-3, 0) is the magic position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill%
        \centering%
        \includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{\@ThesisFrontpageLogo}%
        \vfill%
      }%
    }%
  }
  % Faculty / department
  \begingroup
    \vskip \z@
    \fontsize{10.3pt}{23pt}\usefont{OT1}{fos}{l}{n}\selectfont
    \noindent\@thesisfaculty
    \vskip -\parskip
  \endgroup
  % Thesis title
  \begingroup
    \vskip 2\baselineskip
    \fontsize{12.5pt}{15pt}\usefont{OT1}{fos}{b}{n}\selectfont
    \vspace*{-\baselineskip}
    \noindent\@title
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}
  \endgroup
  % Thesis subtitle
  \ifdefined\@subtitle
    \ifx\@subtitle\@empty\else
      \begingroup
        \vskip \ht\strutbox
        \fontsize{12.5pt}{19pt}\usefont{OT1}{fos}{l}{it}\selectfont
        \vspace*{-\baselineskip}
        \noindent\@subtitle
        \vskip -\parskip
        \normalsize\normalfont\selectfont\vspace*{\baselineskip}
      \endgroup
    \fi
  \fi
  % Separation line
  \begingroup
    \fontsize{12.5pt}{15pt}\usefont{OT1}{fos}{l}{it}\selectfont
    \vspace*{-\baselineskip}
    \noindent ---
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}
  \endgroup
  % Name of author
  \begingroup
    \fontsize{10.3pt}{13pt}\usefont{OT1}{fos}{sb}{n}\selectfont
    \vspace*{-\baselineskip}
    \noindent\@author
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}
  \endgroup
  % Thesis description one-line / study program / month and year
  \begingroup
    \fontsize{10.3pt}{13pt}\usefont{OT1}{fos}{l}{it}\selectfont
    \vspace*{-\baselineskip}
    \noindent\@thesisprogramme
    \vskip -\parskip
  \endgroup
  %
  % \begin{egg}
  \IfEndWith{\@author}{arlberg}{\printthed}{}
  % \end{egg}
  %
  \end{titlepage}%
  %
  % Restore original geometry
  \restoregeometry
  %
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\@subtitle\@empty
  \global\let\title\relax
  \global\let\subtitle\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\fi


%:-------------------------- Convenient macros and definitions -----------------------

\def \const #1{\penalty 100 \hbox{\texttt{#1}}}

% todo macro
\newcommand{\todo}[1]{\textcolor{blue}{TODO:\\#1}}
% WIP macro
\newcommand{\wip}[1]{\textcolor{red}{W.I.P:\\#1}}

\let\ult@save@onefilewithoptions\@onefilewithoptions
\def\@onefilewithoptions#1[#2][#3]#4{%
  \ifx\AtBeginDocument\@firstofone\else
    \@latex@warning{Are you sure you are allowed to use the #1 package?}%
  \fi
  \ult@save@onefilewithoptions#1[{#2}][{#3}]#4%
}

% That's all, folks!
\endinput
