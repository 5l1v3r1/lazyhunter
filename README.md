# autorecon

![made with bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/drsigned/autorecon.svg?style=flat&color=0040ff)](https://github.com/drsigned/autorecon/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/drsigned/autorecon.svg?style=flat&color=0040ff)](https://github.com/drsigned/autorecon/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/drsigned/autorecon/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@drsigned-0040ff.svg)](https://twitter.com/drsigned)

A wrapper, bash script, around tools I use for assets discovery to automate my workflow. This script utilizes the following tools:

* Asset Discovery
    * Subdomains Gathering
        * [amass](https://github.com/OWASP/Amass)
        * [sigsubs](https://github.com/drsigned/sigsubs)
        * [subfinder](https://github.com/projectdiscovery/subfinder)
        * [findomain]()
    * Subdomains Resolution
        * [massdns](https://github.com/blechschmidt/massdns)
    * HTTP(S) probing
        * [httpx](https://github.com/projectdiscovery/httpx)
    * Visual Reconnaissance
        * [aquatone](https://github.com/michenriksen/aquatone)
* Content Discovery
    * Fingerprinting
        * [wappalyzer]()
    * URLs gathering
        * [sigurls](https://github.com/drsigned/sigurls)
    * Crawling
        * [sigrawler](https://github.com/drsigned/sigrawler)
* Notification
    * [notifier](https://github.com/drsigned/notifier)

## Installation

To get the script clone this repository:

```bash
$ git clone https://github.com/drsigned/autorecon.git
```

## Usage

To display this script's help message, use the `-h` flag:

```
$ ./autorecon -h

           _               _       _   
  __ _  __| |___  ___ _ __(_)_ __ | |_ 
 / _` |/ _` / __|/ __| '__| | '_ \| __|
| (_| | (_| \__ \ (__| |  | | |_) | |_ 
 \__,_|\__,_|___/\___|_|  |_| .__/ \__| v1.0.0 
----------------------------|_| By Dr. Signed -----
---------------------------------------------------

USAGE:
  autorecon.sh [OPTIONS]

FEATURES:
  [+] Asset Discovery
  [+] Content Discovery
  [+] Low Hanging Vulns Discovery

GENERAL OPTIONS:
  -d 		 domain to AD on
  -notify 	 send notifications
  -h 		 display this message and exit

ASSET DISCOVERY OPTIONS:
  -u 		 subs' tools to use
  -e 		 subs' tools to exclude
  -r 		 enable subdomains' resolution
  -h 		 find hosts
  -hp 		 find hosts & probe hosts
  -x 		 web screenshot hosts

CONTENT DISCOVERY OPTIONS:
  -cd 		 do content discovery
  -tech-detect 	 detect web technology used

VULNERABILITY DISCOVERY OPTIONS:
  -vulns 	 do content discovery

OUTPUT OPTIONS:
  -o 		 output directory path
  -k 		 keep each tool's results

HAPPY HACKING ! :)
```

## Contibution

[Issues](https://github.com/drsigned/autorecon/issues) and [Pull Requests](https://github.com/drsigned/autorecon/pulls) are welcome!