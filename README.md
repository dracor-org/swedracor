# SweDraCor (Swedish Drama Corpus)

Corpus of 68 TEI-encoded Swedish-language plays taken from the [eDrama](http://www.dramawebben.se/sida/edrama) project. All files in this corpus are licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

The [original TEI documents](https://github.com/dracor-org/swedracor/tree/dramawebben/tei) (tagged `dramawebben` in this repo) have been renamed to follow DraCor naming conventions and have been enriched with a `particDesc` element as well as Wikidata IDs for plays and authors.

These adaptations have been implemented as an [XSLT 2.0 transformation](dramawebben2dracor.xsl) that can be ran from a [shell script](dramawebben2dracor.sh) (which requires [git](https://git-scm.com) and [saxon](http://saxon.sourceforge.net)):

```bash
./dramawebben2dracor.sh
```
