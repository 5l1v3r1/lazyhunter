#!/usr/bin/env bash

bold="\e[1m"
red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
reset="\e[0m"
green="\e[32m"
yellow="\e[33m"
underline="\e[4m"

script_filename=${0##*/}

banner() {
echo -e ${bold}${blue}"
 _                 _
| |__  _   _ _ __ | |_ ___ _ __
| '_ \| | | | '_ \| __/ _ \ '__|
| | | | |_| | | | | ||  __/ |
|_| |_|\__,_|_| |_|\__\___|_|
 ${green}v1.0.0${blue} ----------------------------------------------
------------------------------------------------------
"${reset}
}

display_usage() {
	banner

	while read -r line
	do
		printf "%b\n" "${line}"
	done <<-EOF
	\rUSAGE:
	\r  ${script_filename} [OPTIONS]

	\rFEATURES:
	\r  [+] Asset Discovery
	\r  [+] Content Discovery
	\r  [+] Low Hanging Vulns Discovery

	\rGENERAL OPTIONS:
	\r  -d \t\t domain to AD on
	\r  -notify \t send notifications
	\r  -h \t\t display this message and exit

	\rASSET DISCOVERY OPTIONS:
	\r  -use \t\t tools to use
	\r  -exclude \t tools to exclude
	\r  -r \t\t resolve subdomains
	\r  -rh \t\t resolve subdomains & httprobe
	\r  -rhp \t\t resolve subdomains, httprobe & probe hosts
	\r  -rhpx \t resolve subdomains, httprobe, probe hosts & screenshot

	\rCONTENT DISCOVERY OPTIONS:
	\r  -cd \t\t do content discovery
	\r  -tech-detect \t detect web technology used

	\rVULNERABILITY DISCOVERY OPTIONS:
	\r  -vulns \t do content discovery

	\rOUTPUT OPTIONS:
	\r  -o \t\t output directory path
	\r  -k \t\t keep each tool's results
	
	\rHAPPY HACKING ! :)

EOF
}

