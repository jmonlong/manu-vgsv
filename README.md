[![HTML Manuscript](https://img.shields.io/badge/manuscript-HTML-blue.svg)](https://jmonlong.github.io/manu-vgsv/)
[![PDF Manuscript](https://img.shields.io/badge/manuscript-PDF-blue.svg)](https://jmonlong.github.io/manu-vgsv/manuscript.pdf)
[![Build Status](https://travis-ci.com/jmonlong/manu-vgsv.svg?token=iYnJ9rfnqyHqrADLdak8&branch=master)](https://travis-ci.com/jmonlong/manu-vgsv)

# VG-SV manuscript

Quick "how to use":

- Write content in the Markdown files in the `content` folder.
- Write one-sentence per line (to get cleaner git diffs).
- E.g. citation: `[@doi:10.1038/nmeth.4366]` or `[@tag:vgnbt]` in with tag defined in `content/citation-tags.tsv`.
- Update title/author infos in [content/metadata.yaml](content/metadata.yaml).
- More in [`USAGE.md`](USAGE.md).
- In-text comments using: `<!-- This is a comment -->` or `[//]: # (This is a comment)`.
- Travis is setup to build HTML/PDF (see buttons above). Or [build locally](https://github.com/jmonlong/manu-vgsv#local-execution).

[Repo with the code to reproduce the analysis](https://github.com/vgteam/sv-genotyping-paper)

# Manubot documentation: automated scholarly manuscripts on GitHub

<!-- usage note: edit the H1 title above to personalize the manuscript -->

## Manubot

<!-- usage note: do not edit this section -->

Manubot is a system for writing scholarly manuscripts via GitHub.
Manubot automates citations and references, versions manuscripts using git, and enables collaborative writing via GitHub.
An [overview manuscript](https://greenelab.github.io/meta-review/ "Open collaborative writing with Manubot") presents the benefits of collaborative writing with Manubot and its unique features.
The [rootstock repository](https://git.io/fhQH1) is a general purpose template for creating new Manubot instances, as detailed in [`SETUP.md`](SETUP.md).
See [`USAGE.md`](USAGE.md) for documentation how to write a manuscript.

Please open [an issue](https://github.com/jmonlong/manu-vgsv/issues) for questions related to Manubot usage, bug reports, or general inquiries.

### Repository directories & files

The directories are as follows:

+ [`content`](content) contains the manuscript source, which includes markdown files as well as inputs for citations and references.
  See [`USAGE.md`](USAGE.md) for more information.
+ [`output`](output) contains the outputs (generated files) from the manubot including the resulting manuscripts.
  You should not edit these files manually, because they will get overwritten.
+ [`webpage`](webpage) is a directory meant to be rendered as a static webpage for viewing the HTML manuscript.
+ [`build`](build) contains commands and tools for building the manuscript.
+ [`ci`](ci) contains files necessary for deployment via continuous integration.
  For the CI configuration, see [`.travis.yml`](.travis.yml).

### Local execution

To run the Manubot locally, install the [conda](https://conda.io) environment as described in [`build`](build).
Then, you can build the manuscript on POSIX systems by running the following commands.

```sh
# Activate the manubot conda environment (assumes conda version >= 4.4)
conda activate manubot

# Build the manuscript, saving outputs to the output directory
sh build/build.sh

# At this point, the HTML & PDF outputs will have been created. The remaining
# commands are for serving the webpage to view the HTML manuscript locally.

# Configure the webpage directory
python build/webpage.py

# View the manuscript locally at http://localhost:8000/
cd webpage
python -m http.server
```

Sometimes it's helpful to monitor the content directory and automatically rebuild the manuscript when a change is detected.
The following command, while running, will trigger both the `build.sh` and `webpage.py` scripts upon content changes:

```sh
sh build/autobuild.sh
```

### Continuous Integration

[![Build Status](https://travis-ci.org/jmonlong/manu-vgsv.svg?branch=master)](https://travis-ci.org/jmonlong/manu-vgsv)

Whenever a pull request is opened, Travis CI will test whether the changes break the build process to generate a formatted manuscript.
The build process aims to detect common errors, such as invalid citations.
If your pull request build fails, see the Travis CI logs for the cause of failure and revise your pull request accordingly.

When a commit to the `master` branch occurs (for example, when a pull request is merged), Travis CI builds the manuscript and writes the results to the [`gh-pages`](https://github.com/jmonlong/manu-vgsv/tree/gh-pages) and [`output`](https://github.com/jmonlong/manu-vgsv/tree/output) branches.
The `gh-pages` branch uses [GitHub Pages](https://pages.github.com/) to host the following URLs:

+ **HTML manuscript** at https://jmonlong.github.io/manu-vgsv/
+ **PDF manuscript** at https://jmonlong.github.io/manu-vgsv/manuscript.pdf

For continuous integration configuration details, see [`.travis.yml`](.travis.yml).

## License

<!--
usage note: edit this section to change the license of your manuscript or source code changes to this repository.
We encourage users to openly license their manuscripts, which is the default as specified below.
-->

[![License: CC BY 4.0](https://img.shields.io/badge/License%20All-CC%20BY%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by/4.0/)
[![License: CC0 1.0](https://img.shields.io/badge/License%20Parts-CC0%201.0-lightgrey.svg)](https://creativecommons.org/publicdomain/zero/1.0/)

Except when noted otherwise, the entirety of this repository is licensed under a CC BY 4.0 License ([`LICENSE.md`](LICENSE.md)), which allows reuse with attribution.
Please attribute by linking to https://github.com/jmonlong/manu-vgsv.

Since CC BY is not ideal for code and data, certain repository components are also released under the CC0 1.0 public domain dedication ([`LICENSE-CC0.md`](LICENSE-CC0.md)).
All files matched by the following glob patterns are dual licensed under CC BY 4.0 and CC0 1.0:

+ `*.sh`
+ `*.py`
+ `*.yml` / `*.yaml`
+ `*.json`
+ `*.bib`
+ `*.tsv`
+ `.gitignore`

All other files are only available under CC BY 4.0, including:

+ `*.md`
+ `*.html`
+ `*.pdf`
+ `*.docx`

Please open [an issue](https://github.com/jmonlong/manu-vgsv/issues) for any question related to licensing.
