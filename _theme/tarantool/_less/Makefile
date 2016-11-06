all:
	lessc --source-map --source-map-less-inline --strict-imports \
		  --autoprefix="last 3 versions" \
		  design.less design.css
	cleancss --s1 design.css > design.min.css
	mv design.min.css design.css
	mv design.css** ../static/

debug:
	lessc --source-map --source-map-less-inline --strict-imports \
		  --autoprefix="last 3 versions" \
		  design.less ../static/design.css
