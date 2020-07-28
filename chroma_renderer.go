package main
// https://eddieflores.com/tech/blackfriday-chroma/

import (
	"io"

	"github.com/alecthomas/chroma"
	"github.com/alecthomas/chroma/formatters/html"
	"github.com/alecthomas/chroma/lexers"
	"github.com/alecthomas/chroma/styles"
	"gopkg.in/russross/blackfriday.v2"
)

func renderPage(b []byte) []byte {
    cr := NewChromaRenderer("bw") // TODO: store as global
    return blackfriday.Run(b, blackfriday.WithRenderer(cr))
}

func NewChromaRenderer(theme string) *ChromaRenderer {
	return &ChromaRenderer{
		html:  blackfriday.NewHTMLRenderer(blackfriday.HTMLRendererParameters{}),
		theme: theme,
	}
}

type ChromaRenderer struct {
	html  *blackfriday.HTMLRenderer
	theme string
}

func (r *ChromaRenderer) RenderNode(w io.Writer, node *blackfriday.Node,
	entering bool) blackfriday.WalkStatus {
	switch node.Type {
	case blackfriday.CodeBlock:
		var lexer chroma.Lexer
		lang := string(node.CodeBlockData.Info)
		if lang != "" {
			lexer = lexers.Get(lang)
		} else {
			lexer = lexers.Analyse(string(node.Literal))
		}
		if lexer == nil {
			lexer = lexers.Fallback
		}
		style := styles.Get(r.theme)
		if style == nil {
			style = styles.Fallback
		}
		iterator, err := lexer.Tokenise(nil, string(node.Literal))
		if err != nil {
			panic(err)
		}
		formatter := html.New()
		err = formatter.Format(w, style, iterator)
		if err != nil {
			panic(err)
		}
		return blackfriday.GoToNext
	}
	return r.html.RenderNode(w, node, entering)
}

func (r *ChromaRenderer) RenderHeader(w io.Writer, ast *blackfriday.Node) {}
func (r *ChromaRenderer) RenderFooter(w io.Writer, ast *blackfriday.Node) {}
