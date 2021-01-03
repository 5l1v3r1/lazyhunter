# Dr. Signed's Automatic Recon Script

[![maintenance](https://img.shields.io/badge/maintained%3F-yes-0040ff.svg)](https://github.com/drsigned/autorecon) [![open issues](https://img.shields.io/github/issues-raw/drsigned/autorecon.svg?style=flat&color=0040ff)](https://github.com/drsigned/autorecon/issues?q=is:issue+is:open) [![closed issues](https://img.shields.io/github/issues-closed-raw/drsigned/autorecon.svg?style=flat&color=0040ff)](https://github.com/drsigned/autorecon/issues?q=is:issue+is:closed) [![license](https://img.shields.io/badge/license-MIT-gray.svg?colorB=0040FF)](https://github.com/drsigned/autorecon/blob/master/LICENSE) [![author](https://img.shields.io/badge/twitter-@drsigned-0040ff.svg)](https://twitter.com/drsigned)

A web application reconnaissance automation script. It takes a target domain as an input and performs reconnaissance on it and gives out - Screenshots, javascripts from wayback machine, endpoints, subdomains, Valid paths, xss parameters, check for live ports , check for Subdomain takeover , etc..

## Resources

* [Usage](#usage)
* [Installation](#installation)
* [Contributuion](#contribution)

## Usage

To display this script's help message, use the `-h` flag:

```
$ ./autorecon -h

 ____         ____  _                      _ _     
|  _ \ _ __  / ___|(_) __ _ _ __   ___  __| ( )___ 
| | | | '__| \___ \| |/ _` | '_ \ / _ \/ _` |// __|
| |_| | | _   ___) | | (_| | | | |  __/ (_| | \__ \
|____/|_|(_) |____/|_|\__, |_| |_|\___|\__,_| |___/
                      |___/ Automatic Recon Script
 v1.0.0 ----------------------------------------------
------------------------------------------------------

USAGE:
  autorecon [OPTIONS]

GENERAL OPTIONS:
  -d 		 domain to recon on
  -notify 	 send notifications (via notifier)
  -h 		 display this help message and exit

ASSET DISCOVERY OPTIONS:
  -r 		 resolve
  -hP 		 httprobe
  -x 		 screenshot
  -pH 		 probe hosts
  -use 		 comma(,) separated subs enum tools to use
  -exclude 	 comma(,) separated subs enum tools to exclude

CONTENT DISCOVERY OPTIONS:
  -f 		 fingerprint hosts
  -c 		 crawl/spider the hosts
  -pU 		 probe urls

OUTPUT OPTIONS:
  -k 		 keep each tool's results
  -o 		 output directory path

HAPPY HACKING ! :)
```

## Installation

To get the script clone this repository:

```bash
$ git clone https://github.com/drsigned/autorecon.git
```

## Contibution

[Issues](https://github.com/drsigned/autorecon/issues) and [Pull Requests](https://github.com/drsigned/autorecon/pulls) are welcome!