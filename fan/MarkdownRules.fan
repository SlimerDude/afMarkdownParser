using afPegger

@Js
internal class MarkdownRules : TreeRules {
	
	Rule rootRule() { 
		rules := NamedRules()

		statement		:= rules["statement"]
		paragraph		:= rules["paragraph"]
		heading			:= rules["heading"]
		blockquote		:= rules["blockquote"]
		pre				:= rules["pre"]
		ul				:= rules["ul"]
		ol				:= rules["ol"]
		image			:= rules["image"]
		line			:= rules["line"]
		bold1			:= rules["bold1"]
		bold2			:= rules["bold2"]
		italic1			:= rules["italic1"]
		italic2			:= rules["italic2"]
		codeSpan		:= rules["code"]
		link			:= rules["link"]
		text			:= rules["text"]

		eol				:= firstOf { char('\n'), eos }
		space			:= anyCharOf([' ', '\t'])
		anySpace		:= zeroOrMore(space)
		
		rules["statement"]	= firstOf { heading, ul, ol, pre, blockquote, image, paragraph, eol, }
		rules["heading"]	= sequence { between(1..4, char('#')).withAction(pushHeading.action), onlyIf(anyCharNot('#')), anySpace, line, popHeading, }
		rules["paragraph"]	= sequence { push("paragraph"), oneOrMore(line), eol, pop, }
		rules["blockquote"]	= sequence { pushBlockquote, char('>'), anySpace, line, pop, }
		rules["pre"]		= sequence { 
			push("pre"),
			oneOf(sequence {
				sequence { str("    "), oneOrMore(anyCharNot('\n')), char('\n'), }, 
				oneOrMore( firstOf { 
					sequence { str("    "), oneOrMore(anyCharNot('\n')), char('\n'), }, 
					sequence { between(0..4, char(' ')), char('\n'), },
				} ),
			} ).withAction(addText), 
			popPre,
		}
		
		rules["ul"]			= sequence { 
			push("ul"),
			oneOrMore(sequence {
				pushLi,
				between(0..3, space),
				anyCharOf("*+-".chars),	oneOrMore(space),
				line, 
				zeroOrMore( sequence { 
					between(0..5, space),
					onlyIfNot(sequence { anyCharOf("*+-".chars), oneOrMore(space)}),
					line,					
				}),
				pop("li"),
			}),
			pop, 
		}

		rules["ol"]			= sequence { 
			push("ol"),
			oneOrMore(sequence {
				pushLi,
				between(0..3, space),
				oneOrMore(anyNumChar), char('.'), oneOrMore(space),
				line, 
				zeroOrMore( sequence { 
					between(0..5, space),
					onlyIfNot( sequence { oneOrMore(anyNumChar), char('.'), oneOrMore(space), }),
					line,					
				}),
				pop("li"),
			}),
			pop, 
		}
		
		rules["line"]		= sequence { text, eol, }
		rules["text"]		= oneOrMore( firstOf { italic1, italic2, bold1, bold2, codeSpan, link, anyCharNot('\n').withAction(addText), })
		
		// suppress multiline bold and italics, 'cos it may in the middle of a list, or gawd knows where!
		rules["italic1"]	= sequence { onlyIfNot(str("* ")), push("italic"), char('*'), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot('*'), }).withAction(addText), char('*'), pop, }
		rules["italic2"]	= sequence { onlyIfNot(str("_ ")), push("italic"), char('_'), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot('_'), }).withAction(addText), char('_'), pop, }
		rules["bold1"]		= sequence { push("bold"), str("**"), oneOrMore(anyCharNotOf(['*', '\n'])).withAction(addText), str("**"), pop, }
		rules["bold2"]		= sequence { push("bold"), str("__"), oneOrMore(anyCharNot('_')).withAction(addText), str("__"), pop, }
		rules["code"]		= sequence { push("code"), char('`'), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot('`'), }).withAction(addText), char('`'), pop, }
		rules["link"]		= sequence { 
			push("link"), 
			char('['), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot(']'), }).withAction(addAction("linkText")), char(']'), 
			char('('), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot(')'), }).withAction(addAction("linkHref")), char(')'), 
			pop,
		}
		rules["image"]		= sequence { 
			push("image"),
			char('!'),
			char('['), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot(']'), }).withAction(addAction("imageAlt")), char(']'), 
			char('('), oneOrMore(sequence { onlyIf(anyCharNot('\n')), anyCharNot(')'), }).withAction(addAction("imageSrc")), char(')'),
			anySpace, eol,
			pop,
		}

		return statement
	}

	|Str matched, Obj? ctx| addText() {
		|Str matched, TreeCtx ctx| {
			if (ctx.current.items.last?.type == "text")
				ctx.current.items.last.matched += matched
			else
				ctx.current.add("text", matched)
		}
	}

	Rule pushHeading() {
		doAction |Str matched, TreeCtx ctx| { 
			ctx.push("heading", matched, matched.size) 
		}
	}

	Rule popHeading() {
		doAction |Str matched, TreeCtx ctx| { 
			// tidy up trailing hashes --> ## h2 ##
			text := ctx.current.items.last
			while (text.matched?.endsWith("#") ?: false)
				text.matched = text.matched[0..<-1].trimEnd
			ctx.pop
		}
	}

	Rule popPre() {
		doAction |Str matched, TreeCtx ctx| { 
			text := ctx.current.items.last
			text.matched = text.matched?.trimEnd
			ctx.pop
		}
	}

	Rule pushBlockquote() {
		doAction |Str matched, TreeCtx ctx| {
			if (ctx.current.items.last?.type == "blockquote")
				ctx.current = ctx.current.items.last
			else
				ctx.push("blockquote") 
		}
	}

	Rule pushLi() {
		doAction |Str matched, TreeCtx ctx| {
			ul := ctx.current.prev
			if (ul?.type == "ul" || ul?.type == "ol") {
				// merge the two ul's
				ctx.current.parent.items.remove(ctx.current)
				ctx.current = ul
				
				// enclose the previous li in a p
				li  := ul.items.last
				txt := li.items.dup
				li.items.clear
				p   := li.add("paragraph")
				txt.each { p.addItem(it) }
				
				ctx.push("li").push("paragraph")
			} else 
				ctx.push("li")
		}
	}
}
