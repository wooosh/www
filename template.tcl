# NOT designed to be used for untrusted input
proc html-escape input {
  set entities {{"} &quot; ' &apos; & &amp; < &lt; > &gt;}
  return [string map $entities $input]
}

#"

proc html-doc {title desc contents} {
  return [concat {
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>} $title {</title>
        <meta name="description" content="} $desc {"/>
        <link rel="stylesheet" href="/style.css" type="text/css" />
      </head>
      <body>
        <main>
          } $contents {
        </main>
      </body>
    </html>
  }]
}

proc html-index articles {
  append html {
    <h1 class='hline'>wooo.sh</h1>
    <p>Student, 17.</p>

    <p>You can find me on <a href="https://github.com/wooosh">github</a>.</p>

    <strong>Topics of interest:</strong>
    <ul>
      <li>C/C++</li>
      <li>Software Optimization<ul>
        <li>Vectorization</li>
        <li>Branchless Programming</li>
        <li>Bitwise Manipulation</li>
      </ul></li>
      <li>Computing History</h1>
      <li>Numerical Methods</li>
    </ul>

    <strong>Articles</strong>
  }

  foreach article $articles {
    dict with article {
      append html {
        <div>
          <span class='articledate'>} $Date {</span>
          <span><a href='/} $Path {'>} $Title {</a></span>
        </div>
      }
    }
  }


  return [html-doc "wooo.sh" "Home Page" $html]
}

proc html-article article {
  dict with article {
    append html {
      <a href='https://wooo.sh' class='home'>[https://wooo.sh/]</a>
      <span class='date'>[} [html-escape $Date] {]</span>
      <h1 class='title'>} [html-escape $Title] {</h1>

      <p>} $Description {</p>

      <div class='tableOfContents'>
        <strong>Contents:</strong>
        } $TableOfContents {
      </div>
      } $Body {
    }

    return [html-doc $Title $Description $html]
  }
}