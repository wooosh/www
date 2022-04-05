# NOT designed to be used for untrusted input
proc html-escape input {
  set entities {{"} &quot; ' &apos; & &amp; < &lt; > &gt;}
  return [string map $entities $input]
}

# version of markup::render that only returns the body
proc html-markup {contents} {
  return [dict get [markup::render $contents] Body]
}

proc html-doc {title desc contents} {
  return [concat {
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" type="image/x-icon" href="/icon.png">
        <title>} $title {</title>
        <meta name="description" content="} $desc {"/>
        <link rel="stylesheet" href="/style.css" type="text/css" />
        <link rel="alternate" type="application/rss+xml" href="/feed.rss" title="wooo.sh RSS">
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
  append html {<h1 class='hline'>wooo.sh</h1>}
  append html [html-markup {
    txt {
      Student, 17.

      You can find me on [github](https://github.com/wooosh).
    }

    label "Topics of Interest:"
    txt {
      * C/C++
      * Software Optimization
        * Vectorization
        * Branchless Programming
        * Bitwise Manipulation
      * Computing History
      * Numerical Methods
    }
  }]

  append html {<strong>Writing:</strong> <a type='application/rss+xml' href='/feed.rss'>(RSS Feed)</a>}
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

  append html [html-markup {
    label "Blogs I Follow:"
    txt {
      * [cbloom](http://cbloomrants.blogspot.com/)
      * [ryg](https://fgiesen.wordpress.com/)
      * [Sean Barrett](https://nothings.org/)
      * [Wojciech Muła](http://0x80.pl/)
    }
  }]

  return [html-doc "wooo.sh" "Home Page" $html]
}

proc html-article {filePath article} {
  dict with article {
    append html {
      <header>
        <a href='https://wooo.sh'>[https://wooo.sh/]</a>
        <a type='application/rss+xml' href='/feed.rss'>[rss]</a>
        
        <span>[} [html-escape $Date] {]</span>
      </header>
      <h1 class='title'>} [html-escape $Title] {</h1>

      <p>} $Description {</p>

      <p><a href='https://github.com/wooosh/blog/blob/master/} $filePath {'>Article Source Code</a></p>
      <div class='tableOfContents'>
        <strong>Contents:</strong>
        } $TableOfContents {
      </div>
      } $Body {

      <noscript>
        <div class='note'>
        Unfortunately, inline comments are provided using utteranc.es, which requires JavaScript to function.
        <br>
        You can either view and leave comments on <a href='https://github.com/wooosh/blog/issues'>github</a>, or enable client-side JavaScript for this website.
        </div>
      </noscript>
      <script src="https://utteranc.es/client.js"
        repo="wooosh/blog"
        issue-term="title"
        theme="preferred-color-scheme"
        crossorigin="anonymous"
        async>
      </script>
    }

    return [html-doc $Title $Description $html]
  }
}