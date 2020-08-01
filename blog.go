package main

// TODO: remove newline from filenames

import (
    "io/ioutil"
    "bufio"
    "os"
    "fmt"
    "bytes"
    "text/template"
    "sort"
    "strings"
)

func check(e error) {
    if e != nil {
        panic(e)
    }
}

type Page struct {
    Title string
    Date string
    Filename string
    Content string
}

type Wrapper struct {
    Pages []Page
}

func getLine(r *bufio.Reader) string {
    str, err := r.ReadString('\n')
    check(err)
    return str
}

func main() {
    _ = os.Mkdir("docs", 0777)
    files, err := ioutil.ReadDir("pages")
    check(err)

    tmpl, err := template.ParseFiles("page.tmpl")
    check(err)
    indexTmpl, err := template.ParseFiles("index.tmpl")
    check(err)
    rssTmpl, err := template.ParseFiles("rss.tmpl")
    check(err)

    var pages []Page
    var p Page
    for _, fileInfo := range files {
        fmt.Println(fileInfo.Name()) 
        p.Filename = fileInfo.Name() + ".html"

        file, err := os.Open("pages/" + fileInfo.Name())
        outfile, err := os.Create("docs/" + fileInfo.Name() + ".html")
        check(err)

        r := bufio.NewReader(file)
        p.Title = getLine(r)
        p.Date = getLine(r)
   
        if getLine(r) != "\n" {
            panic("Expected empty line after post metadata in " + fileInfo.Name())
        }

        // Render
        buf := new(bytes.Buffer)
        buf.ReadFrom(r)
        p.Content = string(renderPage(buf.Bytes()))

        err = tmpl.Execute(outfile, p)
        check(err)

        file.Close()
        pages = append(pages, p)
    }

    sort.Slice(pages, func(i, j int) bool {
        v := strings.Compare(pages[i].Title, pages[j].Title);
        return v != 1
    })    
    
    indexFile, err := os.Create("docs/index.html")
    check(err)
    indexTmpl.Execute(indexFile, Wrapper{pages})
    indexFile.Close()
    
    rssFile, err := os.Create("docs/feed.rss")
    check(err)
    rssTmpl.Execute(rssFile, Wrapper{pages})
    rssFile.Close()
}
