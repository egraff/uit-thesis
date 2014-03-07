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
\RequirePackage[explicit]{titlesec}
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

% Used to calculate ratio between two dimension commands
% http://tex.stackexchange.com/questions/6417/how-to-find-the-ratio-of-a-length-command-e-g-textwidth-to-a-reference-valu?rq=1
\newcommand*{\DivideLengths}[2]{%
  \strip@pt\dimexpr\number\numexpr\number\dimexpr#1\relax*65536/\number\dimexpr#2\relax\relax sp\relax
}

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

% Running head color
\definecolor{rheadcolor}{cmyk}{0.15,0,0,0.55}
\definecolor{rheadslashcolor}{cmyk}{0.6,0,0.2,0.1}

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

\usepackage[norule, % drop the small rule before footnotes
            splitrule,% % If a footnote is split, draw a full width rule above the continued part of the footnote as a visual cue to readers
            bottom%    % Make sure footnotes are pushed to the bottom of the page (instead of being placed after the actual page break)
           ]{footmisc}

\debugdef{footnote}
\debugdef{@footnotetext}
\debugdef{@mpfootnotetext}
\debugdef{@xfootnotemark}

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

% To read LaTeX macro from file
\usepackage{catchfile}

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
\lineskip=\z@

% Make sure that line spacing defined by \baselineskip will be preserved under all circumstances!
% See http://tex.stackexchange.com/questions/49072/is-changing-lineskiplimit-to-some-negative-value-a-good-idea-and-what-the-valu
% Note: this could be a potential source of future text formatting bugs (if lines are written on top of each other)
\lineskiplimit=-\maxdimen

\renewcommand{\baselinestretch}{1.0}\normalsize

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

% For \RaggedRight macro, which is better than \raggedright
\usepackage{ragged2e}

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

\newcounter{ult@c@firstblankpage}\setcounter{ult@c@firstblankpage}{\z@}%
\newcounter{ult@c@lastblankpage}\setcounter{ult@c@lastblankpage}{\z@}%
\newcounter{ult@c@tmpblankpage}

\newcommand\updatefirstblankpage{%
  \ifnum\c@page>\value{ult@c@firstblankpage}%
    \setcounter{ult@c@firstblankpage}{\c@page}%
    %\typeout{FIRST BLANK PAGE SET TO: \the\c@page}%
  \fi%
}

\newcommand\updatelastblankpage{%
  \setcounter{ult@c@lastblankpage}{\c@page}%
  %\typeout{LAST BLANK PAGE SET TO: \the\c@page}%
}

\let\ult@saveclearpage\clearpage
\renewcommand\clearpage{%
  \setcounter{ult@c@tmpblankpage}{\c@page}%
  \ult@saveclearpage%
  \ifnum\c@page=\value{ult@c@tmpblankpage}% Previous page was blank
    \ifnum\c@page>\value{ult@c@lastblankpage}
      \setcounter{ult@c@firstblankpage}{\c@page}%
      \addtocounter{ult@c@firstblankpage}{\m@ne}%
      %\typeout{LAST BLANK PAGE UPDATED TO: \the\value{ult@c@firstblankpage}}%
    \fi
  \else
    \updatefirstblankpage%
  \fi
}

% Macro to create empty page so that chapters always start on recto page
% Note that we use pagestyle "empty" to let the blank pages be blank folios (no page numbers)
% It can be changed to "plain" if page number is desired on blank pages
\def\cleardoublepage{%
  \clearpage%
  \if@twoside%
    \ifodd\c@page\else% If even page
      \updatelastblankpage% Verso page is blank
      \hbox{}%
      \thispagestyle{empty}%
      \newpage%
      \if@twocolumn%
        \hbox{}%
        \newpage%
      \fi%
    \fi%
  \fi%
}

