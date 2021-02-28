# 500 Greatest Albums of All Time

https://www.rollingstone.com/music/music-lists/best-albums-of-all-time-1062063

I'm going to try and listen to all of them, but Rolling Stone's website makes my computer unhappy, and I want to be able to add ratings and things in Airtable.

Script just pulls in the links to each range of albums, goes through each page, pulls out a few fields, and stitches everything together in a single JSON file. Whoever at Rolling Stone decided to just keep all the album info in a JSON object on each page is a hero.

The Album title can sometimes contain part of the artist name if the artist name has a comma on it, I could fix it, but for my purposes this was good enough and I only have so much capacity for writing JQ filters. Fixes welcome if this is useful to you, a better version would probably look something like this:

```sh
[.[] | {"artist": (.title_artist|match("(.*), '(.*)'").captures[1].string), "title": (.title_artist|match("(.*), '(.*)'").captures[2].string)}]
```