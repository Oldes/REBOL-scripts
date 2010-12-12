REBOL [
    Title: "XFL-doc"
    Date: 1-Nov-2010/11:54:06+1:00
    Name: none
    Version: none
    File: none
    Home: none
    Author: "Oldes"
    Owner: none
    Rights: none
    Needs: none
    Tabs: none
    Usage: none
    Purpose: {
    	To analyse possible structure of XML files used in XFL
    }
    Comment: none
    History: none
    Language: none
    Type: none
    Content: none
    Email: none
]

do %../xml-parse/xml-parse.r

doc-path:  copy ""
doc-paths: either exists? %data/doc-paths.r [ load %data/doc-paths.r ][ copy [] ]
doc-nodes: either exists? %data/doc-nodes.r [ load %data/doc-nodes.r ][ copy [] ]
;tabs: copy ""

doc-xfl: func[
	dom [block!] "Parsed XML structure"
	/local
	tmp doc-vals
][
	;append tabs #"^-"
	parse dom [any [
		string! (
			unless find doc-paths tmp: join doc-path "/[string!]" [
				append doc-paths tmp
			]
		)
		|
		set node block! (
			foreach [ name atts content ] node [
				append doc-path join "/" name
				;print doc-path 
				;print join tabs name
				;print join tabs [" :" mold atts]
				
				unless find doc-paths doc-path [
					append doc-paths copy doc-path
				]
				unless doc-vals: select doc-nodes name [
					doc-vals: copy []
					repend doc-nodes [copy name doc-vals]
				]
				if atts [
					foreach [att val] atts [
						either string? val [
							trim val
							if 100 < length? val [
								val: join copy/part val 100 " ..."
							]
						][
							val: copy ""
						]
						either att-val: select doc-vals att [
							if all [
								10 > length? att-val
								not find att-val val
							][
								append att-val val
							]
						][
							repend doc-vals reduce [att reduce [val]] 
						]
					]
				]
				if block? content [
					doc-xfl content
				]
				clear find/last doc-path "/"
			]
		)
	]]
	;remove back tail tabs
]

foreach dir [
	;"F:\RS\projects-mm\robotek\wii\swf\"
	;"F:\RS\projects-rswf\xfl\latest\tests\"
	"F:\RS\projects-rswf\xfl\latest\tests\____\"
][
	foreach d read dir: to-rebol-file dir [
		if exists? file: rejoin [ dir d %DOMDocument.xml] [
			probe file
			doc-xfl third parse-xml+/trim as-string read/binary file
			foreach f read libdir: rejoin [dir d %LIBRARY/][
				if find libdir/:f %.xml [
					probe libdir/:f
					doc-xfl third parse-xml+/trim as-string read/binary libdir/:f
				]
			]
		]
	]
]

;sort doc-paths
new-line/all doc-paths true
sort/skip doc-nodes 2
new-line/skip doc-nodes true 2

foreach [node atts] doc-nodes [
	sort/skip atts 2
	new-line/skip atts true 2
	foreach [att vals] atts [
		sort vals
		new-line/all vals true
	]
]

save/header %data/doc-nodes.r doc-nodes [
	structure: [node-name [possible-attribute [posible-values]]]
]
save/header %data/doc-paths.r doc-paths [
	structure: [possible-node-paths]
]
;probe doc-paths
;probe doc-nodes