% Make sure we have a blank verso page. Following content will continue on succeeding recto page.
% Note: this is different from \cleardoublepage, which allows content on verso page.
\def\clearversopage{%
  \clearpage%
  \if@twoside%
    \ifnum\value{ult@c@firstblankpage}>\value{ult@c@lastblankpage}% If we have no known, preceding blank pages
      \ifodd\c@page% If odd page (text ended on verso page)
        %\typeout{CLEARVERSO: ODDPAGE == Y ^^J}
        % Add one blank recto page and one blank verso page
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
        \updatelastblankpage% Verso page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
      \else % Text ended on recto page
        %\typeout{CLEARVERSO: EEEEEEEEEEVENPAGE ^^J}
        % Add one blank verso page
        \updatelastblankpage% Verso page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
      \fi%
    \else% If we have known, preceding blank pages
      %\typeout{CLEARVERSO: ALREADY BLANK ^^J}
      \ifodd\value{ult@c@lastblankpage}% If last blank page was recto page
        %\typeout{CLEARVERSO: ADDING EXTRA BLANK ^^J}
        \ifodd\c@page% Current page should not be recto page in this case...
          \@latex@error{BUG in \@backslashchar clearversopage in uit-thesis package!!!!!!!!!!}\@ehd
        \fi%
        % Add one blank verso page to get blank back-sheet
        \updatelastblankpage% Verso page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
       \fi%
    \fi%
  \fi%
}

% Make sure we have a blank recto page. Following content will continue on succeeding verso page.
\def\clearrectopage{%
  \clearpage%
  \if@twoside%
    \ifnum\value{ult@c@firstblankpage}>\value{ult@c@lastblankpage}% If we have no known, preceding blank pages
      \ifodd\c@page% If odd page (text ended on verso page)
        %\typeout{CLEARRECTO: ODDPAGE == Y ^^J}
        % Add one blank recto page
        \updatelastblankpage% Recto page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
      \else % Text ended on recto page
        %\typeout{CLEARRECTO: EEEEEEEEEEVENPAGE ^^J}
        % Add one blank verso page and one blank recto page
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
        \updatelastblankpage% Recto page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
      \fi%
    \else% If we have known, preceding blank pages
      %\typeout{CLEARRECTO: ALREADY BLANK ^^J}
      \ifodd\value{ult@c@lastblankpage}\else% If last blank page was verso page
        %\typeout{CLEARVERSO: ADDING EXTRA BLANK ^^J}
        \ifodd\c@page\else% Current page should not be verso page in this case...
          \@latex@error{BUG in \@backslashchar clearrectopage in uit-thesis package!!!!!!!!!!}\@ehd
        \fi
        % Add one blank recto page
        \updatelastblankpage% Recto page is blank
        \hbox{}%
        \thispagestyle{empty}%
        \newpage%
        \if@twocolumn%
          \hbox{}%
          \newpage%
        \fi%
       \fi%
    \fi%
  \fi%
}

% Define pagestyle
\pagestyle{fancy}

% Reset all header settings
\fancyhf{}

% strips the crazy head rule
\let\headrule\@empty

% fosj is opensans with old style figures
\newcommand{\rheadfont}{\fontsize{10pt}{12pt}\usefont{OT1}{fosj}{l}{n}\selectfont}

% Set pagenumber in the header.
% RO = Right Odd: Page number is set to the right in the header on odd pages
% LE = Left Even: Page number is set to the left in the header on even pages
\fancyhead[RO,LE]{\rheadfont\textcolor{rheadcolor}{\thepage}}

% Set \leftmark to show to the right in header on even pages. Only upper case on first letter of chapter name
% This will make sure that chapter title is written to the right on even/verso pages
\fancyhead[RE]{\rheadfont\textcolor{rheadcolor}{\nouppercase{\leftmark}}}

