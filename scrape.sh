#!/bin/bash

LINKS_FILE=/tmp/pages.txt
CURL_RESULT=/tmp/curl_result.json
LAST_RESULT=/tmp/last_result.json
MERGE_RESULT=/tmp/merge_result.json

OUTPUT_FILE_JSON=./greatest_500_albums.json
OUTPUT_FILE_CSV=./greatest_500_albums.csv

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
			| sed -e 's/<[^>]*>//g' \
			| sed 's/\\n//g' \
			> $CURL_RESULT

		jq -s '[ map(.[]) ]|flatten' $LAST_RESULT $CURL_RESULT > $MERGE_RESULT

		cat $MERGE_RESULT > $LAST_RESULT
	done < $LINKS_FILE

	mv $LAST_RESULT $OUTPUT_FILE_JSON
}

create_csv() {
	# csv headers
	echo "rank, title, description, coverUrl" > $OUTPUT_FILE_CSV

	# csv data
	jq -r '.[]|[.rank, .title, .description, .coverUrl]|@csv' $OUTPUT_FILE_JSON >> $OUTPUT_FILE_CSV
}

cleanup () {
	rm $LAST_RESULT
	rm $CURL_RESULT
	rm $MERGE_RESULT
}

main () {
	get_links 2> /dev/null
	execute 2> /dev/null
	create_csv 2> /dev/null
	RESULT=$(cat $OUTPUT_FILE_JSON | jq '.[] | .rank' | sort | uniq -c | wc -l)
	echo "$RESULT albums processed and added to ./greatest_500_albums.json and ./greatest_500_albums.csv"
}

main