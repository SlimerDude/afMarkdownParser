using afPegger
using fandoc::HtmlDocWriter

internal class MarkdownTest : Test {
	
	Bool debug
	
	Str parseToHtml(Str markdown, Bool trimLines := true) {
		parser	:= MarkdownParser2()
		parser.grammar	// cache this!
		Peg#.pod.log.level	= debug ? LogLevel.debug : LogLevel.info
		fandoc	:= parser.parseDoc(markdown)
		buf		:= StrBuf()
		fandoc.writeChildren(HtmlDocWriter(buf.out))
		html	:= buf.toStr.replace("\n\n", trimLines ? "\n" : "\n\n").trim
		echo(html)
		return html
	}
}
