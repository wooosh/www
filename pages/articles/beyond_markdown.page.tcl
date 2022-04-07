set Title "Beyond Markdown"
set Date 2022-04-07
set Description "What works well about markdown, what does not, and how to move forward, from the perspective of a personal blog."

set Contents {
  section "Markdown is a Near Universal Format" {
    txt {
      Markdown gets a lot right as a [self-described "text to HTML tool"](https://daringfireball.net/projects/markdown/):

      * Simple, plain text, WYSIWYG format that supports progressive enhancement
      * It supports a reasonable set of HTML features with a much more concise syntax
      * It's a near universal format used to allow a reasonable amount of styling for user provided content while retaining a consistent site theme in forums, issue trackers, chat apps, etc

      This works *extremely* well in most cases, for both large platforms and many personal sites.

      However, as *a personal authoring tool*, it can start to fall apart and introduce friction for the following reasons, in ascending priority:

      1. It's missing a couple of relatively common HTML features:
          * Underlining, Strikethrough, Checklists
          * It was released prior to HTML5, so you also miss out on collapsible `<summary>` blocks, as well as `<figure>` blocks for images with captions. 
      2. Encoding article metadata and semantic structure
      3. Composability with other authoring tools

      #1 and #2 are usually relatively easy to solve in practice:
      
      * Most software uses their own "flavor" of markup to fill in the gaps in the original 2004 specification
          * [GitHub flavored markdown](https://github.github.com/gfm/), [Discord](https://support.discord.com/hc/en-us/articles/210298617-Markdown-Text-101-Chat-Formatting-Bold-Italic-Underline-), etc
      * Online platforms generally already have metadata stored in their database, so there is no reason to explicitly specify metadata as an end user
      * Static site generators usually use some form of header block and scrape the headings to build a table of contents

      #3 is by far the biggest issue for me, however. As an author of a personal website, I want to be able to easily integrate other authoring tools (LaTeX, GraphViz, plotting tools, etc) with little friction.

      Using other tools from "canonical" markdown is somewhat of a pain, generally forcing you to move embedded content out to other files, and then compile your collection of documents and link everything together manually.

      Some platforms have added inline support for other tools in their own flavor of markdown, notably [Github adding support for Mermaid](https://github.blog/2022-02-14-include-diagrams-markdown-files-mermaid/).

      While extensibility is also important to me, I personally find composability to be a much larger issue.
    }
  }

  section "'N+1 Standards', Other tools" {
    # N+1 *competing* standards
    # not a protocol
    # the bottom line has moved above plaintext, and you can still export plain text documents without resorting to markdown
    txt {
      One thing that I think is especially important to address here, is that using your own format for authoring does not suffer the same issues associated with other types of new standards.
    }

    figure "xkcd 927: Standards" "https://imgs.xkcd.com/comics/standards.png"

    txt {
      The reasoning for this is that individual authoring tools are not *competing*. I don't expect (or even want) the format I use for this site to become adopted by anyone else. This enables me to move quickly, and tailor it to my specific needs on a whim.

      Moving the bottom line above a plaintext format for the sources of a blog does not impact anyone but the author, because it's not a protocol (especially given that every site has their own flavor). The final output is what really matters, because that's what people are going to see. There is nothing stopping you from providing a rendered markdown version of a document, while retaining the ergonomic benefits of your own format.

      I'm aware of tools such as R-Markdown, which seem relatively streamlined, but they generally seem much more complex to modify than a solution I put together myself. Retaining the ability to change a format to suit my tastes is very important, instead of being continually frustrated with a format I have little power over.
    }
  }

  section "Moving Forward" {
    txt {
      I see two main ways to move forward from markdown, syntax wise:

      1. Use a primarily text format, with an escape sequence of some kind to embed source code of other tools.
      2. Use a structured format, and explicitly denote text sections.

      While I use #2 for ease of implementation, I believe it has some other merits:

      * Semantic information about document structure is explicit
      * I find that indenting each section as a block makes it a lot easier to edit and read compared to a flat markdown document
      * You automatically gain some editor support, which makes reorganization super easy

      However, I think that #1 is equally (if not more) viable, and a text-first approach is probably more inline with the philosophy of markdown, and less verbose to write in, while maintaining backwards compatibility with existing articles written in markdown.

      In addition to adding special blocks to integrate with other authoring tools, there are several other areas of potential improvement I can think of:

      * Inline math notation
      * Support for smallcaps, underlines
      * Using semantic highlighting/coloring to refer to identifiers from a code block
      * Custom elements (diff views, inline REPLs, etc)
      * Inline compile-time scripting
    }
  }

  section "Conclusion" {
    txt {
      It seems clear at this point that markdown is a good enough solution for most people, but I'd encourage trying out your own format when you start to push at the boundaries.

      If you already use your own format, or decide to create your own, please share it in the comments below!
    }
  }
}