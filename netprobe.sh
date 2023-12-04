#!/bin/bash

# Default values for options
option1="L"
option2="5"
option3="c"
option4=""
option5=""

# Function to display usage information
display_usage() {
    echo "Usage: $0 [-L N] (-c|-2|-r|-F|-t) [-e] <filename>"
    echo "Options:"
    echo "  -L N: Limit the number of results to N (default: 5)"
    echo "  -c: Which IP address makes the most number of connection attempts?"
    echo "  -2: Which address makes the most number of successful attempts?"
    echo "  -r: What are the most common result codes, and where do they come from?"
    echo "  -F: What are the most common result codes that indicate failure and where do they come from?"
    echo "  -t: Which IP number gets the most bytes sent to them?"
    echo "  -e: Enable DNS blacklist checking"
}

BLACKLISTED_DNS="dns.blacklist.txt"

isBlacklisted() {
    local ip="$1"

    if [ -f "$BLACKLISTED_DNS" ]; then
        local domain

        # Resolve the IP address to its DNS domain using dig
        domain=$(dig +short -x "$ip" | sed 's/\.$//')  # Reverse DNS lookup

        if [ -n "$domain" ]; then
            # Check if the domain is blacklisted
            if grep -q "$domain" "$BLACKLISTED_DNS"; then
                return 0  # IP is blacklisted
            fi
        fi

        return 1  # IP is not blacklisted
    else
        echo "DNS blacklist file not found."
        return 1  # Assume IP is not blacklisted
    fi
}


process_input() {
    while IFS= read -r line; do
        # Extract the IP address and count from the line
        ip_count=$(echo "$line" | awk '{print $1, $2}')
        ip=$(echo "$ip_count" | awk '{print $1}')

        # Check if the IP is blacklisted by any DNS server
        if isBlacklisted "$ip"; then
            echo "$line *blacklisted*"
        else
            echo "$line"
        fi
    done
}





# Parse command line arguments
while getopts ":L:c2rFte" opt; do
    case "$opt" in
    L)
        option1="L"
        option2="$OPTARG"
        ;;
    c | 2 | r | F | t) option3="$opt" ;;
    e) option4="e" ;;
    *)
        display_usage
        exit 1
        ;;
    esac
done

# Shift option arguments
shift $((OPTIND - 1))

# Check if the filename is provided
if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

# Assign the filename
option5="$1"

# Validate the number of lines option
if [[ "$option1" == "L" && ! "$option2" =~ ^[0-9]+$ ]]; then
    echo "Number of lines flag is given, but the number is not valid."
    display_usage
    exit 1
fi

# Process based on the selected option
case "$option3" in
c)
    echo "Which IP address makes the most number of connection attempts? $option5"
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "${option5}" | sort | uniq -c | sort -nr | head -n "${option2}" | awk '{printf "%-15s %s\n", $2, $1}' |
    if [ "$option4" = "e" ]; then
            process_input
        else
            cat 
        fi
    ;;
2)
    echo "Which IP address makes the most number of successful attempts? $option5"
    grep ' 200 ' "${option5}" | cut -d ' ' -f 1,9 | sort | uniq -c | sort -nr | head -n "${option2}" | awk '{printf "%-15s %s\n", $2, $1}' | 
    if [ "$option4" = "e" ]; then
            process_input
        else
            cat 
        fi
    ;;
r)
    echo "What are the most common result codes, and where do they come from? $option5"

    touch 401.txt 404.txt 200.txt 304.txt 302.txt 403.txt

    grep ' 401 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >401.txt
    grep ' 404 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >404.txt
    grep ' 200 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >200.txt
    grep ' 304 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >304.txt
    grep ' 302 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >302.txt
    grep ' 403 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >403.txt

    declare -A counts

    counts["401"]=$(wc -l <401.txt)
    counts["404"]=$(wc -l <404.txt)
    counts["403"]=$(wc -l <403.txt)
    counts["200"]=$(wc -l <200.txt)
    counts["304"]=$(wc -l <304.txt)
    counts["302"]=$(wc -l <302.txt)

    sorted_keys=($(for key in "${!counts[@]}"; do

        echo "$key ${counts[$key]}"

    done | sort -rn -k2 | cut -d ' ' -f1))

    for key in "${sorted_keys[@]}"; do
        filename="${key}.txt"

        echo " $key  (Status Code Count: ${counts[$key]})"

        cat "$filename" | head -n "${option2}" |
        if [ "$option4" = "e" ]; then
            process_input
        else
            cat 
        fi

        echo

    done
    rm 401.txt 404.txt 200.txt 304.txt 302.txt 403.txt
    ;;
F)
    echo "What are the most common result codes that indicate failure and where do they come from? $option5"

    touch 401.txt 404.txt 403.txt

    grep ' 401 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >401.txt
    grep ' 404 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >404.txt
    grep ' 403 ' "${option5}" | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | awk '{printf "%-15s %s\n", $2, $1}' >403.txt

    declare -A counts

    counts["401"]=$(wc -l <401.txt)
    counts["404"]=$(wc -l <404.txt)
    counts["403"]=$(wc -l <403.txt)

    sorted_keys=($(for key in "${!counts[@]}"; do
        echo "$key ${counts[$key]}"
    done | sort -rn -k2 | cut -d ' ' -f1))

    for key in "${sorted_keys[@]}"; do
        filename="${key}.txt"
        echo " $key  (Status Code Count: ${counts[$key]})"
        cat "$filename" | head -n "${option2}" | 
        if [ "$option4" = "e" ]; then
            process_input
        else
            cat 
        fi
        echo

    done
    rm 401.txt 404.txt 403.txt
    ;;
t)
    echo "Which IP number gets the most bytes sent to them? $option5"
    cut -d ' ' -f 1,10 "${option5}" | grep -v "-" | sort >data.txt

    declare -A ip_to_sum_of_bytes
    while read -r row; do
        ip=$(echo "$row" | cut -d " " -f 1)
        bytes=$(echo "$row" | cut -d " " -f 2)

        # If the IP address is not in the associative array, add it

        if [ -z "${ip_to_sum_of_bytes[$ip]}" ]; then
            ip_to_sum_of_bytes[$ip]=$bytes

        else

            # If the IP address is in the associative array, update the sum of bytes

            ip_to_sum_of_bytes[$ip]=$((ip_to_sum_of_bytes[$ip] + bytes))

        fi

    done <data.txt

    # Sort the IP addresses by the sum of bytes in descending order

    sorted_ips=$(for ip in "${!ip_to_sum_of_bytes[@]}"; do

        echo "$ip ${ip_to_sum_of_bytes[$ip]}"

    done | sort -k2,2nr)

    # Print the top 10 IP addresses

    echo "Top $option2 IP addresses by total bytes:"

    echo "$sorted_ips" | awk '{printf "%-15s %s\n", $1, $2}' | head -n "${option2}" | 
    if [ "$option4" = "e" ]; then
            process_input
        else
            cat 
        fi

    rm data.txt
    ;;
*)
    display_usage
    exit 1
    ;;
esac

if [ "$option4" == "e" ]; then
    echo "DNS blacklist checking is enabled."
    
fi
