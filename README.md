# Historia Economica Geral II - slides site

Public page listing the lecture decks. No login needed to view.

## Files
- `decks.tsv` - the class list. One line per deck: number, unit, title, citation,
  and the path to the PDF (relative to the `econ history` folder).
- `build.sh` - copies the PDFs listed in `decks.tsv` into `slides/` and regenerates `index.html`.
- `publish.sh` - runs `build.sh`, then commits and pushes to GitHub Pages.
- `slides/` - the published PDFs. Generated; do not edit by hand.
- `index.html` - generated; do not edit by hand (edit `build.sh` instead).

## Updating after recompiling a deck
```
cd "~/Library/CloudStorage/Dropbox/econ history/site"
./publish.sh
```
That's it. The site is live about a minute later.

## Adding a new deck
Add a line to `decks.tsv` (tab-separated, in class-number order), then `./publish.sh`.

## From Windows
Same thing in Git Bash, from the Dropbox copy of this folder.

## No terminal at all
Go to the repo on github.com, open `slides/`, "Add file" > "Upload files",
drag the new PDF in (same filename), commit. Works from any browser.