% Redefine what is in \sectionmark so that \rightmark contains section number and section name (e.g. "2.1 My Sections Name")
\renewcommand{\sectionmark}[1]{%
  \markright{\thesection\ \printrheadslash\ #1}% \leftmark (right even) is set to section number + title after start of new section
}

% Redefine "plain" pagestyle (used on first page of each chapter)
\fancypagestyle{plain}{%
  \fancyhf{} % clear all header and footer fields
  \fancyfoot[C]{\rheadfont \textcolor{rheadcolor}{\thepage}} % except the center
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
}

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

% Alias sectsty internals
\newcommand{\chapnumfont}{\SS@chapnumfont}     % use \chapternumberfont{} to change
\newcommand{\chaptitlefont}{\SS@chaptitlefont} % use \chaptertitlefont{} to change
\newcommand{\sectfont}{\SS@sectfont}           % use \sectionfont{} to change

% Use Open Sans (fos) instead of Charter BT (bch) as chapter and section title font
% fosj is Open Sans with old style figures.
% Note: \raggedright is used to prevent overfull hbox (make it OK to break line before entire line's hbox is filled).
\allsectionsfont{\rmfamily\upshape\bfseries\usefont{OT1}{fosj}{bx}{n}\selectfont}

% Change font for chapter number
\chapternumberfont{%
  \usefont{T1}{fos}{b}{n}%      % Use Open Sans (fos) as chapter number font
  \fontsize{56}{56}%            % font size 56pt, baselineskip 56pt
  \selectfont%                  % activate font
}

% Define how chapter number is drawn
\newcommand{\printchapternum}[1][1.0]{
  % Strutbox for numbers, to make sure that numbers are given correct vertical positions
  \newbox\ult@chapnummetabox%
  \setbox\ult@chapnummetabox\hbox{\Huge\bfseries\chapnumfont 0123456789}%
  \newbox\ult@chapnumbox%
  \setbox\ult@chapnumbox\hbox{%
    \vrule\@height\ht\ult@chapnummetabox
          \@depth\dp\ult@chapnummetabox
          \@width\z@%
  }%
  \begin{tikzpicture}[scale=#1, every node/.style={scale=#1}]
    %\tikzstyle{every rectangle node}=[draw]                                                             % Just for debugging, not used!
    %\draw[fill,color=red] (0,0) rectangle (3.15cm,3.15cm);                                              % Just for debugging, not used!
    \draw[fill,color=chapnumcol] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;                % Draw UiT "slash"
    \draw[color=black] (1.1,1.18) node[rectangle,anchor=west] { \Huge\bfseries\chapnumfont\unhcopy\ult@chapnumbox\thechapter }; % Draw chapter number
  \end{tikzpicture}
}

\newcommand{\printrheadslash}[1][]{
  \begin{tikzpicture}[scale=0.076]
    \draw[fill,color=rheadslashcolor] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;                % Draw UiT "slash"
  \end{tikzpicture}
}

% Align bottom of UiT slash with bottom of baseline
\newlength{\chapterheadalign}\setlength{\chapterheadalign}{\z@ + 8\baselineskip}

% Align chapter name
\newlength{\chapternamealign}\setlength{\chapternamealign}{\z@}

% Extra vertical spacing that is added by book.cls in addition to the default 50\p@ (I think it is \vspace* that does it)
% See https://groups.google.com/forum/#!topic/comp.text.tex/tIoCvZWpF7U
\newlength{\chapterheadtopvspace}\setlength{\chapterheadtopvspace}{\parskip + \baselineskip}

%%%%%%%%%%%%%%% THESE CAN BE CHANGED!!!!! %%%%%%%%%%%%%%%
\def\baselinesbeforefrontchaphead{8} % Approximate same distance as would be with standard 50\p@ vspace
\def\baselinesbeforemainchaphead{6} % Approximate same distance as would be with standard 50\p@ vspace
\def\baselinesafterchapnum{3}
\def\baselinesafterchaptitle{2}

\def\baselinesbeforesection{2}
\def\baselinesaftersection{0}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pretty size that spans two baselines. Height is approx. \baselineskip + \fontcharht\font`B
% baselineskip is set to 2.5 * parskip (baselineskip of normal font), so that every second
% line aligns to the baseline of the normal font.
\def\chaptitlefontsize {\fontsize{26}{2.5\parskip}}

% vbox used to measure chapter name height
\newbox\ult@chaptername@vbox

% Used for counting number of lines in chapter title
\newcounter{ult@chapter@tmpnumlines}

% Override \rightskip for \RaggedRight. This could be adjusted.
% See ftp://ftp.rz.uni-wuerzburg.de/pub/tex/latex2e/contrib/ms/ragged2e.pdf
\RaggedRightRightskip\z@\@plus1 fil

% Now, use our supahdupah chapter style! YEEEEEEAAAAHHHHHH!
\titleformat{\chapter}[display]
  {}% Format
  {\vspace*{\baselinesbeforemainchaphead\baselineskip} \vspace*{-\baselinesbeforefrontchaphead\baselineskip} \vspace*{\chapterheadalign} \printchapternum}% Label
  {\z@ - \parskip + \chapternamealign + \baselinesafterchapnum\baselineskip}% Vertical distance between chapter number and chapter title
  {% Before-code plus chapter name (titlesec's explicit option is enabled, so #1 is chapter name)
    % Make sure Chapter title aligns to baseline
    %
    \chaptitlefont\chaptitlefontsize
    %
    % Prevent overfull hbox
    \RaggedRight
    \selectfont
    %
    \vspace*{-\baselineskip}
    %
    % Measure number of text lines in chapter name
    \newdimen\ult@chapter@tmptotalheight
    \setbox0=\vbox{#1\relax \kern \z@ \strut}
    \ult@chapter@tmptotalheight=\ht0 \advance\ult@chapter@tmptotalheight by \dp0
    \setbox0=\vbox{Bq \kern \z@ \strut}
    \newdimen\ult@chapter@tmpstrutheight
    \ult@chapter@tmpstrutheight=\ht0 \advance\ult@chapter@tmpstrutheight by \dp0
    \setcounter{ult@chapter@tmpnumlines}{\DivideLengths{\ult@chapter@tmptotalheight}{\ult@chapter@tmpstrutheight}}
    %
    % Print chapter name
    #1% Important not to add spaces behind chapter name
  }%
  [% After-code
    % Make sure that normal text following chapter title aligns to baseline
    %
    % The titlesec package inserts something like
    %  \kern \z@ \strut \@@par \nobreak
    % before this.
    %
    % Note: this only works as long as \lineskiplimit=-\maxdimen. Without that, the solution is infinitely more complex.
    % For the old solution, see e.g. commit be2341c37a93c0af6f665bd3d4a0b445c310e1d2
    %
    % Note: we have confirmed that this is needed (try changing value of \parskip right before \@@par).
    % It's probably \@@par that inserts a \parskip. Also note that \parskip does not change when changing font size...
    \vspace*{-\parskip}
    %
    % Make sure total height + spacing corresponds to an even number of parskips (baselineskip for normal font)
    \ifodd\value{ult@chapter@tmpnumlines}\else
      \vspace*{0.5\parskip}% XXX: This value is hardcoded such that \baselineskip of \chaptitlefontsize + this value is an integer multiple of parskips
    \fi
    %
    % Now, switch to normal font
    \normalsize\normalfont\selectfont
    %
  ]

% Adjust spacing around chapter title
\titlespacing*{\chapter}
  {\z@}          % Left margin = 0
  {\z@ - \chapterheadtopvspace + \baselinesbeforefrontchaphead\baselineskip} % Vertical space before chapter head (50\p@ is standard from book.cls)
  {\z@ + \baselinesafterchaptitle\baselineskip}        % Vertical space after title, before text (\ttl@chapafter is default)


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
  {#1}% Before-code: print section name (needed because we have enabled titlesec's explicit option)
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
%\debugdef{ttls@chapter}

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
%\debugdef{ttlh@display}

% Macro for invoking \ttlh@display with arguments from \titleformat{\chapter}
%\debugdef{ttlf@chapter}

%:------------------------ Environments ----------------------
% Environment names
\newcommand{\abstractname}{Abstract}
\newcommand{\ackname}{Acknowledgements}

% Control-ifs
\newif\ifult@hasacknowledgement\ult@hasacknowledgementfalse
\newif\ifult@hasabstract\ult@hasabstractfalse
\newif\ifult@hasdedication\ult@hasdedicationfalse
\newif\ifult@hasepigraph\ult@hasepigraphfalse

% Abstract
\newenvironment{abstract}{%
  \ifult@hasacknowledgement%
    \@latex@warning{'\abstractname' should precede '\ackname'.}%
  \fi
  \global\ult@hasabstracttrue
  \chapter{\abstractname}
  \thispagestyle{empty}
}{}
% Acknowledgements
\newenvironment{acknowledge}{%
  \global\ult@hasacknowledgementtrue
  \chapter{\ackname}
  \thispagestyle{empty}
}{}
% Dedication
\newenvironment{dedication}{%
  \ifult@hasabstract%
    \@latex@warning{'Dedication' should precede '\abstractname'.}%
  \fi
  \ifult@hasacknowledgement%
    \@latex@warning{'Dedication' should precede '\ackname'.}%
  \fi
  \ifult@hasepigraph%
    \@latex@warning{'Dedication' should precede 'Epigraph'}%
  \fi
  \global\ult@hasdedicationtrue
  \cleardoublepage
  \phantomsection
  \chaptermark{}
  \thispagestyle{empty}
  \null
  \vfil
  \begingroup
  \center
  \fontsize{12pt}{14.4pt}\usefont{OT1}{bch}{m}{it}\selectfont
}{%
  \endcenter
  \endgroup
  \vfil
}
% Epigraph
\newcommand{\epigraphitem}[2]{%
  \ifdefined\@ult@epigraphenv%
    \item{``#1\relax''\\{--}#2\relax}%
  \else%
    \@latex@error{epigraph environment required for epigraphitem!}\@ehd%
  \fi
}
\newenvironment{epigraph}{%
  \ifult@hasacknowledgement%
    \@latex@warning{'Epigraph' should precede '\ackname'.}%
  \fi
  \ifult@hasabstract%
    \@latex@warning{'Epigraph' should precede '\abstractname'.}%
  \fi
  \ifult@hasdedication\else%
    \@latex@warning{'Epigraph' should succeed 'Dedication'.}%
  \fi
  \ifdefined\@ult@epigraphenv%
    \@latex@error{Nested epigraphs are not allowed!}\@ehd%
  \fi
  \global\ult@hasepigraphtrue
  \def\@ult@epigraphenv{}
  \clearpage\thispagestyle{empty}
  \null\vfill
  \begin{flushright}%
}{%
  \end{flushright}%
  \vspace*{2\baselineskip}
}

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

% Override \printglossary to prevent blank page from being inserted
% when acronym/glossary list is empty.
%
% The problem is that an "empty" auxillary file for a glossary list
% will contain "\null" as its file contents. The \null command is the
% same as \hbox{}, and will flush a new page if called after a
% \clearpage or \cleardoublepage, which is *extremely* undesirable.
%
% The following hack exploits the fact that \printglossary uses the
% \@input@ command to output the contents of the auxillary file for
% the glossary list. So we re-define \@input@ temporarily to use
% LaTeX magic to read the entire file contents into a command
% \ult@read@buf, and test if the file contents are strictly equal to
% \null. If so, we simply ignore the \@input@, else we call the
% normal \@input@ command (that we have saved first). Then, when
% \printglossary calls \@input@, it will actually call our overridden
% command, and make sure we don't output anything if the file only
% contains \null. Finally, we restore the original \@input@ command
% so it can be used later.
%
% Note: Must use \LetLtxMacro because \printglossary is complex with
% default value for parameter.
% See: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=patch
%
% Also note: I tried to use a normal LaTeX \read-loop with scantokens,
% but did not succeed, so I ended up using the 'catchfile' package,
% which seems to get the job done!
\LetLtxMacro{\ult@saveprintglossary}{\printglossary}
\renewcommand{\printglossary}[1][type=\glsdefaulttype]{%
  % Override \@input@ that is used by \printglossary
  \let\ult@save@input@\@input@
  \renewcommand\@input@[1]{%
    \IfFileExists{##1}{%
      % See http://tex.stackexchange.com/questions/14145/how-do-i-create-a-macro-which-reads-the-content-of-a-file-when-the-macro-is-defi
      \CatchFileDef{\ult@read@buf}% Macro we dump file contents into
                   {##1}% File name
                   {\makeatletter\endlinechar=-1\relax}% Scancode magic
      
      % If file contents is equal to \null, then ignore...
      % This will prevent an additional blank page being inserted,
      % since we suppress the \null from being output.
      \expandafter\ifx\ult@read@buf\null\else
        % Call on saved \@input@ command
        \ult@save@input@{##1}
      \fi%
    }{}% Don't output anything if file does not exist!
  }%
  %
  % Now, that we have overridden \@input@, call saved \printglossary
  \ult@saveprintglossary[#1]%
  %
  % Finally, restore \@input@ so we don't fuck up for other stuff
  \let\@input@\ult@save@input@
}

% Make sure \printacronyms has effect at most once!
\AtBeginDocument{%
  \ifglsacronym
    \ult@once{\printacronyms}
  \fi%
}

% Prevent \printglossaries, since we have acronyms in frontmatter and glossary in back matter
\renewcommand*{\printglossaries}{%
  \@latex@warning{Call to \@backslashchar printglossaries was ignored.}%
}


%:-------------------------- Book class overrides -----------------------

% Frontmatter
\let\ult@savefrontmatter\frontmatter
\renewcommand\frontmatter{%
  \ult@savefrontmatter

  % Redefine what is in \chaptermark so that \leftmark contains chapter name. Thus "Abstract" and "Acknowledgements" will be written in header
  \renewcommand{\chaptermark}[1]{%
    % Note: we use two number signs (#) because we have renewcommand within renewcommand
    \markboth{##1}% % \leftmark (will be written to the right on even/verso pages and to the left on odd/recto pages) is set to chapter title after start of new chapters
             {}%    % \rightmark is cleared after start of new chapters, and will be replaced after start of new section
    }

  % Set \leftmark to the left on odd pages
  % This will make sure that chapter title is written in front matter where section title is normally written in main matter,
  % that is, to the left on odd/recto pages (in addition to the right on even/verso pages, where it is already written)
  \fancyhead[LO]{\rheadfont\textcolor{rheadcolor}{\nouppercase{\leftmark}}}

  % Make sure that abbreviations are not expanded
  \glsunsetall
}

% Table of Contents
\let\ult@savetableofcontents\tableofcontents
\renewcommand\tableofcontents{%
  % Call original \tableofcontents
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

  \printacronyms
}

% Mainmatter
\let\ult@savemainmatter\mainmatter
\renewcommand\mainmatter{%
  \ult@savemainmatter
  
  % Redefine \chaptermark, so it contains chapter number in front of chapter name (e.g. "2 My Chapers Name")
  % Note that we do not use \@chapapp (contains "chapter type"), because we do not want to write "Chapter" before the chapter number.
  \renewcommand{\chaptermark}[1]{%
    % Note: we use two number signs (#) because we have renewcommand within renewcommand
    \markboth{\@chapapp\ \thechapter\ \printrheadslash\ ##1}% % \leftmark (will be written to the right on even/verso pages) is set to chapter title after start of new chapters
             {}%                 % \rightmark is cleared after start of new chapters, and will be replaced after start of new section
  }
  
  % Set odd pages to have have \rightmark instead of \leftmark
  % This will make sure that section title is written to the left in running headers on odd (recto) pages
  \fancyhead[LO]{\rheadfont\textcolor{rheadcolor}{\nouppercase{\rightmark}}}
  
  % Reset glossaries so every abbreviation will expand on first use
  \glsresetall
}

% Backmatter
\let\ult@savebackmatter\backmatter
\renewcommand\backmatter{%
  \ult@savebackmatter
  
  % Redefine headers for appendices
  \pagestyle{empty}
  
  \printglossary
  
  % Blank back cover
  \clearversopage
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
