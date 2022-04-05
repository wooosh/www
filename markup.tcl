namespace eval markup {
  namespace export render

  variable TableOfContents
  variable Body
  variable SectionDepth
  variable ListDepth
  variable HeadingIndex
  variable LatexId

  proc render {contents} {
    variable Body
    variable TableOfContents
    variable SectionDepth
    variable ListDepth
    variable LatexId

    # reset existing state
    set TableOfContents {}
    set Body {}
    set SectionDepth 1
    set ListDepth 1
    set HeadingIndex 0
    set LatexId 0

    eval $contents
    append TableOfContents </ol>

    return [dict create TableOfContents $TableOfContents Body $Body]
  }

  # utility
  proc with-cmd {cmd in} {
    set chan [open "|$cmd" r+]
    puts $chan $in
    close $chan write
    set out [read $chan]
    close $chan
    return $out
  }

  proc trim-indentation txt {
    set txt [string trim $txt "\n"]
    regexp -indices "( *)(\\S)" $txt indentlen b
    scan $indentlen "%d %d" - indentlen
    if {$indentlen <= 0} {return $txt}
    set txt [regsub -all -line "^ {0,$indentlen}" $txt {}]
    # this shouldn't be needed?
    set txt [string trim $txt "\n"]
    return $txt
  }

  # formatting objects
  proc section {title contents} {
    variable Body
    variable TableOfContents
    variable SectionDepth
    variable ListDepth
    variable HeadingIndex

    
    incr SectionDepth
    if {$ListDepth < $SectionDepth} {
      append TableOfContents <ol>
      incr ListDepth
    }

    incr HeadingIndex
    append id heading $HeadingIndex

    append TableOfContents "<li><a href='#$id'>$title</a>"
    # TODO: put the id on the section
    append Body "<h$SectionDepth id='$id'><a href='#$id'>$title</a></h$SectionDepth>"

    uplevel $contents

    append TableOfContents </li>

    if {$ListDepth > $SectionDepth && $ListDepth != 1} {
      set ListDepth $SectionDepth
      append TableOfContents </ol>
    }
    incr SectionDepth -1
  }

  proc txt contents {
    variable Body
    append Body [with-cmd cmark [trim-indentation $contents]]
  }

  proc details {summary contents} {
    variable Body
    append Body {
      <details>
        <summary>} $summary {</summary>
    }

    uplevel $contents

    append Body "</details>"
  }

  proc code {lang contents} {
    variable Body
    append Body [with-cmd "chroma --html --html-only --lexer=$lang" [trim-indentation $contents]]
  }

  proc label {contents} {
    variable Body
    append Body "<strong class='label'>" $contents "</strong>"
  }

  proc pre {contents} {
    variable Body
    append Body "<pre>" [trim-indentation $contents] "</pre>"
  }

  proc note {contents} {
    variable Body
    append Body "<div class='note'>" [trim-indentation $contents] "</div>"
  }

  proc latex contents {
    variable Body
    variable LatexId

    append src {
      \documentclass{article}
      \usepackage{amsmath}
      \usepackage{amssymb}
      \usepackage{amsfonts}

      \thispagestyle{empty}
      \begin{document}
      \begin{align*}
      } [trim-indentation $contents] {
      \end{align*}
      \end{document}
    }

    exec latex << $src
    exec dvisvgm --no-fonts -c 1.5 texput.dvi 2>/dev/null

    global OutputDir
    global AssetPrefix
    exec mv texput.svg "$OutputDir/${AssetPrefix}_latex$LatexId.svg"
    #exec dvipng -T tight -bg Transparent -otexput.png texput.dvi

    append Body "<img src='/${AssetPrefix}_latex$LatexId.svg'>"
    incr LatexId
  }
}