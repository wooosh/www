source markup.tcl
source template.tcl

# online path for articles
set ArticlesPath "articles"

set SrcDir    "[pwd]/pages"
set BuildDir  "[pwd]/build"
set OutputDir "[pwd]/docs"

# clean first
file delete -force -- $BuildDir $OutputDir
file mkdir $BuildDir $OutputDir
file mkdir "$OutputDir/$ArticlesPath"

file copy style.css "$OutputDir/style.css"
file copy CNAME "$OutputDir/CNAME"

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
  puts $fp [html-article $article]
  close $fp

  lappend articles $article
}

set fp [open "$OutputDir/index.html" w]
puts $fp [html-index $articles]
close $fp

