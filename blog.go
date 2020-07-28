package main

import (
    "io/ioutil"
    "bufio"
    "os"
    "fmt"
    "bytes"
    "text/template"
)

func check(e error) {
    if e != nil {
        panic(e)
    }
}

type page struct {
    Title string
    Date string
    Content string
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

    var p page
    for _, fileInfo := range files {
        fmt.Println(fileInfo.Name()) 

        file, err := os.Open("pages/" + fileInfo.Name())
        outfile, err := os.Create("docs/" + fileInfo.Name())
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
    }    
}
