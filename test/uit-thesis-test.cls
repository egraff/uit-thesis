\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{uit-thesis-test}

\def\baseclass{uit-thesis}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\baseclass}}

% Now, process!
\ProcessOptions\relax
\LoadClass{\baseclass}

% That's all, folks!
\endinput
