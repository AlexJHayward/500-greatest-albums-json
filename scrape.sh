#!/bin/bash

declare -a urls=("https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/rufus-chaka-khan-ask-rufus-1062734/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/linda-mccartney-and-paul-ram-1062783/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/the-go-gos-beauty-and-the-beat-1062833/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/stevie-wonder-music-of-my-mind-2-1062883/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/shania-twain-come-on-over-1062933/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/buzzcocks-singles-going-steady-2-1062983/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/sade-diamond-life-1063033/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/bruce-springsteen-nebraska-3-1063083/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/the-band-music-from-big-pink-2-1063133/"
				"https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063/jay-z-the-blueprint-3-1063183/"
				)

execute () {
	touch /tmp/last_result.json

	for url in "${urls[@]}"; do
		echo $url
		curl "$url" \
			| grep pmcGalleryExports \
			| sed "s/var pmcGalleryExports = \(.*\);/\1/" \
			| jq '[.gallery[] | {"rank": .positionDisplay, "title": .title, "description": .description, "coverUrl": .image}]' \
			> /tmp/curl_result.json

		jq -s '[ map(.[]) ]|flatten' /tmp/last_result.json /tmp/curl_result.json > /tmp/merge_result.json

		cat /tmp/merge_result.json > /tmp/last_result.json
	done

	mv /tmp/last_result.json ./greatest_500_albums.json
	cleanup
}

cleanup () {
	rm /tmp/last_result.json
	rm /tmp/curl_result.json
	rm /tmp/merge_result.json
}

main () {
	execute 2> /dev/null
	RESULT=$(cat greatest_500_albums.json | jq '.[] | .rank' | wc -l)
	echo "$RESULT albums processed and added to ./greatest_500_albums.json"
}

main