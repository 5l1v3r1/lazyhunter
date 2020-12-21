# hunter

![made with bash](https://img.shields.io/badge/made%20with-Bash-0040ff.svg) ![maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg) [![open issues](https://img.shields.io/github/issues-raw/drsigned/hunter.svg?style=flat&color=0040ff)](https://github.com/drsigned/hunter/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/drsigned/hunter.svg?style=flat&color=0040ff)](https://github.com/drsigned/hunter/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/drsigned/hunter/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@drsigned-0040ff.svg)](https://twitter.com/drsigned)

A wrapper, bash script, around tools I use for assets discovery to automate my workflow.

## Installation

To get the script clone this repository:

```bash
$ git clone https://github.com/drsigned/hunter.git
```

## Usage

To display this script's help message, use the `-h` flag:

```
$ ./hunter -h

 _                 _
| |__  _   _ _ __ | |_ ___ _ __
| '_ \| | | | '_ \| __/ _ \ '__|
| | | | |_| | | | | ||  __/ |
|_| |_|\__,_|_| |_|\__\___|_|
 v1.0.0 ----------------------------------------------
------------------------------------------------------

USAGE:
  hunter.sh [OPTIONS]

FEATURES:
  [+] Asset Discovery
  [+] Content Discovery
  [+] Low Hanging Vulns Discovery

GENERAL OPTIONS:
  -d 		 domain to AD on
  -notify 	 send notifications
  -h 		 display this message and exit

ASSET DISCOVERY OPTIONS:
  -use 		 tools to use
  -exclude 	 tools to exclude
  -r 		 resolve subdomains
  -rh 		 resolve subdomains & httprobe
  -rhp 		 resolve subdomains, httprobe & probe hosts
  -rhpx 	 resolve subdomains, httprobe, probe hosts & screenshot

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

[Issues](https://github.com/drsigned/hunter/issues) and [Pull Requests](https://github.com/drsigned/hunter/pulls) are welcome!