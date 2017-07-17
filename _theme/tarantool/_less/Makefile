all:
	lessc --source-map --source-map-less-inline --strict-imports \
		  --autoprefix="last 8 versions" \
		  design.less design.css
	cleancss -O2 design.css > design.min.css
	mv design.min.css design.css
	mv design.css** ../static/

debug:
	lessc --source-map --source-map-less-inline --strict-imports \
		  --autoprefix="last 8 versions" \
		  design.less ../static/design.css
