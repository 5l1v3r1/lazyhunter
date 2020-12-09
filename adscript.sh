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
           _               _       _   
  __ _  __| |___  ___ _ __(_)_ __ | |_ 
 / _\` |/ _\` / __|/ __| '__| | '_ \| __|
| (_| | (_| \__ \ (__| |  | | |_) | |_ 
 \__,_|\__,_|___/\___|_|  |_| .__/ \__| ${green}v1.0.0 ${blue}
----------------------------|_| ${yellow}By Dr. Signed ${blue}-----
---------------------------------------------------"${reset}
}

display_usage() {
	banner

	while read -r line
	do
		printf "%b\n" "${line}"
	done <<-EOF
	\r Usage:
	\r   ${script_file_name} [OPTIONS]

	\r Options:
	\r   -d, --domain\t\t domain to AD on
	\r   -u, --use\t\t subs' sources to use
	\r   -e, --exclude\t subs' sources to exclude
	\r       --resolve\t resolve subdomains
	\r       --screenshot\t take screenshots
	\r   -o, --output\t\t output directory path
	\r   -k, --keep\t\t keep each tool's temp results
	\r   -n, --notify\t\t send notifications
	\r   -h, --help\t\t display this message and exit
	
	\r HAPPY HACKING ! :)

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
		signotify
		subfinder
		findomain
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
	local amass_output="${output}/temp-amass-subdomains.txt"

	printf "    [${green}+${reset}] amass"
	printf "\r"
	amass enum -passive -d ${domain} -o ${amass_output} &> /dev/null
	echo -e "    [${green}+${reset}] amass: $(wc -l < ${amass_output})"
}

_sigsubs() {
	local sigsubs_output="${output}/temp-sigsubs-subdomains.txt"

	printf "    [${green}+${reset}] sigsubs"
	printf "\r"
	sigsubs -d ${domain} -s 1> ${sigsubs_output} 2> /dev/null
	echo -e "    [${green}+${reset}] sigsubs: $(wc -l < ${sigsubs_output})"
}

_findomain() {
	local findomain_output="${output}/temp-findomain-subdomains.txt"

	printf "    [${green}+${reset}] findomain"
	printf "\r"
	findomain -t ${domain} -q 1> ${findomain_output} 2> /dev/null
	echo -e "    [${green}+${reset}] findomain: $(wc -l ${findomain_output} | awk '{print $1}' 2> /dev/null)"
}

_subfinder() {
	local subfinder_output="${output}/temp-subfinder-subdomains.txt"

	printf "    [${green}+${reset}] subfinder"
	printf "\r"
	subfinder -d ${domain} -silent 1> ${subfinder_output} 2> /dev/null
	echo -e "    [${green}+${reset}] subfinder: $(wc -l < ${subfinder_output})"
}

main() {
	check_tools
	banner

	echo -e "
[${yellow}*${reset}] asset discovery on ${bold}${underline}${domain}${reset}
"

	[ ! -d ${output} ] && mkdir -p ${output}

	# {{ SUNDOMAIN GATHERING

	echo -e "[${green}+${reset}] subdomains gathering"

	subdomains="${output}/subdomains.txt"

	[ ${sources_to_use} == False ] && [ ${sources_to_exclude} == False ] && {
		for source in "${sources[@]}"
		do 
			_${source}
		done
	} || {
		[ ${sources_to_use} != False ] && {
			for source in "${sources_to_use_dictionary[@]}"
			do 
				_${source}
			done
		} 
		[ ${sources_to_exclude} != False ] && {
			for source in ${sources[@]}
			do
				if [[ " ${sources_to_exclude_dictionary[@]} " =~ " ${source} " ]]
				then
					continue
				else
					_${source}
				fi
			done
		}
	}

	cat ${output}/temp-*-subdomains.txt | sed 's#*.# #g' | anew -q ${subdomains}
	echo -e "    [=] unique subdomains: $(wc -l < ${subdomains})"

	[ ${keep} == False ] && rm ${output}/temp-*-subdomains.txt

	# }}
	# {{ SUBDOMAINS RESOLUTION

	[ ${resolve} == True ] && {
		echo -e "[${green}+${reset}] subdomain resolution"

		ips="${output}/ips.txt"
		resolved_subdomains="${output}/resolved-subdomains.txt"

		local massdns_output="${output}/temp-massdns-resolve.txt"

		printf "    [${green}+${reset}] resolving"
		printf "\r"
		massdns -r ${HOME}/tools/web-sec/discovery/dns/massdns/lists/resolvers.txt -q -t A -o S -w ${massdns_output} ${subdomains}
		echo -e "    [${green}+${reset}] resolved!"

		printf "    [${green}+${reset}] resolved IPs"
		printf "\r"
		egrep -o -h "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" ${massdns_output} | sort -u | anew -q ${ips}
		echo -e "    [${green}+${reset}] resolved IPs: $(wc -l < ${ips})"

		printf "    [${green}+${reset}] resolved subdomains"
		printf "\r"
		cat ${massdns_output} | grep -Po "^[^-*\"]*?\K[[:alnum:]-]+\.${domain}" | sort -u | anew -q ${resolved_subdomains}
		echo -e "    [${green}+${reset}] resolved subdomains: $(wc -l < ${resolved_subdomains})"

		[ ${keep} == False ] && rm ${output}/temp-*-resolve.txt
	}

	# }}
	# {{ HTTP(S) PROBING

	[ ${resolve} == True ] && [ ${httprobe} == True ] && {
		echo -e "[${green}+${reset}] http(s) probing"

		hosts="${output}/hosts.txt"

		[ ${notify} == True ] && {
			httpx -l ${resolved_subdomains} -silent | anew ${hosts} | awk '{print new ": `" $0 "`"}' new="script4assets: New host for ${domain}" | signotify
		} || {
			httpx -l ${resolved_subdomains} -silent | anew -q ${hosts} 
		}
	}

	# }}
	# {{ VISUAL RECONNAISSANCE

	[ ${resolve} == True ] && [ ${httprobe} == True ] &&[ ${screenshot} == True ] && {
		echo -e "[${green}+${reset}] visual reconnaissance"

		visual_reconnaissance="${output}/visual-reconnaissance"
		[ ! -d ${visual_reconnaissance} ] && mkdir -p ${visual_reconnaissance}

		cat ${hosts} | aquatone -threads=5 -http-timeout 10000 -out ${visual_reconnaissance} &> /dev/null
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

output="$(pwd)/asset-discovery"

sources=(
	amass
	sigsubs
	findomain
	subfinder
)
sources_to_use=False
sources_to_exclude=False

while [[ "${#}" -gt 0 && ."${1}" == .-* ]]
do
	case "$(echo ${1} | tr '[:upper:]' '[:lower:]')" in
		-d | --domain)
			domain=${2}
			shift
		;;
		-u | --use)
			sources_to_use=${2}
			sources_to_use_dictionary=${sources_to_use//,/ }

			for i in ${sources_to_use_dictionary}
			do
				if [[ ! " ${sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		-e | --exclude)
			sources_to_exclude=${2}
			sources_to_exclude_dictionary=${sources_to_exclude//,/ }

			for i in ${sources_to_exclude_dictionary}
			do
				if [[ ! " ${sources[@]} " =~ " ${i} " ]]
				then
					echo -e "[-] Unknown Task: ${i}"
					exit 1
				fi
			done
			shift
		;;
		--resolve) resolve=True ;;
		--httprobe) httprobe=True ;;
		--screenshot) screenshot=True ;;
		-o | --output)
			output="${2}/asset-discovery"
			shift
		;;
		-k | --keep) keep=True ;;
		-n | --notify) notify=True ;;
		-h | --help) 
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