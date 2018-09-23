\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{uit-thesis}[2014/16/02 v0.1a UiT thesis class]


%:----------------- INFO, WARNING, ERROR -----------------

\newcommand\ult@info[1]{%
  \ClassInfo{uit-thesis}{#1}%
}

\newcommand\ult@warning[1]{%
  \ClassWarning{uit-thesis}{#1}%
}

\newcommand\ult@warning@nl[1]{%
  \ClassWarningNoLine{uit-thesis}{#1}%
}

\newcommand\ult@critical@error[1]{%
  \ClassError{uit-thesis}{#1}{\@ehd}%
}


%:-------------------------- DEBUG -----------------------

% Used to halt LaTeX compilation
\def\debughalt#1{%
  \PackageError{uit-thesis}{DEBUG}{#1}}

% Used to output definition of a LaTeX macro in console
\def\debugdef#1{%
  \typeout{[DEBUG] Definition of \@backslashchar #1: \expandafter\meaning\csname#1\endcsname ^^J ^^J}}


%:-------------------------- Early includes and checks -----------------------

% e-Tex tools, macros, hooks, etc.
\RequirePackage{etex}
\RequirePackage{etoolbox}

% Used to provide \ifpdf macro
\RequirePackage{ifpdf}

\ifpdf\else
  \ult@critical@error{The uit-thesis template only supports compiling with pdflatex}
\fi


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

% Class options for thesis type (master thesis default)
\DeclareOption{master}{}
\newif\ifult@phdthesisprofile
\ult@phdthesisprofilefalse % Default to false
\DeclareOption{phd}{\ult@phdthesisprofiletrue}

% Suppress book class options
\DeclareOption{a5paper}{}
\DeclareOption{b5paper}{}
\DeclareOption{letterpaper}{}
\DeclareOption{legalpaper}{}
\DeclareOption{executivepaper}{}
\DeclareOption{landscape}{}
\DeclareOption{openany}{}
\DeclareOption{twocolumn}{}

% Option for drawing baseline grid
\newif\ifult@drawbaselinegrid
\ult@drawbaselinegridfalse % Default to false
\DeclareOption{baselinegrid}{\ult@drawbaselinegridtrue}

\newif\ifult@copyright@disabled
\ult@copyright@disabledfalse % Default to false
\DeclareOption{nocopyright}{\ult@copyright@disabledtrue}

% Option for using indented paragraphs instead of vertical skip between paragraphs
\newif\ifult@parindent
\ult@parindentfalse % Default to false
\DeclareOption{parindent}{\ult@parindenttrue}

% Option for resetting expansion of acronyms at start of each chapter
\newif\ifult@resetallglsperchapter
\ult@resetallglsperchapterfalse % Default to false
\DeclareOption{glsresetperchapter}{\ult@resetallglsperchaptertrue}

% Option for ignoring drawing of List of Figures
\newif\ifult@printlistoffigures
\ult@printlistoffigurestrue % Default to true
\DeclareOption{notlof}{\ult@printlistoffiguresfalse}

% Option for ignoring drawing of List of Tables
\newif\ifult@printlistoftables
\ult@printlistoftablestrue % Default to true
\DeclareOption{notlot}{\ult@printlistoftablesfalse}

% Extra options for glossaries package
\newcommand*{\ult@glossariesextraoptions}{,}
\DeclareOption{xindy}{\gappto\ult@glossariesextraoptions{xindy,}}

% Detect if USenglish is specified in the class options
\newif\ifult@specified@english
\ult@specified@englishfalse
\DeclareOption{USenglish}{\ult@specified@englishtrue}

% Now, process!
\ProcessOptions\relax
\LoadClass{\baseclass}

% Fix compatibility issues. A4 dimensions hard coded.
\special{papersize=210mm,297mm}

% Inject USenglish in front of class options if it was not specified in the list.
% If any other language is specified in the list, it will take precedence
% We only inject if its was not specified, since every option is only processed once.
\ifult@specified@english\else
\preto\@classoptionslist{USenglish,}
\fi


%:-------------------------- Require packages -----------------------

% Used to suppress certain package warnings
\RequirePackage[safe]{silence}

\WarningFilter*{microtype}{You are using the `ragged2e' package}
\WarningFilter*{fixltx2e}{fixltx2e is not required with releases after 2015}

% Allow UTF-8 characters in .tex source files (e.g. so we don't have to escape Norwegian characters)
\RequirePackage[utf8]{inputenc}

% Support text copy and text search in LaTex pdf documents with ligatures (e.g. ff, fi, ...)
\RequirePackage[resetfonts]{cmap}

% Correct font encoding / language support in output (hyphenations, etc.)
\RequirePackage[T1]{fontenc}

% American patterns
\RequirePackage[english=usenglishmax]{hyphsubst}
\RequirePackage{babel}

% To modify the heading styles more thoroughly use the titlesec package
\RequirePackage[explicit]{titlesec}
\RequirePackage{sectsty}

% Scalable Computer Modern font support
\RequirePackage{lmodern}
\RequirePackage{type1cm}

% Support for subscript and superscript using \textsuperscript{} and \textsubscript{}
\RequirePackage{fixltx2e}

% Better support fraction calculations
\RequirePackage{xintexpr}


%:-------------------------- LaTeX control flow macros -----------------------

% Used to provide if-then-else macros
\usepackage{ifthen}

% Allow calculations in \vspace*
\usepackage{calc}

% Used to calculate ratio between two dimension commands
\newcommand*{\DivideLengths}[2]{%
  \xintthe\xintiexpr #1/#2\relax
}

% Used to prevent given LaTeX macro from being called more than once
\newcommand\ult@once[1]{%
  % Save original macro
  \expandafter\let\csname ult@once@save\expandafter\@gobble\string#1\endcsname#1\relax
  %
  % DEBUG
  %\typeout{DEBUG \expandafter\meaning\csname ult@once@savelistoffigures\endcsname}
  %\debughalt{}
  %
  % Re-define macro
  \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
    % Invoke original macro
    \csname ult@once@save\expandafter\@gobble\string#1\endcsname
    % Re-define macro
    \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
      % Warn on second usage
      \ult@warning{Call to \@backslashchar\expandafter\@gobble\string#1\space was ignored, because it was called previously}%
      % Re-define macro
      \expandafter\renewcommand\csname\expandafter\@gobble\string#1\endcsname{%
        % Error on third usage
        \ult@critical@error{Duplicate call to \@backslashchar\expandafter\@gobble\string#1}%
      }%
    }%
  }%
}

% Used to prevent package from being loaded.
% Macro is used as \ult@disallowpackage{packagename} or \ult@disallowpackage[Reason for disallowing package]{packagename}.
\newcommand\ult@disallowpackage[2][\@empty]{%
  \expandafter\edef\csname ult@disallowpackage@#2\endcsname{#1}%
  \AtBeginDocument{%
    \@ifpackageloaded{#2}{%
      \ult@critical@error{Package #2 has been loaded even if it was disallowed}%
    }{}%
  }%
}

% Disallowed packages
\ult@disallowpackage[Pacakge notoccite should not be loaded. The uit-thesis template already integrates the changes from notoccite.]{notoccite}
\ult@disallowpackage[Package subfigure is deprecated. The subcaption package (already included by the document class) is used instead.]{subfigure}
\ult@disallowpackage[Package subfig is incompatible with the uit-thesis document class. The subcaption package (already included) is used instead.]{subfig}
\ult@disallowpackage[Package easyeqn is incompatible with hyperref.]{easyeqn}
\ult@disallowpackage[Package mathenv is incompatible with hyperref.]{mathenv}
\ult@disallowpackage[Package pstcol is not allowed. The uit-thesis document class uses the xcolor package instead.]{pstcol}
\ult@disallowpackage[The uit-thesis document class already provides beautiful chapter headings. Why would you want to change them?]{fncychap}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{tocbasic}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{tocstyle}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{typearea}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{titlepage}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrpage}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrpage2}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrdate}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrtime}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scraddr}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrextend}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrbase}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrlfile}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrwfile}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrhack}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrlayer}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrlayer-scrpage}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrlayer-notecolumn}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrjura}
\ult@disallowpackage[The uit-thesis document class is not compatible with KOMA-Script.]{scrlogo}
\ult@disallowpackage[The uit-thesis document class uses the float package, which isn't compatible with floatrow.]{floatrow}


%:-------------------------- Colors -----------------------

% Text coloring, table colors, etc.
% Note: the xcolor package will pretend that the color package has been loaded, to prevent the color package
% from being loaded as well. Same goes for the colortbl package.
\usepackage[dvipsnames,table,hyperref]{xcolor}

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
\ifult@phdthesisprofile
  \definecolor{rheadcolor}{cmyk}{0.15,0,0,0.8}
  \colorlet{chapnumcol}{pms1797}
\else
  \definecolor{rheadcolor}{cmyk}{0.15,0,0,0.8}
  \definecolor{chapnumcol}{cmyk}{0.77,0.09,0.32,0}
\fi


%:-------------------------- URLs -----------------------

% Nicely formatted URLs
% Retain spaces in URLs, and allow line break at hyphens
\usepackage[obeyspaces,hyphens]{url}

% Define a new 'leo' style for the package that will use a smaller font.
% http://www.kronto.org/thesis/tips/url-formatting.html
\def\url@leostyle{%
  \@ifundefined{selectfont}{\def\UrlFont{\sf}}{\def\UrlFont{\small\ttfamily}}%
}
% Now actually use the newly defined style.
\urlstyle{leo}


%:-------------------------- Things we need to do magic -----------------------

% Needed by our black magic hacks below
\usepackage{xparse}
\usepackage{atbegshi}

% To read LaTeX macro from file
\usepackage{catchfile}

% Convenient
\usepackage{expl3}
\usepackage{xstring}

% Allows us to do hardcore patching
\usepackage{xpatch}


%:-------------------------- Floats -----------------------

\usepackage{ult-rename}

% Floats (should be loaded before hyperref)
\usepackage{float}

% Note: we load newfloat package before we override \@chapter, because
% newfloat tries really hard to override it, and we don't really want it to.
% Now, it should patch the default \@chapter command of the book class.
% If newfloat was included after we have patched \@chapter, then it would
% patch \addtocontents instead.
% See http://mirrors.ctan.org/macros/latex/contrib/caption/newfloat.pdf
\usepackage{newfloat}

\xapptocmd{\floatname}{%
  \renamedefname{#1}{\@nameuse{fname@#1}}
  \renameautorefname{#1}{\@nameuse{fname@#1}}
}
{}
{\ult@critical@error{Failed to patch \@backslashchar floatname}}


%:-------------------------- Book class overrides -----------------------

% Override \@chapter to get a consistent look of all ToC lists
\def\@chapter[#1]#2{%
  \ifnum \c@secnumdepth >\m@ne
    \if@mainmatter
      \refstepcounter{chapter}%
      \typeout{\@chapapp\space\thechapter.}%
      \addcontentsline{toc}{chapter}%
                {\protect\numberline{\thechapter}#1}%
    \else
      \addcontentsline{toc}{chapter}{#1}%
    \fi
  \else
    \addcontentsline{toc}{chapter}{#1}%
  \fi
  \chaptermark{#1}%
  %\addtocontents{lof}{\protect\addvspace{10\p@}}%
  %\addtocontents{lot}{\protect\addvspace{10\p@}}%
  %
  % Add space between entries belonging to different
  % chapters in ToC lists
  \ult@foralltoclists{\ult@this@toclist@ext}{%
    \addtocontents{\ult@this@toclist@ext}%
                  {\protect\addvspace{\ult@cftbeforechapskip}}%
  }%
  \@makechapterhead{#2}%
  \@afterheading
}


%:-------------------------- Footnotes ----------------------------

\usepackage[norule,%    % Drop the small rule before footnotes
            splitrule,% % If a footnote is split, draw a full width rule above the continued part of the footnote as a visual cue to readers
            bottom%     % Make sure footnotes are pushed to the bottom of the page (instead of being placed after the actual page break)
           ]{footmisc}

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
\def\hangfootparindent{2.5em}

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

\usepackage[pdftex,%                       %
            plainpages=false,%             % "Physical" page numbers and logical page numbers are not the same
            pdfpagelabels=false,%          % Don't index pages using logical page numbers in PDF reader (such as ii, iii, iv, ...)
            pdfpagemode={UseOutlines},%    % Show bookmarks
            pdfstartview={FitV},%          % Fit height of page to PDF viewer window
            pdfpagelayout={TwoPageRight},% % Display two pages, odd-numbered pages to the right
            pdfdisplaydoctitle,%           % Display document title instead of filename in title bar
            bookmarks,%                    % Show bookmarks bar when displaying document
            pagebackref=false,%            % No back references inside bibilography.
            hyperindex,%                   %
            hyperfigures%                  %
           ]{hyperref}

% Used for adding figures in thesis
\usepackage[pdftex]{graphicx}

% Make it easy to include PDFs using \includepdf macro. Note that PDF links will be lost when including!
\usepackage{pdfpages}

% Correct a problem with hyperref
\usepackage[all]{hypcap}

\hypersetup{%
  bookmarksopen=true,
  bookmarksnumbered=true,
  breaklinks=true,
  linktocpage,
  colorlinks=false,% Should never be set to true, as it reduces quality of print...
  linkcolor=blue,
  urlcolor=blue,
  citecolor=red,
  anchorcolor=green,
  hidelinks, % Remove color and border
  unicode=true, % Enforce unicode encoding in bookmarks, which is required for samin language to interoperate with hyperref
}

\usepackage{ult-autoref}

% Small, hanging indentation with bold label.
% hypcap option is used to make sure that hyperlink to
% e.g. figure points to the top of the figure rather than
% to the caption.
\usepackage[hang,bf,small,hypcap]{caption}

% Enables adding figures and tables side by side
\usepackage{subcaption}

% For sweet-ass drawings and transformations and shit
\usepackage{tikz}
\usepackage[skins]{tcolorbox}
\usepackage{picture}
\usepackage{eso-pic}


%:-------------------------- References -----------------------

% For some reason, hyperref has let some reference names have first capital letter, whereas others do not.
% Make sure all default reference names use first capital letter.
\renameautorefname[USenglish]{section}{Section}
\renameautorefname[USenglish]{footnote}{Footnote}
\renameautorefname[USenglish]{item}{Item}
\renameautorefname[USenglish]{chapter}{Chapter}
\renameautorefname[USenglish]{subsection}{Subsection}
\renameautorefname[USenglish]{paragraph}{Paragraph}
\renameautorefname[USenglish]{subparagraph}{Subparagraph}
\renameautorefname[USenglish]{FancyVerbLine}{Line}
\renameautorefname[USenglish]{page}{Page}
\renameautorefname[USenglish]{part}{Part}
\renameautorefname[USenglish]{appendix}{Appendix}

% Set autoref definitions for norsk language - none of these are set.
\renameautorefname[norsk]{section}{seksjon}
\renameautorefname[norsk]{footnote}{fotnote}
\renameautorefname[norsk]{item}{element}
\renameautorefname[norsk]{chapter}{kapittel}
\renameautorefname[norsk]{subsection}{underseksjon}
\renameautorefname[norsk]{paragraph}{avsnitt}
\renameautorefname[norsk]{subparagraph}{underavsnitt}
\renameautorefname[norsk]{FancyVerbLine}{Line}
\renameautorefname[norsk]{page}{side}
\renameautorefname[norsk]{equation}{formel}
\renameautorefname[norsk]{table}{tabell}
\renameautorefname[norsk]{figure}{figur}
\renameautorefname[norsk]{lstlisting}{listing}
\renameautorefname[norsk]{part}{del}
\renameautorefname[norsk]{appendix}{tillegg}


%:-------------------------- Title and subtitle  -----------------------

% Override \title to update pdftitle
\let\ult@savetitle\title
\def\title#1{%
  \ult@savetitle{#1}%
  \hypersetup{pdftitle={#1}}%
}

% Used to hold author name as string
\global\let\ult@author\@empty

% Make sure we get an error if using \maketitle without specifying \author{}, not just warning...
\def\@author{\ult@critical@error{No \noexpand\author given}}

% Override \author to update pdfauthor
\let\ult@saveauthor\author
\def\author#1{%
  \gdef\ult@author{#1}%
  \ult@saveauthor{#1}%
  \hypersetup{pdfauthor={#1}}%
}

% Add macro for subtitle
\def\subtitle#1{\gdef\@subtitle{#1}}


%:-------------------------- Fonts -----------------------

\usepackage{opensans}

% Dependencies of XCharter
\usepackage{textcomp}
\usepackage{mweights}
\usepackage{fontaxes}
\usepackage{xkeyval}

% XCharter
\usepackage[scaled=.98,sups]{XCharter}% lining figures in math

% Save font family for XCharter with lining figures
\global\let\ult@fontfamilylfstyle\@empty
\begingroup
\lfstyle
\global\let\ult@fontfamilylfstyle\f@family\relax
\endgroup

% Save font family for XCharter with old style figures
\global\let\ult@fontfamilyosfstyle\@empty
\begingroup
\osfstyle
\global\let\ult@fontfamilyosfstyle\f@family\relax
\endgroup

\newcommand{\ult@setlfstyledefault}{%
  \renewcommand*{\rmdefault}{\ult@fontfamilylfstyle}%
  \normalfont
}

\newcommand{\ult@setosfstyledefault}{%
  \renewcommand*{\rmdefault}{\ult@fontfamilyosfstyle}%
  \normalfont
}

% In his Elements of Typographic Style, Robert Bringhurst recommends that you use the
% same amount of space after an end-of-sentence fullstop as there is between words.
% See http://tex.stackexchange.com/questions/26996/implementing-a-sort-of-tightened-frenchspacing
\frenchspacing

% The csquotes package provides convenient macros for typesetting various kinds of quotations.
\usepackage{csquotes}

\usepackage[activate={true,nocompatibility},final,kerning=true,spacing=true,factor=1100,stretch=10,shrink=10]{microtype}

% this is necessary so that smallcapped italics & bolds also get spaced
\DeclareMicrotypeSet{ultsmallcaps}
   { encoding = {OT1,T1,T2A,LY1,OT4,QX,T5,TS1,EU1,EU2},
     shape    = {sc,si,scit}
   }
\microtypesetup{tracking=ultsmallcaps}

% the default tracking is kind of huge, this sets tracking to 5.5% of an em
\SetTracking{encoding = *, shape = {sc,si,scit}}{55}

\newif\ifult@microtypeloaded
\AtBeginDocument{%
  \@ifpackageloaded{microtype}%
  {%
    \global\ult@microtypeloadedtrue
  }%
  {%
    \global\ult@microtypeloadedfalse
    \global\newif\ifMT@protrusion
    \global\MT@protrusionfalse
  }%
}

% Allows us to scale font sizes relatively
\usepackage{scalefnt}


%:-------------------------- Listings, tables, etc.  -----------------------

% Listings (e.g. used for code examples)
\usepackage{listings}

% Don't use old style numbers for line numbers or in listing content
\lst@AddToHookAtTop{Init}{\ult@setlfstyledefault}

\usepackage{ult-custom-listings}

% Pretty tables
\usepackage{booktabs}
\usepackage{tabularx}


%:-------------------------- Symbols -----------------------

\usepackage{xspace}

\usepackage{amsmath}
\usepackage{amsthm}

\usepackage[libertine,bigdelims,scaled=1.07]{newtxmath}

% Use oldstyle figures in text
% Note: we have to do this manually instead of using XCharter's \useosf command, since last version of XCharter breaks \useosf
\edef\XCharter@figurestyle{TOsF}\edef\XCharter@altone{1}
\AtEndPreamble{%
  % Note: we use \XCharter@figurestyle here instead of TOsF to allow user to
  % override default figure style in preamble!
  \renewcommand*{\rmdefault}{XCharter-\XCharter@figurestyle}%
  \normalfont
}


%:-------------------------- Page layout -----------------------

\newlength\ult@gm@topmargin
\setlength\ult@gm@topmargin\topmargin

\newlength\ult@gm@textheight
\setlength\ult@gm@textheight\textheight

\newlength\ult@gm@textwidth
\setlength\ult@gm@textwidth\textwidth

\newlength\ult@gm@headheight
\setlength\ult@gm@headheight\headheight

% Geometry is needed to set frontpage layout
% Enable option 'showframe' for debugging...
\usepackage[a4paper,ignorehead,ignorefoot,twoside,top=\the\topmargin,textheight=\the\textheight,textwidth=\the\textwidth]{geometry}

% Calculate differences between geometry dimensions and LaTeX dimensions
\addtolength\ult@gm@topmargin{\ult@gm@topmargin}
\addtolength\ult@gm@topmargin{-\topmargin}

\addtolength\ult@gm@textheight{\ult@gm@textheight}
\addtolength\ult@gm@textheight{-\textheight}

\addtolength\ult@gm@textwidth{\ult@gm@textwidth}
\addtolength\ult@gm@textwidth{-\the\textwidth}

% Update geometry to preserve book class' dimensions
\geometry{top=\the\ult@gm@topmargin,textheight=\the\ult@gm@textheight,textwidth=\the\ult@gm@textwidth}

% Make sure width of running heads is updated when geometry is changed
\gappto\Gm@process{\f@nch@setoffs}
\gappto\Gm@changelayout{\f@nch@setoffs}

% Used to modify layout
\usepackage{layout}

% Used to give adjustwidth environment
\usepackage{changepage}

%A4 settings
\pdfpageheight=297mm
\pdfpagewidth=210mm

% Get value of baselineskip of normal-sized font in \ult@normalbaselineskip
\newdimen\ult@normalbaselineskip
\begingroup
\normalsize
\global\ult@normalbaselineskip=\baselineskip
\endgroup

% Save \parindent for current font size
\newlength\ult@saveparindent
\setlength{\ult@saveparindent}{\parindent}

% Begin paragraphs with an empty line rather than an indent
% Note: we use package parskip even if uit-thesis class is loaded with class option 'parindent',
% just to make sure that the parskip package cannot be loaded later and fuck up our layout!
\usepackage[parfill]{parskip}[=v1]

\ifult@parindent
  % Restore the default \parindent
  \setlength{\parindent}{\ult@saveparindent}

  % No skip between paragraphs when using indentation
  \setlength{\parskip}{\z@}
\else
  % Set indent at new paragraph to 0
  \setlength{\parindent}{\z@}

  % Set paragraph skip length to two lines
  % Note: this reads the current value of \baselineskip for the normal font and font size, and stores it in parskip.
  % Changing \baselineskip later will NOT change \parskip
  \setlength{\parskip}{\ult@normalbaselineskip}
\fi

\linespread{1.0}

% Strict linespacing, don't allow LaTeX to put extra spacing between lines
\lineskip=\z@

% Note: this breaks tables, figures, and probably other environments too if set < \z@.
\lineskiplimit=\z@

\renewcommand{\baselinestretch}{1.0}\normalsize

% Spacing for \item lists
% \topsep is vertical spacing before first item
% \parsep is spacing between items
% \itemsep = \z@ <=> add nothing to \parsep between items
\def\@listI{%
  \leftmargin\leftmargini
  \topsep\ult@normalbaselineskip
  \advance\topsep by -\parskip
  \parsep\parskip
  \listparindent\parindent
  \itemsep\z@
}
\let\@listi\@listI
\@listi

% BASELINE GRID
% http://tex.stackexchange.com/questions/150619/drawing-a-background-grid-based-on-linespread-value
\ifult@drawbaselinegrid
\AtBeginShipout{%
  \AtBeginShipoutUpperLeft{%
    \color{red}%
    \ifodd\c@page
      \put(\dimexpr 1in+\oddsidemargin,
           -\dimexpr 1in+\topmargin+\headheight+\headsep+\topskip)%
        {%
          \vtop to\dimexpr\vsize+\ult@normalbaselineskip{%
            \hrule
            \leaders\vbox to\ult@normalbaselineskip{\hrule width\hsize\vfill}\vfill
          }%
        }%
    \else
      \put(\dimexpr 1in+\evensidemargin,
           -\dimexpr 1in+\topmargin+\headheight+\headsep+\topskip)%
        {%
          \vtop to\dimexpr\vsize+\ult@normalbaselineskip{%
            \hrule
            \leaders\vbox to\ult@normalbaselineskip{\hrule width\hsize\vfill}\vfill
          }%
        }%
    \fi
  }%
}
\fi

% For \RaggedRight macro, which is better than \raggedright
\usepackage{ragged2e}


%:-------------------------- Table of Contents (TOC), bibliography, etc. -----------------------

% ToC support for list of figures, list of tables, bibliography, index, etc.
\usepackage[nottoc%     % No entry for ToC in ToC
           ]{tocbibind}

% Styling of actual Table of Contents
\usepackage[titles%     % Retain chapter headers
           ]{tocloft}

\newif\ifult@first@contentsline
\global\ult@first@contentslinefalse

\let\ult@save@contentsline\contentsline
\renewcommand*{\contentsline}[4]{%
  \ult@save@contentsline{#1}{#2}{#3}{#4}%
  \global\ult@first@contentslinefalse
}

% Citation numbering not starting on table of contents
% Note: we do not use notoccite package, since it overwrites changes that
% parskip does to \@starttoc
\renewcommand*{\@starttoc}[1]{%
  % First element in ToC will be a chapter. Compensate for vertical space
  % added by tocloft, so the first element isn't pushed down.
  % Also, elements in ToC lists that belong to different chapters are separated
  % with spacing, and this spacing will be present before the very first element.
  % Hence, we compensate for both these cases...
  \vspace*{-\ult@cftbeforechapskip}%
  %
  % Make sure spacing is the same with class option 'parindent' and without
  \vspace*{\parskip}%
  %
  \begingroup
    % Disable protrusion locally
    \microtypesetup{protrusion=false}%
    %
    % Add modification from notoccite.
    % Note: this only has effect within the current local group
    % (which is why it works!)
    \@fileswfalse
    %
    % Make sure @ have right catcode before reading input file
    \makeatletter
    %
    % Retain modification from parskip.
    % Note: this is only consistent because we compensate with \vspace*{\parskip} above
    \parskip\z@
    %
    \global\ult@first@contentslinetrue
    %
    % Read auxillary file
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

\usepackage{ult-clearpage}

% Define pagestyle
\pagestyle{fancy}

% Reset all header settings
\fancyhf{}

% strips the crazy head rule
\let\headrule\@empty

% fosj is opensans with old style figures
\newcommand{\rheadfont}{\fontsize{10pt}{12pt}\usefont{T1}{fosj}{l}{n}}
\newcommand{\rheadfmt}[1]{\textsc{\MakeLowercase{#1}}}

% Set pagenumber in the header.
% RO = Right Odd: Page number is set to the right in the header on odd pages
% LE = Left Even: Page number is set to the left in the header on even pages
\fancyhead[RO,LE]{\rheadfont\textcolor{rheadcolor}{\thepage}}

% Set \leftmark to show to the right in header on even pages.
% This will make sure that chapter title is written to the right on even/verso pages
\fancyhead[RE]{\rheadfont\textcolor{rheadcolor}{\leftmark}}

% Redefine what is in \sectionmark so that \rightmark contains section number and section name (e.g. "2.1 My Sections Name")
\renewcommand{\sectionmark}[1]{%
  \markright{\rheadfmt{\thesection}\hspace{5pt}\printrheadslash\hspace{5pt}\rheadfmt{#1}}% \leftmark (right even) is set to section number + title after start of new section
}

% Redefine "chapter mark" for Toc lists (\tocetcmark command is originally defined in tocbibind...)
% Note: this also applies to running heads for ToC itself, due to the use of \prw@mkboth in our definition later.
\renewcommand{\tocetcmark}[1]{%
  \markboth{\rheadfmt{#1}}% \leftmark
           {\rheadfmt{#1}}% \rightmark
}

% Redefine "plain" pagestyle (used on first page of each chapter)
\fancypagestyle{plain}{%
  \fancyhf{}% clear all header and footer fields
  \fancyfoot[C]{\rheadfont \textcolor{rheadcolor}{\thepage}}% except the center
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}

% Fix head height
\setlength{\headheight}{15pt}


%:-------------------------- Black magic hacks -----------------------

\usepackage{ult-upsc}

\DeclareRobustCommand{\ult@upsc@fntsetup}{%
  \scalefont{1.12}%
  \microtypesetup{tracking=false}% Disable tracking to reduce letterspacing for acronyms and similar
}

\LetLtxMacro{\ult@upsc}{\upsc}
\renewcommand{\upsc}[1]{%
  \begingroup
    \ult@upsc@fntsetup
    \ult@upsc{#1}%
  \endgroup
}


%:-------------------------- Glossaries -----------------------

% Used for abreviations and list of abreviations
% Translate=false because package 'babel' reverts renaming of the default glossary-/acronymnames
\usepackage[toc,acronym,shortcuts,nonumberlist,nopostdot,translate=false,\ult@glossariesextraoptions]{glossaries}
\usepackage{ult-glossaries}

% Apply custom smallcaps glossaries style
\setacronymstyle{ult-long-upsc-short}

\newglossarystyle{ult-list}{%
  % base it on the list style
  \setglossarystyle{list}%
  %
  \renewenvironment{theglossary}{%
    \begin{adjustwidth}{\cftfigindent}{}% Left align with same indent as LoF
    \begin{description}%
  }{%
    \end{description}%
    \end{adjustwidth}%
  }%
  \renewcommand*{\glsnamefont}[1]{\upsc{##1}}%
}

% Better "long" style (consistent spacing, prevent running headers on empty page)
\newglossarystyle{ult-long}{%
  % base it on the long style
  \setglossarystyle{long}%
  \renewenvironment{theglossary}{%
    % Remove vspace before and after table (note: these are only modified locally)
    \setlength{\LTpre}{0pt}\setlength{\LTpost}{0pt}%
    \setlength\LTleft{\cftfigindent}% Left align with same indent as LoF
    \leavevmode% Make sure table isn't ouput one line before it should
    % Note: {longtable*} is unnumbered, so table-counter isn't increased!
    \begin{longtable*}{@{}l p{\glsdescwidth}}%
  }{%
    \end{longtable*}%
  }%
  \renewcommand*{\glsnamefont}[1]{\textbf{\upsc{##1}}}%
}

\AtBeginDocument{%
  \renewcommand*{\printacronyms}[1][]{%
    \printglossary[type=\acronymtype,style=ult-list,#1]%
  }%
}

% Prevent grouping together abbreviations starting on same letter in list of
% abbreviations.
% See http://tex.stackexchange.com/questions/4183/package-glossaries-single-spaced-printglossaries
\glsnogroupskiptrue
\renewcommand*{\glsgroupskip}{}

% Make sure running heads of glossaries are output consistently with other ToC lists (using smallcaps)
\renewcommand{\glossarymark}[1]{\prw@mkboth{#1}}


%:-------------------------- Chapter and section style -----------------------

% Alias sectsty internals
\newcommand{\chapnumfont}{\SS@chapnumfont}       % use \chapternumberfont{} to change
\newcommand{\chaptitlefont}{\SS@chaptitlefont}   % use \chaptertitlefont{} to change
\newcommand{\sectfont}{\SS@sectfont}             % use \sectionfont{} to change
\newcommand{\subsectfont}{\SS@subsectfont}       % use \subsectionfont{} to change
\newcommand{\subsubsectfont}{\SS@subsubsectfont} % use \subsubsectionfont{} to change
\newcommand{\parafont}{\SS@parafont}             % use \paragraphfont{} to change

% Use Open Sans (fos) as chapter and section title font
% fosj is Open Sans with old style figures.
\allsectionsfont{\usefont{T1}{fosj}{bx}{n}}

% Change font for chapter number
\chapternumberfont{%
  \fontsize{56}{56}%            % font size 56pt, baselineskip 56pt
  \usefont{T1}{fos}{b}{n}%      % Use Open Sans (fos) as chapter number font
}

% Draw the UiT slash (must be used inside a tikzpicture environment)
\newcommand{\ult@chapslashtikz}{%
  \fill[color=chapnumcol] (0,0) -- (1.15,3.15) -- (1.4,3.15) -- (0.25,0) -- cycle;
}

% Strutbox for numbers, to make sure that numbers are given correct vertical positions
\newbox\ult@chapnummetabox
\newbox\ult@chapnumbox
\AtBeginDocument{%
  \setbox\ult@chapnummetabox\hbox{\Huge\bfseries\chapnumfont 0123456789}%
  \setbox\ult@chapnumbox\hbox{%
    \vrule\@height\ht\ult@chapnummetabox
          \@depth\dp\ult@chapnummetabox
          \@width\z@
  }%
}

% Define how chapter number is drawn
\newcommand{\printchapternum}[1][]{%
  \begin{tikzpicture}%
    %\tikzstyle{every rectangle node}=[draw]                                                             % Just for debugging, not used!
    %\draw[fill,color=red] (0,0) rectangle (3.15cm,3.15cm);                                              % Just for debugging, not used!
    \ult@chapslashtikz                                                                                   % Draw UiT "slash"
    \draw[color=black] (1.1,1.18) node[rectangle,anchor=west] { \Huge\bfseries\chapnumfont\unhcopy\ult@chapnumbox\thechapter }; % Draw chapter number
  \end{tikzpicture}%
}

% Used to measure height of UiT slash
\newbox\ult@chapslashbox
\setbox\ult@chapslashbox\hbox{\begin{tikzpicture}\ult@chapslashtikz\end{tikzpicture}}
\newlength\ult@chapslash@height
\setlength{\ult@chapslash@height}{\ht\ult@chapslashbox}

\newcommand{\printrheadslash}[1][]{%
  \begingroup
    % This is a hotfix for a problem with using tikzpicture in running head (triggered when verbatim environment crosses a page boundary)
    % See issue #23 on GitHub. Hopefully, we'll find a better solution later.
    % Note: we only restore dollar catcode inside the local group.
    \catcode`\$=3
    %
    \raisebox{-0.6pt}{%
      \begin{tikzpicture}[scale=0.074]
        \ult@chapslashtikz % Draw UiT "slash"
      \end{tikzpicture}%
    }%
  \endgroup
}

% Align bottom of UiT slash with bottom of baseline
\newlength{\chapterheadalign}
\setlength{\chapterheadalign}{\z@ + 8\ult@normalbaselineskip}

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

\def\baselinesbeforesection{3}
\def\baselinesaftersection{1}

\def\baselinesbeforesubsection{2}
\def\baselinesaftersubsection{1}

\def\baselinesbeforesubsubsection{2}
\def\baselinesaftersubsubsection{1}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pretty size that spans two baselines. Height is approx. \baselineskip + \fontcharht\font`B
% baselineskip is set to 2.5 * \ult@normalbaselineskip (baselineskip of normal font), so that every second
% line aligns to the baseline of the normal font.
\def\chaptitlefontsize {\fontsize{26}{2.5\ult@normalbaselineskip}}

% \Large (of 10pt and 11pt) modified to skip 1.5 normal base lines, so that every second line aligns to
% baseline of the normal font.
\def\sectfontsize {\fontsize\@xivpt{1.5\ult@normalbaselineskip}}

% \large (of 10pt and 11pt) modified to skip exactly 1 base line
\def\subsectfontsize {\fontsize\@xiipt{\ult@normalbaselineskip}}

% Used to measure height of chapter name, section name, etc.
\newbox\ult@chaptername@vbox
\newdimen\ult@chapter@tmptotalheight
\newdimen\ult@chapter@tmpstrutheight
\newbox\ult@sectionname@vbox
\newdimen\ult@section@parwidth
\newdimen\ult@section@tmptotalheight
\newdimen\ult@section@tmpstrutheight

% Used for counting number of lines in chapter title, section title, etc.
\newcounter{ult@chapter@tmpnumlines}
\newcounter{ult@section@tmpnumlines}

% Override \rightskip for \RaggedRight. This could be adjusted.
% See ftp://ftp.rz.uni-wuerzburg.de/pub/tex/latex2e/contrib/ms/ragged2e.pdf
\RaggedRightRightskip\z@\@plus1 fil

% Now, use our supahdupah chapter style! YEEEEEEAAAAHHHHHH!
\titleformat{\chapter}[display]
  {% Format
    % Make sure that line spacing defined by \baselineskip will be preserved under all circumstances!
    % See http://tex.stackexchange.com/questions/49072/is-changing-lineskiplimit-to-some-negative-value-a-good-idea-and-what-the-valu
    % Note: this could be a potential source of future text formatting bugs (if lines are written on top of each other)
    \lineskiplimit=-\maxdimen
  }%
  {\vspace*{\baselinesbeforemainchaphead\ult@normalbaselineskip} \vspace*{-\baselinesbeforefrontchaphead\ult@normalbaselineskip} \vspace*{\chapterheadalign} \printchapternum}% Label
  {\z@ - \parskip + \chapternamealign + \baselinesafterchapnum\ult@normalbaselineskip}% Vertical distance between chapter number and chapter title
  {% Before-code plus chapter name (titlesec's explicit option is enabled, so #1 is chapter name)
    % Make sure Chapter title aligns to baseline
    %
    \chaptitlefont\chaptitlefontsize
    %
    % Prevent overfull hbox (make it OK to break line before entire line's hbox is filled).
    \microtypesetup{protrusion=false,spacing=false}%
    \RaggedRight
    %
    \selectfont
    %
    \vspace*{-\baselineskip}%
    %
    % Measure number of text lines in chapter name
    \setbox0=\vbox{\leavevmode #1\relax \kern \z@ \strut}%
    \ult@chapter@tmptotalheight=\ht0 \advance\ult@chapter@tmptotalheight by \dp0
    \setbox0=\vbox{Bq \kern \z@ \strut}%
    \ult@chapter@tmpstrutheight=\ht0 \advance\ult@chapter@tmpstrutheight by \dp0
    \setcounter{ult@chapter@tmpnumlines}{\DivideLengths{\ult@chapter@tmptotalheight}{\ult@chapter@tmpstrutheight}}%
    %
    % Print chapter name
    #1% Important not to add spaces behind chapter name
  }%
  [% After-code
    % Make sure that normal text following chapter title aligns to baseline
    %
    % The titlesec package inserts something like
    %  \kern \z@ \strut \@@par \nobreak
    % before this (see definition of \ttlh@display).
    %
    % Note: this only works as long as \lineskiplimit=-\maxdimen. Without that, the solution is infinitely more complex.
    % For the old solution, see e.g. commit be2341c37a93c0af6f665bd3d4a0b445c310e1d2
    %
    % Note: we have confirmed that this is needed (try changing value of \parskip right before \@@par).
    % It's probably \@@par that inserts a \parskip. Also note that \parskip does not change when changing font size...
    \vspace*{-\parskip}%
    %
    % Make sure total height + spacing corresponds to an even number of baselineskips for normal font.
    \ifodd\value{ult@chapter@tmpnumlines}\else
      \vspace*{0.5\ult@normalbaselineskip}% XXX: This value is hardcoded such that \baselineskip of \chaptitlefontsize + this value is an integer multiple of \ult@normalbaselineskip.
    \fi
    %
    % Now, switch to normal font
    \normalsize\normalfont\selectfont
    %
    % Strut the fuck up!
    \kern \z@ \strut
    %
    % Compensate for extra line added by strut
    \vspace*{-\parskip}%
    \vspace*{-\baselineskip}%
    %
    %
    %
    % If requested, reset gls expansion on each new chapter
    \ifult@resetallglsperchapter
      % Reset glossaries so every abbreviation will expand on first use (except those that have been unset)
      \ult@restoreglsstates
    \fi
  ]

% Adjust spacing around chapter title
\titlespacing*{\chapter}
  {\z@} % Left margin = 0
  {\z@ - \chapterheadtopvspace + \baselinesbeforefrontchaphead\ult@normalbaselineskip} % Vertical space before chapter head (50\p@ is standard from book.cls)
  {\z@ + \baselinesafterchaptitle\ult@normalbaselineskip} % Vertical space after title, before text (\ttl@chapafter is default)


% The titlesec package overrides definition of \section, but sectsty overrides that definition in turn.
% Re-define \section using titlesec's macros
% NOTE: We do this instead of renewing \section definition manually
% using \@startsection, because it allows a higher degree of flexibility.
\titleclass{\section}{straight}
\titleclass{\subsection}{straight}
\titleclass{\subsubsection}{straight}
\titleclass{\paragraph}{straight}

% Now, define how \section is formatted.
% This will define \ttlf@section as macro:#1-> \ttlh@hang{Format}{Label}{Sep}{Before-code}{After-code}
% (the last three arguments to \ttlh@hang come from \ttl@select{section}...).
\titleformat{\section}[hang]
  {% Format
    % Make sure that line spacing defined by \baselineskip will be preserved under all circumstances!
    % See http://tex.stackexchange.com/questions/49072/is-changing-lineskiplimit-to-some-negative-value-a-good-idea-and-what-the-valu
    % Note: this could be a potential source of future text formatting bugs (if lines are written on top of each other)
    \lineskiplimit=-\maxdimen
    %
    % This \null is needed to ensure space between consecutive chapter/section/subsection/... headers
    \null
    % And this is to compensate for \null after page break
    \if@nobreak\else
      \vspace*{-\parskip}%
    \fi
    %
    \sectfontsize \bfseries \sectfont
    %
    % Prevent overfull hbox (make it OK to break line before entire line's hbox is filled).
    \microtypesetup{protrusion=false,spacing=false}%
    \RaggedRight
    %
    \selectfont
    %
    \vspace*{-\baselineskip}%
  }%
  {\@seccntformat{section}}% Label
  {\z@}% Sep
  {% Before-code:
    % Measure number of text lines in section name
    \ult@section@parwidth=\textwidth
    % Note: \ttlh@hang uses \leftskip in titlesec versions < v.2.10.2, and \hangindent from v.2.10.2
    \advance\ult@section@parwidth by -\leftskip
    \advance\ult@section@parwidth by -\hangindent
    \setbox0=\vbox{\parbox{\ult@section@parwidth}{{#1}\kern \z@ \strut \@@par}}%
    \ult@section@tmptotalheight=\ht0 \advance\ult@section@tmptotalheight by \dp0
    \setbox0=\vbox{Bq \kern \z@ \strut}%
    \ult@section@tmpstrutheight=\ht0 \advance\ult@section@tmpstrutheight by \dp0
    \setcounter{ult@section@tmpnumlines}{\DivideLengths{\ult@section@tmptotalheight}{\ult@section@tmpstrutheight}}%
    %
    % Print section name (needed because we have enabled titlesec's explicit option)
    #1% Important not to add spaces behind section name
  }%
  [% After-code
    % Make sure that normal text following section title aligns to baseline
    %
    % The titlesec package inserts something like
    %  \kern \z@ \strut \@@par \nobreak
    % before this (see definition of \ttlh@hang).
    %
    % Note: this only works as long as \lineskiplimit=-\maxdimen. Without that, the solution is infinitely more complex.
    % For the old solution, see e.g. commit be2341c37a93c0af6f665bd3d4a0b445c310e1d2
    %
    % Note: we have confirmed that this is needed (try changing value of \parskip right before \@@par).
    % It's probably \@@par that inserts a \parskip. Also note that \parskip does not change when changing font size...
    \vspace*{-\parskip}%
    %
    % Make sure total height + spacing corresponds to an even number of baselineskips for normal font.
    \ifodd\value{ult@section@tmpnumlines}\else
      \vspace*{0.5\ult@normalbaselineskip}% XXX: This value is hardcoded such that \baselineskip of \sectfontsize + this value is an integer multiple of \ult@normalbaselineskip.
    \fi
    %
    % Now, switch to normal font
    \normalsize\normalfont\selectfont
    %
    % Add a strut, to make sure that following text is placed perfectly on baseline.
    % Note: we cannot use \kern\z@ before strut, because that will ruin the \nobreak that we want between a section header
    % and the following text (we do not want to have a section header at the end of a page, and the following text at the next page).
    \strut
    %
    % Compensate for extra line added by strut
    \vspace*{-\parskip}%
    \vspace*{-\baselineskip}%
  ]

% Starred version makes sure we suppress indentation of text following section title
\titlespacing*{\section}
  {\z@} % Left margin = 0
  {\z@ + \baselinesbeforesection\ult@normalbaselineskip} % Vertical space before
  {\z@ + \baselinesaftersection\ult@normalbaselineskip} % Vertical space after

% Now, define how \subsection is formatted.
\titleformat{\subsection}[hang]
  {% Format
    % This \null is needed to ensure space between consecutive chapter/section/subsection/... headers
    \null
    % And this is to compensate for \null after page break
    \if@nobreak\else
      \vspace*{-\parskip}%
    \fi
    %
    \subsectfontsize \bfseries \subsectfont
    %
    % Prevent overfull hbox (make it OK to break line before entire line's hbox is filled).
    \microtypesetup{protrusion=false,spacing=false}%
    \RaggedRight
    %
    \selectfont
    %
    \vspace*{-\baselineskip}%
  }%
  {\@seccntformat{subsection}}% Label
  {\z@}% Sep
  {#1}% Before-code: print subsection name (needed because we have enabled titlesec's explicit option)
  []% After-code

% Starred version makes sure we suppress indentation of text following section title
\titlespacing*{\subsection}
  {\z@} % Left margin = 0
  {\z@ + \baselinesbeforesubsection\ult@normalbaselineskip} % Vertical space before
  {\z@ - \parskip + \baselinesaftersubsection\ult@normalbaselineskip} % Vertical space after

% Now, define how \subsection is formatted.
\titleformat{\subsubsection}[hang]
  {% Format
    % This \null is needed to ensure space between consecutive chapter/section/subsection/... headers
    \null
    % And this is to compensate for \null after page break
    \if@nobreak\else
      \vspace*{-\parskip}%
    \fi
    %
    \normalsize \bfseries \subsubsectfont
    %
    % Prevent overfull hbox (make it OK to break line before entire line's hbox is filled).
    \microtypesetup{protrusion=false,spacing=false}%
    \RaggedRight
    %
    \selectfont
    %
    \vspace*{-\baselineskip}%
  }%
  {\@seccntformat{subsubsection}}% Label
  {\z@}% Sep
  {#1}% Before-code: print subsubsection name (needed because we have enabled titlesec's explicit option)
  []% After-code

% Starred version makes sure we suppress indentation of text following section title
\titlespacing*{\subsubsection}
  {\z@} % Left margin = 0
  {\z@ + \baselinesbeforesubsubsection\ult@normalbaselineskip} % Vertical space before
  {\z@ - \parskip + \baselinesaftersubsubsection\ult@normalbaselineskip} % Vertical space after

% Now, define how \paragraph is formatted.
\titleformat{\paragraph}[runin]
  {% Format
    \null
    \vspace*{-\parskip}%
    \normalsize \bfseries \parafont \selectfont
    \vspace*{-\baselineskip}%
  }%
  {\@seccntformat{paragraph}}% Label
  {\z@}% Sep
  {#1}% Before-code: print paragraph name (needed because we have enabled titlesec's explicit option)
  []% After-code

%%% NOTE
%%% The \@startsection macro is defined as follows:
%%%  \@startsection{<name>}{<level>}{<indent>}{<beforeskip>}{<afterskip>}{<style>}*[<altheading>]{<heading>}
%%% where the part after the *, including the * is optional.
%%% See http://tex.stackexchange.com/questions/31780/where-can-i-find-help-files-or-documentation-for-commands-like-startsection-fo
%%% and http://www.tug.org/texlive/Contents/live/texmf-dist/doc/latex/base/source2e.pdf

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
% (see http://mirrors.ctan.org/macros/latex/contrib/titlesec/titlesec.pdf section 3.1)
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

% Default environment names for abstract and acknowledgement.
% These needs to be defined, incase a language who does not define them is loaded (like samin)
% Therefore, if they are not defined, the compilation won't halt on an undefined control sequence within the classfile,
% but rather use the standard defined english term.
\newcommand{\abstractname}{Abstract}
\newcommand{\ackname}{Acknowledgements}

% Define ack and abstract for english and norwegian explicitly, even though they may be defined in the language pack.
\renamedefname[USenglish]{abstract}{Abstract}
\renamedefname[USenglish]{ack}{Acknowledgements}
\renamedefname[norsk]{abstract}{Sammendrag}
\renamedefname[norsk]{ack}{Takksigelser}

% Missing from samin babel package
\renamedefname[samin]{ack}{Giitosat}
\renamedefname[samin]{acronym}{Oanádusat}

% Defined incorrectly with capital first letter in babel's 'norsk'
\renamedefname[norsk]{see}{se}

% Control-ifs
\newif\ifult@hasacknowledgement\ult@hasacknowledgementfalse
\newif\ifult@hasabstract\ult@hasabstractfalse
\newif\ifult@hasdedication\ult@hasdedicationfalse
\newif\ifult@hasepigraph\ult@hasepigraphfalse

% Abstract
\newenvironment{abstract}{%
  \ifult@hasacknowledgement
    \ult@warning{'\abstractname' should precede '\ackname'.}%
  \fi
  \global\ult@hasabstracttrue
  \chapter{\abstractname}%
  \thispagestyle{empty}%
}{}

% Acknowledgements
\newenvironment{acknowledgement}{%
  \global\ult@hasacknowledgementtrue
  \chapter{\ackname}%
  \thispagestyle{empty}%
}{}

% Dedication
\newenvironment{dedication}{%
  \ifult@hasabstract
    \ult@warning{'Dedication' should precede '\abstractname'.}%
  \fi
  \ifult@hasacknowledgement
    \ult@warning{'Dedication' should precede '\ackname'.}%
  \fi
  \ifult@hasepigraph
    \ult@warning{'Dedication' should precede 'Epigraph'}%
  \fi
  \global\ult@hasdedicationtrue
  \cleardoublepage
  \phantomsection
  \chaptermark{}%
  \thispagestyle{empty}%
  \null
  \vfil
  \begingroup
  \center
  \fontsize{12pt}{14.4pt}\rmfamily\mdseries\itshape\selectfont
}{%
  \endcenter
  \endgroup
  \vfil
}

% Epigraph
\newcommand{\epigraphitem}[2]{%
  \ifdefined\@ult@epigraphenv
    \item{``#1\relax''\\{--}#2\relax}%
  \else
    \ult@critical@error{epigraph environment required for epigraphitem!}%
  \fi
}
\newenvironment{epigraph}{%
  \ifult@hasacknowledgement
    \ult@warning{'Epigraph' should precede '\ackname'.}%
  \fi
  \ifult@hasabstract
    \ult@warning{'Epigraph' should precede '\abstractname'.}%
  \fi
  \ifdefined\@ult@epigraphenv
    \ult@critical@error{Nested epigraphs are not allowed!}%
  \fi
  \global\ult@hasepigraphtrue
  \def\@ult@epigraphenv{}%
  \clearpage\thispagestyle{empty}%
  \null\vfill
  \begin{flushright}%
}{%
  \end{flushright}%
  \vspace*{2\baselineskip}%
}


%:-------------------------- ToC lists -----------------------

% TODO:
% \l@part
% \l@chapter
% \l@section
% \l@subsection
% \l@subsubsection
% \l@paragraph
% \l@subparagraph
% \l@figure
% \l@table

% List of ToC lists (e.g. lof for List of Figures, lot for List of Tables, ...)
\newcommand*{\ult@toclists}{,}
\newcommand*{\ult@foralltoclists}[2]{%
  \@for#1:=\ult@toclists\do{\ifx#1\@empty\else#2\fi}%
}

\eappto\ult@toclists{lof,} % Append List of Figures to \ult@toclists
\eappto\ult@toclists{lot,} % Append List of Tables to \ult@toclists

\let\ult@save@l@part\l@part
\renewcommand*\l@part[2]{%
  \ifult@first@contentsline
    \vspace*{\ult@cftbeforechapskip}
    \vspace*{-\cftbeforepartskip}
  \fi
  \ult@save@l@part{#1}{#2}%
}

\newlength\ult@cftbeforepartskip
  \setlength{\ult@cftbeforepartskip}{2\ult@normalbaselineskip} % Default is 2.25em \@plus\p@
\newlength\ult@cftbeforechapskip
  \setlength{\ult@cftbeforechapskip}{\ult@normalbaselineskip} % Default is 1.0em \@plus\p@
\newlength\ult@cftbeforesecskip
  \setlength{\ult@cftbeforesecskip}{0pt} % Default is \z@ \@plus .2\p@

\newlength\ult@cftpartindent
  \setlength{\ult@cftpartindent}{0em} % Default is 0em
\newlength\ult@cftpartnumwidth
  \setlength{\ult@cftpartnumwidth}{0em} % Default is 0em

\newlength\ult@cftchapindent
  \setlength{\ult@cftchapindent}{0em} % Default is 0em
\newlength\ult@cftchapnumwidth
  \setlength{\ult@cftchapnumwidth}{1.5em} % Default is 1.5em

\newlength\ult@cftsecindent
  \setlength{\ult@cftsecindent}{1.5em} % Default is 1.5em
\newlength\ult@cftsecnumwidth
  \setlength{\ult@cftsecnumwidth}{2.3em} % Default is 2.3em

\newlength\ult@cftsubsecindent
  \setlength{\ult@cftsubsecindent}{3.8em} % Default is 3.8em
\newlength\ult@cftsubsecnumwidth
  \setlength{\ult@cftsubsecnumwidth}{3.2em} % Default is 3.2em

\newlength\ult@cftsubsubsecindent
  \setlength{\ult@cftsubsubsecindent}{7.0em} % Default is 7.0em
\newlength\ult@cftsubsubsecnumwidth
  \setlength{\ult@cftsubsubsecnumwidth}{4.1em} % Default is 4.1em

\newlength\ult@cftparaindent
  \setlength{\ult@cftparaindent}{10em} % Default is 10em
\newlength\ult@cftparanumwidth
  \setlength{\ult@cftparanumwidth}{5em} % Default is 5em

\newlength\ult@cftsubparaindent
  \setlength{\ult@cftsubparaindent}{12em} % Default is 12em
\newlength\ult@cftsubparanumwidth
  \setlength{\ult@cftsubparanumwidth}{6em} % Default is 6em

\newcommand{\ult@cftpartfont}     % part titles
           {\usefont{T1}{bch}{b}{n}\large}
\newcommand{\ult@cftchapfont}     % chapter titles
           {\usefont{T1}{bch}{b}{n}}
\newcommand{\ult@cftsecfont}      % section titles
           {\usefont{T1}{bch}{m}{n}}
\newcommand{\ult@cftpartpagefont} % part page numbers
           {\ult@cftpartfont}
\newcommand{\ult@cftchappagefont} % chapter page numbers
           {\ult@cftchapfont}
\newcommand{\ult@cftsecpagefont}  % section page numbers
           {\ult@cftsecfont}

% Skip
\setlength{\cftbeforepartskip}{\ult@cftbeforepartskip}
\setlength{\cftbeforechapskip}{\ult@cftbeforechapskip}
\setlength{\cftbeforesecskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforesubsecskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforesubsubsecskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforeparaskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforesubparaskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforefigskip}{\ult@cftbeforesecskip}
\setlength{\cftbeforetabskip}{\ult@cftbeforesecskip}

% Indent
\setlength{\cftpartindent}{\ult@cftpartindent}
\setlength{\cftchapindent}{\ult@cftchapindent}
\setlength{\cftsecindent}{\ult@cftsecindent}
\setlength{\cftsubsecindent}{\ult@cftsubsecindent}
\setlength{\cftsubsubsecindent}{\ult@cftsubsubsecindent}
\setlength{\cftparaindent}{\ult@cftparaindent}
\setlength{\cftsubparaindent}{\ult@cftsubparaindent}
\setlength{\cftfigindent}{\ult@cftsecindent}
\setlength{\cfttabindent}{\ult@cftsecindent}

% Num width
\setlength{\cftpartnumwidth}{\ult@cftpartnumwidth}
\setlength{\cftchapnumwidth}{\ult@cftchapnumwidth}
\setlength{\cftsecnumwidth}{\ult@cftsecnumwidth}
\setlength{\cftsubsecnumwidth}{\ult@cftsubsecnumwidth}
\setlength{\cftsubsubsecnumwidth}{\ult@cftsubsubsecnumwidth}
\setlength{\cftparanumwidth}{\ult@cftparanumwidth}
\setlength{\cftsubparanumwidth}{\ult@cftsubparanumwidth}
\setlength{\cftfignumwidth}{\ult@cftsecnumwidth}
\setlength{\cfttabnumwidth}{\ult@cftsecnumwidth}

% Fonts
\renewcommand{\cftpartfont}{\ult@cftpartfont}
\renewcommand{\cftchapfont}{\ult@cftchapfont}
\renewcommand{\cftsecfont}{\ult@cftsecfont}
\renewcommand{\cftsubsecfont}{\ult@cftsecfont}
\renewcommand{\cftsubsubsecfont}{\ult@cftsecfont}
\renewcommand{\cftparafont}{\ult@cftsecfont}
\renewcommand{\cftsubparafont}{\ult@cftsecfont}
\renewcommand{\cftfigfont}{\ult@cftsecfont}
\renewcommand{\cfttabfont}{\ult@cftsecfont}

% Page number fonts
\renewcommand{\cftpartpagefont}{\ult@cftpartpagefont}
\renewcommand{\cftchappagefont}{\ult@cftchappagefont}
\renewcommand{\cftsecpagefont}{\ult@cftsecpagefont}
\renewcommand{\cftsubsecpagefont}{\ult@cftsecpagefont}
\renewcommand{\cftsubsubsecpagefont}{\ult@cftsecpagefont}
\renewcommand{\cftparapagefont}{\ult@cftsecpagefont}
\renewcommand{\cftsubparapagefont}{\ult@cftsecpagefont}
\renewcommand{\cftfigpagefont}{\ult@cftsecpagefont}
\renewcommand{\cfttabpagefont}{\ult@cftsecpagefont}

% Override tocloft's \newlistentry
% First, allow \newlistentry (and hence, also \newlistof) command, even if entry has already been defined.
% This allows us to use \newlistof to generate list definition after e.g. defining a float using \newfloat.
% For example:
%        \newfloat{algorithm}{htbp}{loalgorithm}[chapter]
%        \newlistof{algorithm}{loalgorithm}{List of Algorithms}
%
\xpatchcmd{\newlistentry}
    {{\PackageError{tocloft}{#2 has been previously defined}{\@eha}}}
    {{}}
    {}
    {\ult@critical@error{Failed to patch \@backslashchar newlistentry}}
%
% Now, override the macro, so we may override default styling on new list entries.
\LetLtxMacro{\ult@savenewlistentry}{\newlistentry}
\renewcommand{\newlistentry}[4][\@empty]{%
  \ult@savenewlistentry[#1]{#2}{#3}{#4}%
  \setlength{\@nameuse{cftbefore#2skip}}{\ult@cftbeforesecskip}%
  \setlength{\@nameuse{cft#2indent}}{\ult@cftsecindent}%
  \setlength{\@nameuse{cft#2numwidth}}{\ult@cftsecnumwidth}%
  \@namedef{cft#2font}{\ult@cftsecfont}%
  \@namedef{cft#2pagefont}{\ult@cftsecpagefont}%
}

% Override tocloft's \newlistof
\LetLtxMacro{\ult@savenewlistof}{\newlistof}
\renewcommand{\newlistof}[4][\@empty]{%
  \ult@savenewlistof[#1]{#2}{#3}{#4}%
  %
  % Append list extension to \ult@toclists
  \eappto\ult@toclists{#3,}%
  %
  % Override \listof... macro to use tocbibind to generate list
  % (will also add list to ToC).
  \@namedef{listof#2}{%
    \begingroup
      \tocfile{#4}{#3}%
    \endgroup
  }%
}

% Override float package's \listof (for lists that do not use tocloft)
% See: http://tex.stackexchange.com/questions/58469/why-are-listof-and-listoffigures-styled-differently
\renewcommand*{\listof}[2]{%
  \@ifundefined{ext@#1}{\float@error{#1}}{%
    \expandafter\let\csname l@#1\endcsname \l@figure  % <- use layout of figure
    %
    % Append list extension to \ult@toclists
    % Note: this is safe even if it has already been added to \ult@toclists...
    \eappto\ult@toclists{\@nameuse{ext@#1},}%
    %
    % Use tocbibind to render list
    \begingroup
      \tocfile{#2}{\@nameuse{ext@#1}}%
    \endgroup
  }%
}

% Override newfloat package's \newfloat@list@of to use our \listof command,
% because it relies on the ability to first make customizations, and then typeset
% the list using \listoffigures, which won't work in this template.
\renewcommand*{\newfloat@list@of}[2]{%
  \listof{#1}{\@nameuse{list#1name}}%
}

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
\begingroup
  \let\newcounter\@gobble
  \let\setcounter\@gobbletwo
  \globaldefs\@ne
  \let\c@loldepth\@ne
  \newlistof{listings}{lol}{\lstlistlistingname}
\endgroup
\let\l@lstlisting\l@listings

% List of Listings
\renamedefname[USenglish]{lstlistlisting}{List of Listings}
\renamedefname[norsk]{lstlistlisting}{Listinger}
\renewcommand\lstlistoflistings{%
  \iftotallstlistings% Only output list if count > 0
    \cleardoublepage
    % Use tocbibind to generate list of listings
    \listoflistings
  \fi
}
% Make sure \listoflistings has effect at most once!
\ult@once{\lstlistoflistings}

% List of Abbreviations
\renamedefname[USenglish]{acronym}{List of Abbreviations}
\renamedefname[norsk]{acronym}{Forkortelser}

\usepackage{ult-printglossary}

% Prevent \printglossaries, since we have acronyms in frontmatter and glossary in back matter
\renewcommand*{\printglossaries}{%
  \ult@warning{Call to \@backslashchar printglossaries was ignored.}%
}


%:-------------------------- Book class overrides -----------------------

% List of glossary entries that has been unset or reset (and must be remembered as such...)
\newcommand*{\ult@glsstates}{,}
\let\ult@saveglsreset\glsreset
\let\ult@saveglsunset\glsunset

% Macros for remembering gls entry states (unset or reset)
\newcommand*{\ult@unsetgls}[1]{%
  \gls@ifnotmeasuring
  {%
    \glsdoifexists{#1}%
    {%
      \csname ifglo@#1@flag\endcsname% True means unset
        \global\eappto\ult@glsstates{-#1,}% Append gls entry to list (minus indicates that glsentry is unset)
      \fi
    }%
  }%
}
\newcommand*{\ult@rememberglsstates}[1][\@glo@types]{%
  \forallglsentries[#1]{\@glsentry}%
  {%
     \ult@unsetgls{\@glsentry}%
  }%
}
\newcommand*{\ult@preserveglsstates}{%
  \renewcommand*{\glsreset}[1]{%
    \gls@ifnotmeasuring
    {%
      \glsdoifexists{##1}%
      {%
        \global\eappto\ult@glsstates{+##1,}% Append gls entry to list (plus indicates that glsentry is reset)
      }%
    }%
  }%
  \renewcommand*{\glsunset}[1]{%
    \gls@ifnotmeasuring
    {%
      \glsdoifexists{##1}%
      {%
        \global\eappto\ult@glsstates{-##1,}% Append gls entry to list (minus indicates that glsentry is unset)
      }%
    }%
  }%
}
\newcommand*{\ult@restoreglsstates}{%
  % Restore \glsreset and \glsunset
  \let\glsreset\ult@saveglsreset
  \let\glsunset\ult@saveglsunset
  %
  % Reset all gls entries, so these will expand
  \glsresetall
  %
  % Re-apply overridden gls states
  \@for{\@glsentry}:=\ult@glsstates\do% Iterate over entries in \ult@glsstates
  {%
    \ifx\@glsentry\@empty% Ignore empty entries
    \else
      \StrLeft{\@glsentry}{1}[\firstchar]% Get leftmost character
      \StrGobbleLeft{\@glsentry}{1}[\@glsentry]% Remove leftmost character
      \IfStrEq{\firstchar}{+}{% If entry starts with a plus (indicates reset)
        \glsreset{\@glsentry}%
      }%
      {% If not
        \IfStrEq{\firstchar}{-}{% If entry start with a minus (indicates unset)
          \glsunset{\@glsentry}%
        }%
        {% If not
          \ult@critical@error{BUG in \@backslashchar ult@restoreglsstates}%
        }%
      }%
    \fi
  }%
}

% Frontmatter
\let\ult@savefrontmatter\frontmatter
\renewcommand\frontmatter{%
  \ult@savefrontmatter
  %
  % Clear running heads
  \markboth{}{}%
  %
  % Redefine what is in \chaptermark so that \leftmark contains chapter name. Thus "Abstract" and "Acknowledgements" will be written in header
  \renewcommand{\chaptermark}[1]{%
    % Note: we use two number signs (#) because we have renewcommand within renewcommand
    \markboth{\rheadfmt{##1}}% % \leftmark (will be written to the right on even/verso pages and to the left on odd/recto pages) is set to chapter title after start of new chapters
             {}%    % \rightmark is cleared after start of new chapters, and will be replaced after start of new section
    }%
  %
  % Set \leftmark to the left on odd pages
  % This will make sure that chapter title is written in front matter where section title is normally written in main matter,
  % that is, to the left on odd/recto pages (in addition to the right on even/verso pages, where it is already written)
  \fancyhead[LO]{\rheadfont\textcolor{rheadcolor}{\leftmark}}%
  %
  % Remember current gls states (if any gls entries have been unset)
  \ult@rememberglsstates
  %
  % Make sure that abbreviations are not expanded
  \glsunsetall
  %
  % Make sure that we retain future state modifications
  \ult@preserveglsstates
}

% Table of Contents
\renewcommand\tableofcontents{%
  % Modified version of original \tableofcontents (we use tocloft, and our running heads style),
  % so we do not invoke original \tableofcontents.
  % Note: we do *not* use tocbibind's \tocfile (and use tocbibind with nottoc option), since we
  % do not want to include ToC as entry in ToC
  \toc@start
  \chapter*{\contentsname}\prw@mkboth{\contentsname}%
  \@starttoc{toc}%
  \toc@finish
  %
  \renewcommand\tableofcontents{%
    \ult@critical@error{Duplicate \@backslashchar tableofcontents}%
  }%
  %
  % LISTS
  % 1: Figures/illustrations
  % 2: Tables
  % 3: Abbreviations
  % 4: Symbols
  % 5: Preface
  %
  \ifult@printlistoffigures
    \listoffigures
  \fi
  %
  \ifult@printlistoftables
    \listoftables
  \fi
}

% Mainmatter
\let\ult@savemainmatter\mainmatter
\renewcommand\mainmatter{%
  \ult@savemainmatter
  %
  % Clear running heads
  \markboth{}{}%
  %
  % Redefine \chaptermark, so it contains chapter number in front of chapter name (e.g. "2 My Chapter's Name")
  % Note that we do not use \@chapapp (contains "chapter type"), because we do not want to write "Chapter" before the chapter number.
  \renewcommand{\chaptermark}[1]{%
    % Note: we use two number signs (#) because we have renewcommand within renewcommand
    \markboth{\rheadfmt{\@chapapp\ \thechapter}\hspace{5pt}\printrheadslash\hspace{5pt}\rheadfmt{##1}}% % \leftmark (will be written to the right on even/verso pages) is set to chapter title after start of new chapters
             {}%                 % \rightmark is cleared after start of new chapters, and will be replaced after start of new section
  }%
  %
  % Set odd pages to have \rightmark instead of \leftmark
  % This will make sure that section title is written to the left in running headers on odd (recto) pages
  \fancyhead[LO]{\rheadfont\textcolor{rheadcolor}{\rightmark}}%
  %
  % Reset glossaries so every abbreviation will expand on first use (except those that have been unset)
  \ult@restoreglsstates
}

% Backmatter
\let\ult@savebackmatter\backmatter
\renewcommand\backmatter{%
  \ult@savebackmatter
  %
  % Redefine headers
  \pagestyle{empty}%
  %
  % Blank back cover
  \clearversopage
}


%:-------------------------- Frontpage stuffs -----------------------

% \begin{egg}
\usetikzlibrary{arrows}
\newcommand{\printthed}{%
\begin{tikzpicture}[y=0.80pt,x=0.80pt,yscale=-1, inner sep=0pt, outer sep=0pt]
\begin{scope}[cm={{0.15032,0.0,0.0,0.15032,(687.69171,514.56151)}},miter limit=4.00,line width=1.597pt]
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2786.7101,-1367.9041) .. controls (-2786.7101,-1367.9041) and
    (-2797.9533,-1520.1411) .. (-3101.0019,-1132.0707) .. controls
    (-3511.0303,-607.0069) and (-3327.5762,-521.3086) .. (-3217.9124,-534.4309) ..
    controls (-3022.0493,-557.8676) and (-2794.3016,-925.5333) ..
    (-2794.3016,-925.5333) .. controls (-2794.3016,-925.5333) and
    (-2658.2818,-610.7784) .. (-2459.3821,-585.8766);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2797.3381,-1384.0170) .. controls (-2692.2596,-1466.0366) and
    (-2425.9814,-1145.6598) .. (-2402.5755,-688.2351);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2779.1183,-956.2942) .. controls (-2779.1183,-956.2942) and
    (-2560.6330,-725.3784) .. (-2401.1541,-695.4867) .. controls
    (-2316.7703,-623.7343) and (-2444.2807,-673.0076) .. (-2444.2807,-673.0076);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2681.9459,-828.8564) .. controls (-2681.9459,-828.8564) and
    (-2361.4997,-520.0828) .. (-2397.1286,-662.0771);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2718.3857,-830.3210) .. controls (-2718.3857,-830.3210) and
    (-2562.8065,-632.6814) .. (-2462.2460,-644.1461);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2770.9901,-1266.4851) .. controls (-2770.9901,-1266.4851) and
    (-2737.9867,-849.6432) .. (-3113.1485,-686.7705) .. controls
    (-3325.7131,-594.4876) and (-3190.5828,-940.1815) .. (-3190.5828,-940.1815) ..
    controls (-3190.5828,-940.1815) and (-3395.2357,-697.4748) ..
    (-3269.5352,-598.8821) .. controls (-3148.2610,-503.7611) and
    (-2829.3065,-868.1222) .. (-2793.3621,-1065.8372);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2760.8986,-1297.5935) .. controls (-2760.8986,-1297.5935) and
    (-2835.2962,-1095.4507) .. (-2763.9353,-963.6182);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2583.8842,-958.0129) .. controls (-2567.8959,-990.3475) and
    (-2562.3605,-915.8801) .. (-2468.6603,-939.5927) .. controls
    (-2502.4592,-913.9053) and (-2512.4648,-886.0831) .. (-2490.0090,-842.7378) ..
    controls (-2579.7589,-804.7920) and (-2568.2158,-858.5995) ..
    (-2585.9235,-832.6466) .. controls (-2593.0189,-826.1517) and
    (-2624.2725,-896.9944) .. (-2583.8842,-958.0129) -- cycle;
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2599.5802,-908.7520) .. controls (-2599.5802,-908.7520) and
    (-2547.5100,-851.7847) .. (-2455.7161,-891.6619);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2520.5053,-945.8622) .. controls (-2520.5053,-945.8622) and
    (-2570.7746,-822.2300) .. (-2517.0940,-834.6594);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3204.7844,-536.3246) .. controls (-3304.7291,-515.4385) and
    (-3314.9076,-555.0852) .. (-3333.1284,-549.7742) .. controls
    (-3342.5947,-547.0150) and (-3365.6865,-475.9550) .. (-3302.1252,-497.3588);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2801.0295,-862.4825) .. controls (-2801.0295,-862.4825) and
    (-3050.8703,-494.7833) .. (-3258.0776,-509.2841);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2797.4975,-868.6973) .. controls (-2815.8287,-855.9247) and
    (-2989.8181,-474.3128) .. (-3238.7527,-487.5329);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2852.2518,-728.8680) .. controls (-2852.2518,-728.8680) and
    (-3057.6670,-385.8845) .. (-3291.7146,-455.2813);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2685.1231,-739.4034) .. controls (-2685.1231,-735.2603) and
    (-2677.2529,-564.1800) .. (-2662.2223,-553.8224);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3281.1604,-456.9775) .. controls (-3281.1604,-456.9775) and
    (-3305.0618,-443.6829) .. (-3336.4514,-459.5670) .. controls
    (-3364.6339,-473.8281) and (-3349.3347,-497.8906) .. (-3340.7459,-495.8190);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3326.0703,-454.4629) .. controls (-3312.0037,-456.7248) and
    (-3350.3096,64.3455) .. (-3337.5251,149.4673);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3265.9479,-457.6755) .. controls (-3265.9479,-457.6755) and
    (-3305.7694,-335.8731) .. (-3276.3290,-91.8677) .. controls
    (-3252.7095,103.8933) and (-3319.2388,478.5928) .. (-3328.9011,551.0969) ..
    controls (-3335.2228,598.5318) and (-3288.5199,604.2066) ..
    (-3288.5199,604.2066);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3210.8387,921.1179) .. controls (-3242.2285,904.7599) and
    (-3297.8420,806.2980) .. (-3305.3167,820.3446) .. controls
    (-3311.2638,782.9671) and (-3320.3473,746.0723) .. (-3320.3473,746.0723) ..
    controls (-3320.3473,746.0723) and (-3327.8625,611.4219) ..
    (-3325.7152,579.3130) .. controls (-3323.5681,547.2040) and
    (-3328.9362,339.0137) .. (-3332.1570,241.6511) .. controls
    (-3335.3777,144.2885) and (-3337.5251,146.3600) .. (-3337.5251,146.3600);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2432.3047,-628.9332) .. controls (-2432.3047,-628.9332) and
    (-2416.2900,-622.4134) .. (-2424.4169,-608.7182) .. controls
    (-2428.7917,-601.3459) and (-2439.0924,-587.1995) .. (-2457.8808,-587.1998) ..
    controls (-2461.1016,-576.8420) and (-2452.8676,-261.7344) ..
    (-2442.1316,-183.0157) .. controls (-2431.3954,-104.2970) and
    (-2374.5289,1364.2417) .. (-2370.2344,1410.8514);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3333.3046,697.4691) .. controls (-3353.0427,706.2581) and
    (-3415.2937,744.3429) .. (-3397.0740,797.0759) .. controls
    (-3378.8542,849.8088) and (-3292.3100,921.5842) .. (-3287.7550,940.6266);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3340.7167,872.4330) .. controls (-3340.7167,872.4330) and
    (-3374.4975,1382.5149) .. (-3348.4879,1488.4631) .. controls
    (-3334.8230,1544.1257) and (-3342.4145,1569.0273) .. (-3342.4145,1569.0273) ..
    controls (-3342.4145,1569.0273) and (-3328.5045,1567.7983) ..
    (-3319.6397,1681.8172) .. controls (-3311.7684,1783.0607) and
    (-3318.5192,1918.3023) .. (-3316.6032,1995.2853) .. controls
    (-3315.4755,2040.5893) and (-3287.6925,2156.3533) .. (-3299.9016,2206.2169) ..
    controls (-3311.2659,2252.6302) and (-3305.9750,2264.8092) ..
    (-3305.9750,2264.8092);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3206.5443,194.0056) .. controls (-3206.5443,194.0056) and
    (-3231.3810,277.5901) .. (-3146.4219,409.4463) .. controls
    (-3097.0357,486.0934) and (-3107.7719,568.9552) .. (-3107.7719,568.9552);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3148.8289,202.3655) .. controls (-3131.8729,234.9954) and
    (-3148.2376,270.9435) .. (-3098.7285,311.3944) .. controls
    (-3058.5621,330.4696) and (-3004.7620,272.1281) .. (-2957.5208,256.5632);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2947.6517,322.4794) .. controls (-2980.7067,354.1865) and
    (-3064.4514,381.7564) .. (-3034.1958,564.1720) .. controls
    (-3026.8437,608.5002) and (-3017.4944,723.8357) .. (-3017.4944,723.8357);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2843.6470,-464.1202) .. controls (-2847.9385,-472.8146) and
    (-2875.3017,-19.2960) .. (-2864.1442,104.2236) .. controls
    (-2854.9997,205.4609) and (-2848.9611,650.5954) .. (-2852.7569,752.3994);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2673.5953,-392.3448) .. controls (-2681.6787,-389.4204) and
    (-2691.6365,-330.8249) .. (-2688.7784,-30.5383) .. controls
    (-2685.8911,272.8240) and (-2725.9034,701.2633) .. (-2724.4589,727.4976);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2399.0003,1441.3359) .. controls (-2399.0003,1441.3359) and
    (-2361.1394,1481.6904) .. (-2355.0660,1448.7324) .. controls
    (-2352.1248,1432.7702) and (-2398.7795,1334.6587) .. (-2398.7795,1334.6587) ..
    controls (-2398.7795,1334.6587) and (-2416.9995,1149.3611) ..
    (-2425.3501,1084.9097) .. controls (-2433.7009,1020.4583) and
    (-2429.9051,719.4412) .. (-2430.6642,659.3842) .. controls
    (-2431.4235,599.3273) and (-2443.5701,484.3402) .. (-2443.5701,484.3402);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2382.0781,1453.3079) .. controls (-2382.0781,1453.3079) and
    (-2367.3531,1638.0816) .. (-2362.3400,1703.0569) .. controls
    (-2358.0196,1759.0522) and (-2496.7112,1850.2697) .. (-2496.7112,1850.2697);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2476.9731,1960.8624) .. controls (-2458.9406,1901.4002) and
    (-2311.6093,1853.3671) .. (-2294.7749,1736.7475) .. controls
    (-2284.1466,1670.8312) and (-2373.0505,1554.9952) .. (-2373.0505,1554.9952);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2347.8922,1837.8308) .. controls (-2347.8922,1837.8308) and
    (-2349.4560,1917.8862) .. (-2346.3281,1968.8303) .. controls
    (-2343.2005,2019.7746) and (-2341.5452,2063.4643) .. (-2343.8911,2115.1364) ..
    controls (-2346.2370,2166.8084) and (-2323.6513,2459.3509) ..
    (-2297.0648,2532.8562);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2840.6103,1760.9167) .. controls (-2860.1263,1863.3716) and
    (-2916.1694,1853.7498) .. (-2899.0656,2033.3701) .. controls
    (-2899.0656,2033.3701) and (-2909.6938,2116.8640) .. (-2905.8980,2140.3009);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2913.4896,1716.9726) .. controls (-2914.0739,1750.9623) and
    (-2937.8977,1731.2109) .. (-2968.1491,1826.8328) .. controls
    (-2976.7277,1853.9497) and (-2983.3321,1927.1719) .. (-2983.3321,1927.1719) ..
    controls (-3037.0903,1845.0040) and (-3073.1447,1821.1102) ..
    (-3100.2428,1767.5084) .. controls (-3135.6427,1697.4845) and
    (-3138.2007,1628.3519) .. (-3138.2007,1628.3519);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3213.3574,1675.9581) .. controls (-3213.3574,1675.9581) and
    (-3162.5855,1828.7648) .. (-3109.3527,1938.1578) .. controls
    (-3082.8272,1992.6673) and (-3017.4944,2014.3277) .. (-2992.4422,2173.2589);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2569.5905,-226.8220) .. controls (-2569.5905,-226.8220) and
    (-2563.5173,-53.9752) .. (-2581.7370,-17.3551) .. controls (-2591.5044,2.2764)
    and (-2581.7370,19.2650) .. (-2581.7370,19.2650);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2531.6326,-276.6253) .. controls (-2531.6326,-276.6253) and
    (-2523.5813,-227.8031) .. (-2531.6324,-125.7505) .. controls
    (-2537.9047,-46.2458) and (-2513.4126,-29.0735) .. (-2513.4126,-29.0735);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2504.3027,-32.0031) .. controls (-2504.3027,-32.0031) and
    (-2448.1249,-125.7505) .. (-2443.5701,-177.0187);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2555.9255,690.1451) .. controls (-2555.9255,690.1451) and
    (-2573.4689,763.9446) .. (-2598.4385,779.4981) .. controls
    (-2670.7557,824.5447) and (-2694.0925,763.3853) .. (-2694.0925,763.3853);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2528.5959,739.9484) .. controls (-2528.5959,739.9484) and
    (-2536.6623,754.6074) .. (-2513.4126,801.4702) .. controls
    (-2505.6121,817.1931) and (-2489.1197,819.0480) .. (-2489.1197,819.0480);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2678.9095,838.0904) .. controls (-2678.9095,838.0904) and
    (-2644.5456,834.1778) .. (-2622.7316,857.1328) .. controls
    (-2601.9209,879.0319) and (-2602.9935,893.7528) .. (-2602.9935,893.7528);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2483.0463,854.2031) .. controls (-2483.0463,854.2031) and
    (-2559.1374,846.6649) .. (-2581.7370,901.0770) .. controls
    (-2602.2085,950.3651) and (-2602.9935,974.3170) .. (-2602.9935,974.3170);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2871.7359,870.3161) .. controls (-2870.7711,869.1525) and
    (-2827.0211,1247.8097) .. (-2818.5948,1341.9827) .. controls
    (-2810.9750,1427.1384) and (-2806.5419,1795.5502) .. (-2800.3748,1900.0730) ..
    controls (-2794.9261,1992.4212) and (-2771.5268,2374.6695) ..
    (-2768.4901,2393.7119) .. controls (-2765.4536,2412.7543) and
    (-2754.8254,2609.0380) .. (-2751.7887,2617.8268);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2678.9095,980.1763) .. controls (-2678.9095,980.1763) and
    (-2631.0411,1389.6121) .. (-2623.4496,1418.9082);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2628.8048,1385.9269) .. controls (-2628.8048,1385.9269) and
    (-2610.5850,1482.6040) .. (-2609.0667,1567.5625) .. controls
    (-2607.5483,1652.5211) and (-2604.5118,1737.4798) .. (-2599.9568,1749.1983);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2604.9531,1720.9011) .. controls (-2604.9531,1720.9011) and
    (-2577.3350,1947.1375) .. (-2560.4806,2015.7925) .. controls
    (-2546.8157,2071.4550) and (-2542.2608,2134.4416) .. (-2542.2608,2172.5266) ..
    controls (-2542.2608,2210.6114) and (-2530.4731,2358.2978) ..
    (-2531.9915,2383.1994);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2538.8650,2356.2066) .. controls (-2538.8650,2356.2066) and
    (-2480.0096,2591.4605) .. (-2486.0830,2631.0101);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-3041.2077,2414.7021) .. controls (-3054.2936,2434.8853) and
    (-3031.8680,2407.7116) .. (-3129.2441,2358.7704) .. controls
    (-3230.1636,2311.1249) and (-3268.8138,2294.5525) .. (-3268.8138,2294.5525) ..
    controls (-3268.8138,2294.5525) and (-3404.6829,2250.5159) ..
    (-3532.9227,2323.5541) .. controls (-3655.5874,2393.4172) and
    (-3741.2037,2592.8549) .. (-3741.2037,2592.8549) .. controls
    (-3741.2037,2592.8549) and (-3818.5847,2877.4244) .. (-3837.8288,2945.0178) ..
    controls (-3848.2304,2981.5527) and (-3840.1002,3060.9338) ..
    (-3805.6203,3208.1039) .. controls (-3779.0209,3321.6384) and
    (-3693.6823,3405.2555) .. (-3580.1616,3479.4763) .. controls
    (-3502.0728,3530.5316) and (-2944.5827,3531.2650) .. (-2923.1102,3431.8308);
  \path[draw=black,line join=miter,line cap=butt,miter limit=4.00,line
    width=1.597pt] (-2293.9729,2520.3509) .. controls (-2293.9729,2520.3509) and
    (-2296.1202,2514.1362) .. (-2274.6480,2516.2078) .. controls
    (-2253.1755,2518.2793) and (-2229.5562,2468.5623) .. (-2229.5562,2468.5623) ..
    controls (-2229.5562,2468.5623) and (-2150.1087,2383.6289) ..
    (-2006.2446,2352.5557) .. controls (-1862.3805,2321.4825) and
    (-1778.6385,2340.1264) .. (-1660.5410,2375.3427) .. controls
    (-1542.4436,2410.5590) and (-1432.9350,2596.9980) .. (-1432.9350,2596.9980) ..
    controls (-1432.9350,2596.9980) and (-1311.3431,2684.0029) ..
    (-1339.2571,2996.8064) .. controls (-1367.1711,3309.6097) and
    (-1441.5238,3274.3934) .. (-1484.4685,3328.2536) .. controls
    (-1519.3282,3371.9740) and (-1649.8048,3452.5462) .. (-1832.3191,3442.1886) ..
    controls (-2014.8335,3431.8308) and (-2214.5256,3427.6877) ..
    (-2298.2673,3386.2569);
\end{scope}
\end{tikzpicture}%
}
% \end{egg}

% Custom variables for the frontpage
\def\thesisfaculty#1{\gdef\@thesisfaculty{#1}}
\def\thesisprogramme#1{\gdef\@thesisprogramme{#1}}

\newif\ifult@frontpage@image@issingle
\ult@frontpage@image@issinglefalse % Default to false

\let\ult@frontpage@image@single\@empty
\def\ThesisFrontpageImage#1{%
  \ult@frontpage@image@issingletrue
  \gdef\ult@frontpage@image@single{#1}%
}

\let\ult@frontpage@image@left\@empty
\def\ThesisLeftFrontpageImage#1{%
  \ult@frontpage@image@issinglefalse
  \gdef\ult@frontpage@image@left{#1}%
}

\let\ult@frontpage@image@right\@empty
\def\ThesisRightFrontpageImage#1{%
  \ult@frontpage@image@issinglefalse
  \gdef\ult@frontpage@image@right{#1}%
}

\def\ult@frontpage@pattern@left{%
  \AddToShipoutPicture*{%
    \put(0,0){%
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \ifult@phdthesisprofile
          \includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{pattern_yellow_left.pdf}%
        \else
          \includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{pattern_blue_left.pdf}%
        \fi
        \vfill
      }%
    }%
  }%
}

\def\ult@frontpage@pattern@right{%
  \AddToShipoutPicture*{%
    \put(0,0){%
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \ifult@phdthesisprofile
          \includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{pattern_yellow_right.pdf}%
        \else
          \includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio]{pattern_blue_right.pdf}%
        \fi
        \vfill
      }%
    }%
  }%
}

\def\ult@frontpage@customimage@tikz#1{%
  \AddToShipoutPicture*{%
    \put(25.5,28.3){
      \begin{tikzpicture}[radius=1cm,delta angle=180]
        #1%
      \end{tikzpicture}
    }%
  }%
}

% Defines tikz picture for custom frontpage images
\def\ult@frontpage@customimage@tile#1{%
  \path[fill overzoom image=#1]
    % (Lower left) -- (Lower right) -- (Upper right) -- (Upper left)
    (0,0) -- (19,0) -- ++(0,19.975) -- ++(-19,0) -- cycle;
}

\def\ult@frontpage@customimage@left{%
  \ult@frontpage@customimage@tikz{%
    % Note: "tile" makes sure we effectively blit the image in place without zooming or translating
    \path[fill tile picture=\ult@frontpage@customimage@tile{\ult@frontpage@image@left}]
      % (Lower left) -- (Upper left) -- (Upper right)
      (0,0) -- (0,19.975) -- ++(7.3,0) -- cycle;
  }%
}

\def\ult@frontpage@customimage@right{%
  \ult@frontpage@customimage@tikz{%
    % Note: "tile" makes sure we effectively blit the image in place without zooming or translating
    \path[fill tile picture=\ult@frontpage@customimage@tile{\ult@frontpage@image@right}]
      (0,0)% Make sure (0,0) is origo, instead of (0.355,0)
      % (Lower left) -- (Lower right) -- (Upper right) -- (Upper left)
      (0.355,0) -- (19,0) -- ++(0,19.975) -- ++(-11.29,0) -- cycle;
  }%
}

\def\ult@frontpage@customimage@single{%
  \ult@frontpage@customimage@tikz{%
    % Note: we use tile+overzoom here as well, to make sure image is zoomed and positioned
    % the same way as triangle (left image) and trapezoid (right image).
    % In other words, \ThesisFrontpageImage{example.jpg} will look identically to
    % \ThesisLeftFrontpageImage{example.jpg} + \ThesisRightFrontpageImage{example.jpg},
    % except for the white diagonal that separates the left and right image.
    \path[fill tile picture=\ult@frontpage@customimage@tile{\ult@frontpage@image@single}]
      % (Lower left) -- (Lower right) -- (Upper right) -- (Upper left)
      (0,0) -- (19,0) -- ++(0,19.975) -- ++(-19,0) -- cycle;
  }%
}

% Error if \maketitle is used without defining \thesisfaculty{} and \thesisprogramme{}
\def\@thesisfaculty{\ult@critical@error{No \noexpand\thesisfaculty given}}
\def\@thesisprogramme{\ult@critical@error{No \noexpand\thesisprogramme given}}

% Use English as default
% Set the topleft frontpage logo to English
\gdef\ult@frontpage@logo{Logo_eng_pos.pdf}
% Set the pattern, depending on PHD or master, which contains the UiT logo with the English language.
\ifult@phdthesisprofile
  \gdef\ult@frontpage@profile{phd_profile_en.pdf}
\else
  \gdef\ult@frontpage@profile{master_profile_en.pdf}
\fi

% norsk language - changes the frontpage logos and profile to the norwegian language
\iflanguage{norsk}{%
  % Set the topleft frontpage logo to Norwegian
  \gdef\ult@frontpage@logo{Logo_norsk_pos.pdf} %
  % Set the pattern, depending on PHD or master, which contains the UiT logo with the Norwegian language.
  \ifult@phdthesisprofile
    \gdef\ult@frontpage@profile{phd_profile_nor.pdf}
  \else
    \gdef\ult@frontpage@profile{master_profile_nor.pdf}
  \fi
}{}

% samin language - changes the frontpage logos and profile to the Sami language
% samin is not a standard language in babel - therefore, it yields the error "You haven't defined the language samin yet"
% if used like \iflanguage{samin}{...}{}. We thus switch on the \languagename macro provided by babel.
\def\languagetemp{samin}
\ifx\languagename\languagetemp
  % Set the topleft frontpage logo to Sami
  \gdef\ult@frontpage@logo{Logo_samisk_pos.pdf}
  % Set the pattern, depending on PHD or master, which contains the UiT logo with the Sami language.
  \ifult@phdthesisprofile
    \gdef\ult@frontpage@profile{phd_profile_sami.pdf}
  \else
    \gdef\ult@frontpage@profile{master_profile_sami.pdf}
  \fi
\fi

\newif\ifult@has@titlepage
\ult@has@titlepagefalse % Default to false

\newif\ifult@titlepage@was@not@first@page
\ult@titlepage@was@not@first@pagefalse % Default to false

%%%%%%%%%%% COPYRIGHT PAGE %%%%%%%%%%%

\newbox\ult@copyright@page@box
\newbox\ult@tmp@shipoutbox

\fancypagestyle{ult-copyrightpage}{%
  \fancyhf{}%
  \fancyfoot[C]{%
    \color[cmyk]{0.3,0.3,0.3,0.9}%
    This thesis document was typeset using the \emph{UiT Thesis L\kern-.28em\raise.35ex\hbox{\textsc{a}}\kern-.12emT\kern-.12em\lower.38ex\hbox{E}\kern-.03emX Template}.\\
    \textcopyright{} \the\year{} -- \url{http://github.com/egraff/uit-thesis}%
  }%
}

\def\ult@copyright@page@contents{%
  \thispagestyle{ult-copyrightpage}%
  \null\vfill
}

\ifcsname tikzexternalrealjob\endcsname\else
  \ifult@copyright@disabled
    \ult@warning@nl{%
      You have disabled the copyright notice.\MessageBreak
      THIS MAY BE IN VIOLATION OF THE\MessageBreak
      LICENCE AGREEMENT!\MessageBreak
      See http://github.com/egraff/uit-thesis for more info%
    }

    \AfterBeginDocument{%
      \AtBeginShipoutNext{%
        \ifult@has@titlepage\else
          \global\ult@titlepage@was@not@first@pagetrue
        \fi
      }%
    }
  \else
    % Copyright page
    \AfterBeginDocument{%
      \pagenumbering{alph}%
      \setcounter{page}{2}%
      %
      % Now, this may seem counter-intuitive (and it is!!), but this page label
      % will be associated with the first actual page to be shipped out!
      \renewcommand\thepage{A}%
      %
      % Record the following copyright page in \ult@copyrightpagebox
      \AtBeginShipoutNext{%
        \global\setbox\ult@copyright@page@box=\copy\AtBeginShipoutBox
        \AtBeginShipoutDiscard
      }%
      %
      % Start copyright page
      %
      \ult@copyright@page@contents
      \cleardoublepage
      %
      % End copyright page - setup first "normal" page
      %
      \pagenumbering{arabic}%
      \setcounter{page}{1}%
      %
      % Setup hook for first page
      \AtBeginShipoutNext{%
        \ifult@has@titlepage
          % First, shipout the title page
          % Note: we have to restore \protect first, which was overridden in \AtBegShi@Output.
          % Then, after shipout, we use LaTeX' \set@typeset@protect to change \protect the way
          % that was already done in \AtBegShi@Output.
          %
          \let\protect\noexpand
          \AtBeginShipoutOriginalShipout\box\AtBeginShipoutBox
          \set@typeset@protect
          %
          % Then, setup shipout of copyright page
          %
          \setbox\AtBeginShipoutBox=\box\ult@copyright@page@box
          %
          % Make sure title page is displayed as recto page
          % (but only if using two-page layout)
          %
          \def\ult@tmp@pdfpagelayout{TwoPageLeft}%
          \ifx\@pdfpagelayout\ult@tmp@pdfpagelayout
            % We cannot use hyperref to change page layout, because we're after preamble.
            % So we use "direct" PDF command instead.
            \pdfcatalog{/PageLayout/TwoPageRight}%
          \fi
        \else
          % First page wasn't title page, so we insert copyright page before first page.
          \global\ult@titlepage@was@not@first@pagetrue
          %
          % First, save the current first page.
          \setbox\ult@tmp@shipoutbox=\copy\AtBeginShipoutBox
          %
          % Then, we shipout the copyright page.
          % Note: we have to restore \protect first, which was overridden in \AtBegShi@Output.
          % Then, after shipout, we use LaTeX' \set@typeset@protect to change \protect the way
          % that was already done in \AtBegShi@Output.
          %
          \let\protect\noexpand
          \AtBeginShipoutOriginalShipout\box\ult@copyright@page@box
          \set@typeset@protect
          %
          % Restore original first page, so it will be shipped out too!
          %
          \setbox\AtBeginShipoutBox=\box\ult@tmp@shipoutbox
          %
          % Make sure copyright page is displayed as verso page
          % (but only if using two-page layout)
          %
          \def\ult@tmp@pdfpagelayout{TwoPageRight}%
          \ifx\@pdfpagelayout\ult@tmp@pdfpagelayout
            % We cannot use hyperref to change page layout, because we're after preamble.
            % So we use "direct" PDF command instead.
            \pdfcatalog{/PageLayout/TwoPageLeft}%
          \fi
        \fi
      }%
    }
  \fi
\fi

%%%%%%%%%%% END COPYRIGHT PAGE %%%%%%%%%%%

\renewenvironment{titlepage}
  {%
    % If we have already shipped out first page, produce error!
    \ifult@titlepage@was@not@first@page
      \ClassError{uit-thesis}{Title page must be first page}\@ehd
    \fi
    %
    \ult@has@titlepagetrue
    % Fix PDF page numbering (title page must _not_ get page number 1, else we have two pages with that number)
    \pagenumbering{Alph}%
    \setcounter{page}{1}%
    %
    \ifult@copyright@disabled\else
      % Now, this may seem counter-intuitive (and it is!!), but this page label
      % will actually be associated with the copyright page!
      \renewcommand\thepage{B}%
    \fi
    %
    \cleardoublepage
    \newpage
    \thispagestyle{empty}%
    \setcounter{page}\@ne
  }%
  {%
    \newpage
    %
    \ifult@copyright@disabled\else
      \clearpage
      \pagenumbering{Alph}%
      \setcounter{page}{3}%
    \fi
  }

\renewcommand\maketitle{%
  % Set custom geometry for the frontpage text
  \newgeometry{top=16.5mm,bottom=10mm,right=12mm,left=59mm}%
  %
  \begin{titlepage}%
  %
  %\begin{egg}%
  \IfEndWith{\ult@author}{arlberq}{%
    \AddToShipoutPicture*{%
      \put(140,50){%
        \begingroup
          \printthed
        \endgroup
      }%
    }%
  }{%
  %\end{egg}
  }%
  %
  %%% Front page pattern / images
  \ifult@frontpage@image@issingle
    \ult@frontpage@customimage@single
  \else
    %
    % Left front page image
    %
    \ifx\ult@frontpage@image@left\@empty
      \ult@frontpage@pattern@left
    \else
      \ult@frontpage@customimage@left
    \fi
    %
    % Right front page image
    %
    \ifx\ult@frontpage@image@right\@empty
      \ult@frontpage@pattern@right
    \else
      \ult@frontpage@customimage@right
    \fi
  \fi
  %
  % UiT Logo (Hugin & Munin)
  %
  \AddToShipoutPicture*{%
    \put(221,-350.5){% This is the correct position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \includegraphics[width=24mm,height=24mm,keepaspectratio=false]{\ult@frontpage@logo}%
        \vfill
      }%
    }%
  }%
  %
  % UiT profile ("navnetrekk")
  %
  \AddToShipoutPicture*{%
    \put(-230.5,339.5){% This is the correct position
      \parbox[b][\paperheight]{\paperwidth}{%
        \vfill
        \centering
        \includegraphics[width=90mm,height=90mm,keepaspectratio=false]{\ult@frontpage@profile}%
        \vfill
      }%
    }%
  }%
  %
  % Faculty / department
  %
  \begingroup
    \vskip \z@
    \fontsize{10.3pt}{15pt}\usefont{T1}{fos}{l}{n}
    \noindent\@thesisfaculty
    \vskip -\parskip
  \endgroup
  %
  % Thesis title
  %
  \begingroup
    \vskip 2\baselineskip
    \microtypesetup{protrusion=false,spacing=false}%
    \RaggedRight
    \fontsize{12.5pt}{15pt}\usefont{T1}{fos}{b}{n}
    \vspace*{-\baselineskip}%
    \noindent\@title
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}%
  \endgroup
  %
  % Thesis subtitle
  %
  \ifdefined\@subtitle
    \ifx\@subtitle\@empty\else
      \begingroup
        \vskip \ht\strutbox
        \microtypesetup{protrusion=false,spacing=false}%
        \RaggedRight
        \fontsize{11.4pt}{14pt}\usefont{T1}{fos}{l}{it}
        \vspace*{-\baselineskip}%
        \noindent\@subtitle
        \vskip -\parskip
        \normalsize\normalfont\selectfont\vspace*{\baselineskip}%
      \endgroup
    \fi
  \fi
  %
  % Separation line
  %
  \begingroup
    \vspace*{2pt}%
    \fontsize{12.5pt}{15pt}\usefont{T1}{fos}{l}{it}
    \vspace*{-\baselineskip}%
    \noindent ---%
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}%
  \endgroup
  %
  % Name of author
  %
  \begingroup
    \fontsize{10.3pt}{13pt}\usefont{T1}{fos}{sb}{n}
    \vspace*{-\baselineskip}%
    \noindent\@author
    \vskip -\parskip
    \normalsize\normalfont\selectfont\vspace*{\baselineskip}%
  \endgroup
  %
  % Thesis description one-line / study program / month and year
  %
  \begingroup
    \fontsize{10.3pt}{13pt}\usefont{T1}{fos}{l}{it}
    \vspace*{-\baselineskip}%
    \noindent\@thesisprogramme
    \vskip -\parskip
  \endgroup
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


%:-------------------------- Convenient macros and definitions -----------------------

\def \const #1{\penalty 100 \hbox{\texttt{#1}}}

% todo macro
\newcommand{\todo}[1]{\textcolor{blue}{TODO:\\#1}}
% WIP macro
\newcommand{\wip}[1]{\textcolor{red}{W.I.P:\\#1}}

\let\ult@save@onefilewithoptions\@onefilewithoptions
\def\@onefilewithoptions#1[#2][#3]#4{%
  % Note: the \AtBeginDocument is set to \@firstofone in the \document macro.
  % It can therefore be used to test if command is used before or after \begin{document}...\end{document},
  % that is, if we're in the preamble or not. Since \@onefilewithoptions is defined with \@onlypreamble in
  % the LaTeX kernel, we don't want to take any action if we're not in the preamble, since it's an error anyways.
  \ifx\AtBeginDocument\@firstofone\else
    % We're in the preamble
    %
    % Test if the package is allowed
    \ifcsname ult@disallowpackage@#1\endcsname
      \begingroup
        \expandafter\let\expandafter\ult@tmp@disallowpackagereason\csname ult@disallowpackage@#1\endcsname
        \ifx\ult@tmp@disallowpackagereason\@empty
          \ult@critical@error{The use of package #1 has been disallowed by the uit-thesis document class}%
        \else
          \ult@critical@error{The use of package #1 has been disallowed by the uit-thesis document class.^^J^^J\ult@tmp@disallowpackagereason^^J}%
        \fi
      \endgroup
    \else
      % Warn if package hasn't been previously loaded
      \@ifpackageloaded{#1}{}{\ult@warning@nl{Are you sure you are allowed to use the #1 package?}}%
    \fi
  \fi
  \ult@save@onefilewithoptions#1[{#2}][{#3}]#4%
}

% That's all, folks!
\endinput
