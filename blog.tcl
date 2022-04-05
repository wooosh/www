source markup.tcl
source template.tcl

proc minify filepath {
  exec minify -o $filepath $filepath
}

# online path for articles
set ArticlesPath "articles"

set SrcDir    "[pwd]/pages"
set BuildDir  "[pwd]/build"
set OutputDir "[pwd]/docs"

# clean first
file delete -force -- $BuildDir $OutputDir
file mkdir $BuildDir $OutputDir
file mkdir "$OutputDir/$ArticlesPath"

file copy CNAME "$OutputDir/CNAME"
file copy icon.png "$OutputDir/icon.png"
file copy style.css "$OutputDir/style.css"
minify "$OutputDir/style.css"

cd $BuildDir

set articles {}

set articleFiles [glob -directory $SrcDir "$ArticlesPath/*.page.tcl"]
foreach f $articleFiles {
  set fp [open $f r]
  set src [read $fp]
  close $fp

  # get path of resulting html & images
  # abc/xyz/myarticle.page.tcl -> articles/myarticle.html
  set articleName [file rootname [file rootname [file tail $f]]]
  set articlePath "$ArticlesPath/$articleName.html"
  global AssetPrefix
  set AssetPrefix "$ArticlesPath/$articleName"

  set article [dict create Title "Untitled" Date "Unknown"\
                           Path $articlePath Description {}\
                           Contents "Empty Page" ]
  dict with article $src

  set article [dict merge [markup::render [dict get $article Contents]] $article]

  set fp [open "$OutputDir/$articlePath" w]
  puts $fp [html-article pages/$ArticlesPath/[file tail $f] $article]
  close $fp
  minify "$OutputDir/$articlePath"

  lappend articles $article
}

# sort articles 
proc compareArticleDate {a b} {
  # this works because the date format is ISO8601
  return [string compare [dict get $a Date] [dict get $b Date]]
}

set articles [lsort -decreasing -command compareArticleDate $articles]

set fp [open "$OutputDir/index.html" w]
puts $fp [html-index $articles]
close $fp
minify "$OutputDir/index.html"

# write rss feed
set fp [open "$OutputDir/feed.rss" w]

puts $fp {<?xml version="1.0"?>
  <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
      <title>wooo.sh</title>
      <link>https://wooo.sh</link>
      <description>wooosh's homepage and blog</description>
      <atom:link href="http://wooo.sh/feed.rss" rel="self" type="application/rss+xml" />
}

foreach article $articles {
  dict with article {
    append item {
      <item>
        <title>} $Title {</title>
        <pubDate>} [clock format [clock scan $Date] -format "%a, %d %b %Y 00:00:00 EST"] {</pubDate>
        <guid>https://wooo.sh/} $Path {</guid>
        <link>https://wooo.sh/} $Path {</link>
        <description>} $Description {</description>
      </item>
    }

    puts $fp $item
  }
}

puts $fp {
    </channel>
  </rss>
}

close $fp
exec minify --type xml -o "$OutputDir/feed.rss" "$OutputDir/feed.rss"