# Better DLCQuickplay CSV
A script that makes a better, tidier version of DLCQuickplay's CSV export. This script reads one
(or more) CSV files from DLCQuickPlay.com, containing song and artist information of a given user's
Rock Band song setlist. The output format of a song would be more reflective of the following.

```
"Artist",
        ,"Song Title"
        ,"Song Title"
        ,"Song Title"

"Artist",
        ,"Song Title"
        ,"Song Title"
        ,"Song Title"
...

```

## Objective

To use in conjunction with Google Sheets or a Spreadsheet software (ie. Microsoft Excel,
LibreOffice Calc, etc.) in order for Twitch.tv streamers to present a clean, presentable setlist to
their viewers.

## Known Issues:

- There currently isn't proper support for special characters. For example, the Ø in BØRNS will be
malformatted in certain versions of Ruby and in pre 2.1, will output a "invalid byte sequence in
UTF-8" error.
- Certain Rock Band songs use special characters (ie. "’" instead of "'") as apostrophes.
- Certain Rock Band songs use inconsistent capitalization with respect to the "(RB3 version)". For
example, there exists a song called "I Want it All" and "I Want It All (RB3 version)".
