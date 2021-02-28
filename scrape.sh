#!/bin/bash

LINKS_FILE=/tmp/pages.txt
CURL_RESULT=/tmp/curl_result.json
LAST_RESULT=/tmp/last_result.json
MERGE_RESULT=/tmp/merge_result.json

OUTPUT_FILE=./greatest_500_albums.json

get_links () {
	curl https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063 \
			| grep pmcGalleryExports \
			| sed "s/var pmcGalleryExports = \(.*\);/\1/" \
			| jq '.listNavBar.generatedRanges."800"[] | .link' \
			| sed "s/\"//g" \
			> $LINKS_FILE
}

execute () {
	while read url; do
		echo $url
		curl "$url" \
			| grep pmcGalleryExports \
			| sed "s/var pmcGalleryExports = \(.*\);/\1/" \
			| jq '[.gallery[] | {"rank": .positionDisplay, "title": .title, "description": .description, "coverUrl": .image}]' \
			> $CURL_RESULT

		jq -s '[ map(.[]) ]|flatten' $LAST_RESULT $CURL_RESULT > $MERGE_RESULT

		cat $MERGE_RESULT > $LAST_RESULT
	done < $LINKS_FILE

	mv $LAST_RESULT $OUTPUT_FILE
}

cleanup () {
	rm $LAST_RESULT
	rm $CURL_RESULT
	rm $MERGE_RESULT
}

main () {
	get_links 2> /dev/null
	execute 2> /dev/null
	RESULT=$(cat $OUTPUT_FILE | jq '.[] | .rank' | sort | uniq -c | wc -l)
	echo "$RESULT albums processed and added to ./greatest_500_albums.json"
}

main