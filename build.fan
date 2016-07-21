using build

class Build : BuildPod {

	new make() {
		podName = "afMarkdownParser"
		summary = "Parses Markdown text into Fandoc objects"
		version = Version("0.0.7")

		meta = [	
			"proj.name"		: "Markdown Parser",
			"afIoc.module"	: "afMarkdownParser::MarkdownModule",
			"repo.internal"	: "true",
			"repo.tags"		: "templating, misc",
			"repo.public"	: "false"
		]

		depends = [
			"sys      1.0.68 - 1.0",
			"fandoc   1.0.68 - 1.0",
			"afPegger 0.1.0  - 0.1"
		]

		srcDirs = [`fan/`, `test/`]
		resDirs = [`doc/`]
	}
}
