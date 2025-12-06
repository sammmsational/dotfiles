
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified from: https://gitlab.com/fportales/fphw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Identification

\NeedsTeXFormat{LaTeX2e} % we need to have LaTeX2e for this to compile
\ProvidesClass{thmhw}[2025/12/06]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Preliminary declarations:
%%%% These are some commands where we declare new commands for the class

% We define the macro for the name of the professor
\newcommand{\professor}[1]{ \newcommand{\professorloc}{#1} }
% We define the macro for the name of the course
\newcommand{\class}[1]{ \newcommand{\classlocal}{#1} }
% We define the macro for the name of the institution
\newcommand{\institute}[1]{ \newcommand{\instituteloc}{#1} }

% Header and footers, we will use the titles also
\RequirePackage{fancyhdr}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Options
%%%% We now pass the options of the class

% Two Columns are difficult to read and grade, we will not use them
\DeclareOption{twocolumn}{\OptionNotUsed}

% Two sided paper are difficult to read and grade, we will not use them
\DeclareOption{twoside}{\OptionNotUsed}

\PassOptionsToClass{a4paper}{article}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Bulk Declarations
%%%% Here we do more declarations and call other files

% we need to load
\LoadClass{article}

% we will modify sections, subsections and sub subsections
\RequirePackage{titlesec}
% Modification of section
\titleformat{\section}[block]{\normalsize\bfseries\filcenter}{\thesection.}{.3cm}{}

% modification of subsection and sub sub section
\titleformat{\subsection}[runin]{\bfseries}{ \thesubsection.abc}
{1mm}{}[\quad]
\titleformat{\subsubsection}[runin]{\bfseries\itshape}{ \thesubsubsection.}
{1mm}{}[\quad]

% Geometry lets us modify the sizes of the document nicely
\RequirePackage{geometry}
% Decent margins for the documents, as it is meant to be printed
\geometry{left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm}

\fancyhead{}
\fancyfoot{}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0.4pt} % we want rules
\renewcommand{\footrulewidth}{0.4pt}
\fancyhead[RO] {\footnotesize\thepage}
\fancyhead[LO]
{\footnotesize{\ifx\classlocal\undefined{}\else\itshape\classlocal{}
--{} \fi}\makeatletter\@title\makeatother }
\fancyfoot[RO] {\footnotesize\itshape\makeatletter\@author\makeatother}

% New title style for the document
\renewcommand{\maketitle}{%
  \thispagestyle{plain}
  \begin{center}
    % INSTITUTE
    \ifx\instituteloc\undefined{}\else
    {\scshape \instituteloc}
    \fi
    \vspace{10pt}

    % TITLEBOX
    \hrule
    \vspace{8pt}
    {\LARGE\bfseries\@title} \\[5pt]
    {\itshape\@author}
    \vspace{8pt}
    \hrule
    \vspace{4pt}

    % DATE AND PROFESSOR
    \ifx\classlocal\undefined
    \makebox[\textwidth][r]{\footnotesize\itshape\@date}
    \else
    \makebox[\textwidth]{
      \footnotesize
      {\classlocal}
      \ifx\professorloc\undefined\else
      -- {\itshape \professorloc}%
      \fi
      \hfill
      \itshape\@date
    }\\[8pt]%
    \fi

  \end{center}
}

% definition of the "problem" environment
\newsavebox{\problembox}
\newenvironment{problem}
{
  \begin{center}
    \begin{lrbox}{\problembox}
    \begin{minipage}{.98\textwidth}}
      {
      \end{minipage}
    \end{lrbox}\fbox{\usebox{\problembox}}
\end{center} }

%%% OTHER STUFF
\setlength{\parskip}{.5em}
\setlength{\headheight}{15pt}
\setlength{\parindent}{0pt}

%%% We finish the class with this command
\endinput
