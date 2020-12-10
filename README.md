# adscript (Asset Discovery Script)

![Made with Bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![Maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/drsigned/adscript.svg?style=flat&color=0040ff)](https://github.com/drsigned/adscript/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/drsigned/adscript.svg?style=flat&color=0040ff)](https://github.com/drsigned/adscript/issues?q=is:issue+is:closed) [![License](https://img.shields.io/badge/License-MIT-gray.svg?colorB=0040FF)](https://github.com/drsigned/adscript/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@drsigned-0040ff.svg)](https://twitter.com/drsigned)

A wrapper, bash script, around tools I use for assets discovery to automate my workflow. This script utilizes the following tools:
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
* Notification
    * [notifier](https://github.com/drsigned/notifier)

## Installation

To get the script clone this repository:

```bash
$ git clone https://github.com/drsigned/adscript.git
```

## Usage

To display this script's help message, use the `-h` flag:

```
$ ./adscript -h

           _               _       _   
  __ _  __| |___  ___ _ __(_)_ __ | |_ 
 / _` |/ _` / __|/ __| '__| | '_ \| __|
| (_| | (_| \__ \ (__| |  | | |_) | |_ 
 \__,_|\__,_|___/\___|_|  |_| .__/ \__| v1.0.0 
----------------------------|_| By Dr. Signed -----
---------------------------------------------------
USAGE:
  adscript.sh [OPTIONS]

OPTIONS:
  -d 		 domain to AD on
  -u 		 subs' sources to use
  -e 		 subs' sources to exclude
  -resolve	 resolve subdomains
  -httprobe	 HTTP(S) probe
  -screenshot	 take screenshots
  -o 		 output directory path
  -k 		 keep each tool's temp results
  -n 		 send notifications
  -h 		 display this message and exit

HAPPY HACKING ! :)
```

## Contibution

[Issues](https://github.com/drsigned/adscript/issues) and [Pull Requests](https://github.com/drsigned/adscript/pulls) are welcome!