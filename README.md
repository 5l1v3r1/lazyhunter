# adscript (Asset Discovery Script)

![Made with Bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![Maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/drsigned/adscript.svg?style=flat&color=0040ff)](https://github.com/drsigned/adscript/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/drsigned/adscript.svg?style=flat&color=0040ff)](https://github.com/drsigned/adscript/issues?q=is:issue+is:closed) [![License](https://img.shields.io/badge/License-MIT-gray.svg?colorB=0040FF)](https://github.com/drsigned/adscript/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@drsigned-0040ff.svg)](https://twitter.com/drsigned)

A wrapper, bash script, around tools I use for assets discovery to automate my workflow. This script utilizes the following tools:
* Subdomains Gathering
    * [amass]()
    * [sigsubs]()
    * [subfinder]()
    * [findomain]()
* Subdomains Resolution
    * [massdns]()
* HTTP(S) probing
    * [httpx]()
* Visual Reconnaissance
    * [aquatone]()

## Installation

To get the script clone this repository:

```bash
$ git clone https://github.com/drsigned/adscript.git
```

## Usage

To display this script's help message, use the `-h` flag:

```bash
$ ./adscript -h
```

## Contibution

[Issues](https://github.com/drsigned/adscript/issues) and [Pull Requests](https://github.com/drsigned/adscript/pulls) are welcome!