check_tools() {
	tools=(
		jq
		anew
		notifier

		amass
		sigsubs
		subfinder
		findomain

		massdns

		httpx

		aquatone
		
		substko
		nuclei

		wappalyzer
		wafw00f

		sigurls
		sigurlx
	)
	missing_tools=()

	for tool in "${tools[@]}"
	do
		[ ! -x "$(command -v ${tool})" ] && {
			missing_tools+=(${tool})
		}
	done

	[ ${#missing_tools[@]} -gt 0 ] && {
		missing_tools_str="${missing_tools[@]}"
		echo -e "\n[-] failed! missing tool(s) : " ${missing_tools_str// /,}"\n"
		exit 1
	}
}

_amass() {
	local amass_output="${asset_discovery_output}/temp-amass-subdomains.txt"

	printf "        [${blue}+${reset}] amass"
	printf "\r"
	amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "        [${blue}+${reset}] amass: $(wc -l < ${amass_output})"
}

_sigsubs() {
	local sigsubs_output="${asset_discovery_output}/temp-sigsubs-subdomains.txt"

	printf "        [${blue}+${reset}] sigsubs"
	printf "\r"
	sigsubs -d ${domain} -s 1> ${sigsubs_output} 2> /dev/null
	echo -e "        [${blue}+${reset}] sigsubs: $(wc -l < ${sigsubs_output})"
}

_findomain() {
	local findomain_output="${asset_discovery_output}/temp-findomain-subdomains.txt"

	printf "        [${blue}+${reset}] findomain"
	printf "\r"
	findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "        [${blue}+${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_subfinder() {
	local subfinder_output="${asset_discovery_output}/temp-subfinder-subdomains.txt"

	printf "        [${blue}+${reset}] subfinder"
	printf "\r"
	subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "        [${blue}+${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

main() {
	check_tools
	banner

	# {{ ASSET DISCOVERY

	echo -e "[${blue}+${reset}] asset discovery"
	[ ! -d ${asset_discovery_output} ] && mkdir -p ${asset_discovery_output}

	# {{ ASSET DISCOVERY: SUNDOMAIN GATHERING

	echo -e "    [${blue}+${reset}] subdomains gathering"
	subdomains="${asset_discovery_output}/subdomains.txt"

	[ ${subs_sources_to_use} == False ] && [ ${subs_sources_to_exclude} == False ] && {
		for source in "${subs_sources[@]}"
		do 
			_${source}
		done
	} || {
		[ ${subs_sources_to_use} != False ] && {
			for source in "${subs_sources_to_use_dictionary[@]}"
			do 
				_${source}
			done
		} 
		[ ${subs_sources_to_exclude} != False ] && {
			for source in ${subs_sources[@]}
			do
				if [[ " ${subs_sources_to_exclude_dictionary[@]} " =~ " ${source} " ]]
				then
					continue
				else
					_${source}
				fi
			done
		}
	}

	cat ${asset_discovery_output}/temp-*-subdomains.txt | sed 's#*.# #g' | anew -q ${subdomains}
	echo -e "        [=] unique subdomains: $(wc -l < ${subdomains})"

	# }}
	# {{ VULNERABILITY: SUBDOMAIN TAKEOVER

	[ ${vuln_scan} == True ] && {
		echo -e "    [${blue}+${reset}] subdomain takeover"
		substko_output="${asset_discovery_output}/substko-output.txt"

		substko -l ${subdomains} -silent > ${substko_output} 

		[ ${notify} == True ] && {
			substko -l ${subdomains} -silent | tee ${substko_output} | notifier
		}
	}
	
	# }}
	# {{ ASSET DISCOVERY: SUBDOMAINS RESOLUTION

	[ ${resolve} == True ] && {
		echo -e "    [${blue}+${reset}] subdomains resolution"
		ips="${asset_discovery_output}/ips.txt"
		resolved_subdomains="${asset_discovery_output}/resolved-subdomains.txt"

		local massdns_output="${asset_discovery_output}/temp-massdns-resolve.txt"

		printf "        [${blue}+${reset}] resolving"
		printf "\r"
		massdns -r ${HOME}/tools/reconnaissance/dns-resolution/massdns/lists/resolvers.txt -q -t A -o S -w ${massdns_output} ${subdomains}
		echo -e "        [${blue}+${reset}] resolved!"

		printf "        [${blue}+${reset}] resolved IPs"
		printf "\r"
		egrep -o -h "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" ${massdns_output} | sort -u | anew -q ${ips}
		echo -e "        [${blue}+${reset}] resolved IPs: $(wc -l < ${ips})"

		printf "        [${blue}+${reset}] resolved subdomains"
		printf "\r"
		cat ${massdns_output} | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | sort -u | anew -q ${resolved_subdomains}
		echo -e "        [${blue}+${reset}] resolved subdomains: $(wc -l < ${resolved_subdomains})"
	}

	# }}
	# {{ ASSET DISCOVERY: HTTP(S) PROBING

	[ ${resolve} == True ] \
	&& [ ${httprobe} == True ] && {
		echo -e "    [${blue}+${reset}] http(s) probing"
		hosts="${asset_discovery_output}/hosts.txt"
		httpx -l ${resolved_subdomains} -silent | anew -q ${hosts}
	}

	# }}
	# {{ ASSET DISCOVERY: HOSTS PROBING

	[ ${resolve} == True ] \
	&& [ ${httprobe} == True ] \
	&& [ ${hostsprobe} == True ] && {
		echo -e "    [${blue}+${reset}] hosts probing"
		hosts_probe="${asset_discovery_output}/hosts-probe.json"
		cat ${hosts} | sigurlx -request -o ${hosts_probe} -s &> /dev/null
	}

	# }}
	# {{ VULNERABILITY: DETCETING KNOWN VULNERABILITIES

	[ ${resolve} == True ] \
	&& [ ${httprobe} == True ] \
	&& [ ${hostsprobe} == True ] \
	&& [ ${vuln_scan} == True ] && {
		echo -e "    [${blue}+${reset}] check known vulns"
		nuclei_output="${asset_discovery_output}/nuclei-output.txt"

		[ ${notify} == True ] && {
			jq -r '.[] | select(.status_code == 200) | .url' ${hosts_probe} \
			| nuclei \
				-t ~/nuclei-templates/dns \
				-t ~/nuclei-templates/misc \
				-t ~/nuclei-templates/cves \
				-t ~/nuclei-templates/files \
				-t ~/nuclei-templates/vulnerabilities \
				-t ~/nuclei-templates/security-misconfiguration \
				-severity low,medium,high,critical -silent | tee ${nuclei_output} | notifier
		}
	}

	# }}
	# {{ VULNERABILITY: CORS MISCONFIGURATION

	[ ${resolve} == True ] \
	&& [ ${httprobe} == True ] \
	&& [ ${hostsprobe} == True ] \
	&& [ ${vuln_scan} == True ] && {
		echo -e "    [${blue}+${reset}] cors misconfiguration"
		corsmisc_output="${asset_discovery_output}/corsmisc.json"
		[ ${notify} == True ] && {
			jq -r '.[] | select(.status_code == 200) | .url' ${hosts_probe} | corsmisc -urls - -o ${corsmisc_output} -s | notifier
		}
	}
	
	# }}
	# {{ ASSET DISCOVERY: VISUAL RECONNAISSANCE

	[ ${resolve} == True ] \
	&& [ ${httprobe} == True ] \
	&& [ ${screenshot} == True ] && {
		echo -e "    [${blue}+${reset}] visual reconnaissance"
		visual_reconnaissance="${asset_discovery_output}/visual-reconnaissance"
		[ ! -d ${visual_reconnaissance} ] && mkdir -p ${visual_reconnaissance}
		cat ${hosts} | aquatone -threads=5 -http-timeout 1000 -out ${visual_reconnaissance} &> /dev/null
	}

	# }}
	
	[ ${keep} == False ] && rm ${asset_discovery_output}/temp-*-*.txt

	# }}
	# {{ CONTENT DISCOVERY

	[ ${content_discovery} == True ] && {

		echo -e "[${blue}+${reset}] content discovery"
		[ ! -d ${content_discovery_output} ] && mkdir -p ${content_discovery_output}

		# {{ CONTENT DISCOVERY: TECHNOLOGY DETECTION

		[ ${resolve} == True ] \
		&& [ ${httprobe} == True ] \
		&& [ ${fingerprint} == True ] && {
			echo -e "    [${blue}+${reset}] technology detection"

			echo -e "        [${blue}+${reset}] web application technology"
			web_technology_output="${content_discovery_output}/technology/web-application"
			[ ! -d ${web_technology_output} ] && mkdir -p ${web_technology_output}
			cat ${hosts} | rush 'wappalyzer {} -P > {output_dir}/$(echo {} | urlbits format %s.%S.%r.%t).json' -j 5 -v output_dir=${web_technology_output}

			echo -e "        [${blue}+${reset}] waf technology"
			waf_technology_output="${content_discovery_output}/technology/waf"
			[ ! -d ${waf_technology_output} ] && mkdir -p ${waf_technology_output}
			cat ${hosts} | rush 'wafw00f {} > {output_dir}/$(echo {} | urlbits format %s.%S.%r.%t).txt' -j 5 -v output_dir=${waf_technology_output}
		}
		
		# }}
		# {{ CONTENT DISCOVERY: FETCH KNOWN URLS

		echo -e "    [${blue}+${reset}] urls fetching"
		known_urls="${content_discovery_output}/known-urls.txt"
		sigurls -d ${domain} -subs -s 1> ${known_urls} 2> /dev/null

		# }}
		# {{ CONTENT DISCOVERY: WEB CRAWLING

		echo -e "    [${blue}+${reset}] web crawling"
		sigrawler_output="${content_discovery_output}/sigrawler.json"
		cat ${hosts} ${known_urls} | sigrawler -subs -depth 3 -o ${sigrawler_output} &> /dev/null

		jq -r '.urls[]' ${sigrawler_output} | anew -q ${known_urls}

		# }}
		# {{ CONTENT DISCOVERY: URLS CATEGORIZING

		echo -e "    [${blue}+${reset}] urls categorizing"
		url_categories="${content_discovery_output}/url-categories.json"
		cat ${known_urls} | sigurlx -cat -o ${url_categories} -s &> /dev/null

		# }}
		# {{ CONTENT DISCOVERY: ENDPOINTS PROBING

		echo -e "    [${blue}+${reset}] endpoints probing"
		endpoint_probes="${content_discovery_output}/endpoints-probe.json"
		jq -r '.[] | select(.category == "endpoint") | .url' ${url_categories} | sigurlx -cat -param-scan -request -t 100 -s -o ${endpoint_probes} &> /dev/null

		# }}

	}

	# }}

	echo -e ${bold}${blue}"\n- DONE! ----------------------------------------------"${reset}
}

keep=False
notify=False
domain=False

resolve=False
httprobe=False
hostsprobe=False
screenshot=False

content_discovery=False
fingerprint=False
vuln_scan=False

subs_sources=(
	amass
	sigsubs
	findomain
	subfinder
)
subs_sources_to_use=False
subs_sources_to_exclude=False

asset_discovery_output="$(pwd)/asset-discovery"
content_discovery_output="$(pwd)/content-discovery"

while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case "$(echo ${1} | tr '[:upper:]' '[:lower:]')" in
		# GENERAL OPTIONS
		-d)
			domain=${2}
			shift
		;;
		-notify)
			notify=True
		;;
		-h)
			display_usage
			exit 0
		;;
		# ASSET DISCOVERY OPTIONS
		-use)
			subs_sources_to_use=${2}
			subs_sources_to_use_dictionary=${subs_sources_to_use//,/ }

			for i in ${subs_sources_to_use_dictionary}
			do
				if [[ ! " ${subs_sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		-exclude)
			subs_sources_to_exclude=${2}
			subs_sources_to_exclude_dictionary=${subs_sources_to_exclude//,/ }

			for i in ${subs_sources_to_exclude_dictionary}
			do
				if [[ ! " ${subs_sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		-r) 
			resolve=True
		;;
		-rh)
			resolve=True
			httprobe=True
		;;
		-rhp)
			resolve=True
			httprobe=True
			hostsprobe=True
		;;
		-rhpx)
			resolve=True
			httprobe=True
			hostsprobe=True
			screenshot=True
		;;
		# CONTENT DISCOVERY OPTIONS
		-cd)
			content_discovery=True
		;;
		-tech-detect)
			fingerprint=True
		;;
		# VULNERABILITY DISCOVERY OPTIONS
		-vulns) 
			vuln_scan=True
		;;
		# OUTPUT OPTIONS
		-o)
			asset_discovery_output="${2}/asset-discovery"
			content_discovery_output="${2}/content-discovery"
			shift
		;;
		-k)
			keep=True
		;;
		*)
			display_usage
			exit 1
		;;
	esac
	shift
done

main

exit 0