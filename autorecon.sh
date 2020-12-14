#!/usr/bin/env bash

bold="\e[1m"
red="\e[31m"
cyan="\e[36m"
blue="\e[34m"
reset="\e[0m"
green="\e[32m"
yellow="\e[33m"
underline="\e[4m"
script_file_name=${0##*/}

banner() {
echo -e ${bold}${blue}"
             _                                 
  __ _ _   _| |_ ___  _ __ ___  ___ ___  _ __  
 / _\` | | | | __/ _ \| '__/ _ \/ __/ _ \| '_ \ 
| (_| | |_| | || (_) | | |  __/ (_| (_) | | | |
 \__,_|\__,_|\__\___/|_|  \___|\___\___/|_| |_| ${green}v1.0.0 ${blue} 
--------------------------------- ${yellow}By Dr. Signed ${blue}------
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
	\r  ${script_file_name} [OPTIONS]

	\rOPTIONS:
	\r  -d \t\t domain to AD on
	\r  -u \t\t subs' sources to use
	\r  -e \t\t subs' sources to exclude
	\r  -resolve\t resolve subdomains
	\r  -httprobe\t HTTP(S) probe
	\r  -screenshot\t screenshot
	\r  -map \t\t map the target
	\r  -o \t\t output directory path
	\r  -k \t\t keep each tool's temp results
	\r  -n \t\t send notifications
	\r  -h \t\t display this message and exit
	
	\rHAPPY HACKING ! :)

EOF
}

check_tools() {
	tools=(
		anew
		httpx
		amass
		massdns
		sigsubs
		aquatone
		notifier
		subfinder
		findomain
		sigurls
	)
	missing_tools=()

	for tool in "${tools[@]}"
	do
		[ ! -x "$(command -v ${tool})" ] && { missing_tools+=(${tool}); }
	done

	[ ${#missing_tools[@]} -gt 0 ] && {
		missing_tools_str="${missing_tools[@]}"
		echo -e "\n[-] failed! missing tool(s) : " ${missing_tools_str// /,}"\n"
		exit 1
	}
}

_amass() {
	local amass_output="${asset_discovery}/temp-amass-subdomains.txt"

	printf "        [${green}+${reset}] amass"
	printf "\r"
	amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "        [${green}+${reset}] amass: $(wc -l < ${amass_output})"
}

_sigsubs() {
	local sigsubs_output="${asset_discovery}/temp-sigsubs-subdomains.txt"

	printf "        [${green}+${reset}] sigsubs"
	printf "\r"
	sigsubs -d ${domain} -s 1> ${sigsubs_output} 2> /dev/null
	echo -e "        [${green}+${reset}] sigsubs: $(wc -l < ${sigsubs_output})"
}

_findomain() {
	local findomain_output="${asset_discovery}/temp-findomain-subdomains.txt"

	printf "        [${green}+${reset}] findomain"
	printf "\r"
	findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "        [${green}+${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_subfinder() {
	local subfinder_output="${asset_discovery}/temp-subfinder-subdomains.txt"

	printf "        [${green}+${reset}] subfinder"
	printf "\r"
	subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "        [${green}+${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

main() {
	check_tools; banner

	# {{ ASSET DISCOVERY

	echo -e "[${green}+${reset}] asset discovery"
	[ ! -d ${asset_discovery} ] && mkdir -p ${asset_discovery}

	# {{ SUNDOMAIN GATHERING

	echo -e "    [${green}+${reset}] subdomains gathering"
	subdomains="${asset_discovery}/subdomains.txt"

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

	cat ${asset_discovery}/temp-*-subdomains.txt | sed 's#*.# #g' | anew -q ${subdomains}
	echo -e "        [=] unique subdomains: $(wc -l < ${subdomains})"

	[ ${keep} == False ] && rm ${asset_discovery}/temp-*-subdomains.txt

	# }}
	# {{ SUBDOMAINS RESOLUTION

	[ ${resolve} == True ] && {
		echo -e "    [${green}+${reset}] subdomain resolution"

		ips="${asset_discovery}/ips.txt"
		resolved_subdomains="${asset_discovery}/resolved-subdomains.txt"

		local massdns_output="${asset_discovery}/temp-massdns-resolve.txt"

		printf "        [${green}+${reset}] resolving"
		printf "\r"
		massdns -r ${HOME}/tools/web-sec/discovery/dns/massdns/lists/resolvers.txt -q -t A -o S -w ${massdns_output} ${subdomains}
		echo -e "        [${green}+${reset}] resolved!"

		printf "        [${green}+${reset}] resolved IPs"
		printf "\r"
		egrep -o -h "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" ${massdns_output} | sort -u | anew -q ${ips}
		echo -e "        [${green}+${reset}] resolved IPs: $(wc -l < ${ips})"

		printf "        [${green}+${reset}] resolved subdomains"
		printf "\r"
		cat ${massdns_output} | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | sort -u | anew -q ${resolved_subdomains}
		echo -e "        [${green}+${reset}] resolved subdomains: $(wc -l < ${resolved_subdomains})"

		[ ${keep} == False ] && rm ${asset_discovery}/temp-*-resolve.txt
	}

	# }}
	# {{ HTTP(S) PROBING

	[ ${resolve} == True ] && [ ${httprobe} == True ] && {
		echo -e "    [${green}+${reset}] http(s) probing"

		hosts="${asset_discovery}/hosts.txt"

		[ ${notify} == True ] && {
			httpx -l ${resolved_subdomains} -silent | anew ${hosts} | awk '{print new ": `" $0 "`"}' new="script4assets: New host for ${domain}" | notifier
		} || {
			httpx -l ${resolved_subdomains} -silent | anew -q ${hosts} 
		}
	}

	# }}
	# {{ VISUAL RECONNAISSANCE

	[ ${resolve} == True ] && [ ${httprobe} == True ] &&[ ${screenshot} == True ] && {
		echo -e "    [${green}+${reset}] visual reconnaissance"

		visual_reconnaissance="${asset_discovery}/visual-reconnaissance"
		[ ! -d ${visual_reconnaissance} ] && mkdir -p ${visual_reconnaissance}

		cat ${hosts} | aquatone -threads=5 -http-timeout 10000 -out ${visual_reconnaissance} &> /dev/null
	}

	# }}

	# }}
	# {{ TARGET MAPPING

	[ ${map_target} == True ] && {

		echo -e "[${green}+${reset}] target mapping"
		[ ! -d ${content_discovery} ] && mkdir -p ${content_discovery}

		# {{ GATHER URLS

		echo -e "    [${green}+${reset}] gathering urls"
		
		local sigurls_output="${content_discovery}/temp-sigurls-urls.txt"

		printf "        [${green}+${reset}] sigurls"
		printf "\r"
		sigurls -d ${domain} -subs -s 1> ${sigurls_output} 2> /dev/null
		echo -e "        [${green}+${reset}] sigurls: $(wc -l < ${sigurls_output})"

		local sigrawler_output="${content_discovery}/temp-sigrawler-urls.json"

		printf "        [${green}+${reset}] sigrawler"
		printf "\r"
		cat ${hosts} | sigrawler -subs -depth 3 -o ${sigrawler_output} &> /dev/null
		echo -e "        [${green}+${reset}] sigrawler: $(wc -l < ${sigrawler_output})"

		# }}

	}
	
	# }}

	echo -e ${bold}${blue}"\n- DONE! -------------------------------------------"${reset}
}

# tasks
resolve=False
httprobe=False
screenshot=False

keep=False
domain=False

notify=False

subs_sources=(
	amass
	sigsubs
	findomain
	subfinder
)
subs_sources_to_use=False
subs_sources_to_exclude=False

asset_discovery="$(pwd)/asset-discovery"
content_discovery="$(pwd)/content-discovery"

while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case "$(echo ${1} | tr '[:upper:]' '[:lower:]')" in
		-d)
			domain=${2}
			shift
		;;
		-u)
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
		-e)
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
		-resolve) resolve=True ;;
		-httprobe) httprobe=True ;;
		-screenshot) screenshot=True ;;
		-map) map_target=True ;;
		-o)
			asset_discovery="${2}/asset-discovery"
			content_discovery="${2}/content-discovery"
			shift
		;;
		-k) keep=True ;;
		-n) notify=True ;;
		-h) 
			display_usage
			exit 0
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