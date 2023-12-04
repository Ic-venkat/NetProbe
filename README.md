# NetProbe - Server Network Traffic Analyzer

## Project Description
NetProbe is a powerful shell script designed for analyzing a server's network traffic by processing web server log files. It extracts valuable information summaries to help system administrators identify anomalies and potential security issues. The script provides insights into connection attempts, successful connections, common result codes, and more.

## Features
- Identify IP addresses with the most connection attempts.
- Determine IP addresses with the most successful connection attempts.
- Explore common result codes and their corresponding IP addresses.
- Identify common result codes indicating failure and their sources.
- Find the IP address that receives the most bytes from the server.

## Usage
```bash
./netprobe.sh [-L N] (-c|-2|-r|-F|-t) <filename>
```

### Options:
- `-L N`: Limit the number of results to N.
- `-c`: IP addresses with the most connection attempts.
- `-2`: IP addresses with the most successful connection attempts.
- `-r`: Common result codes and their corresponding IP addresses.
- `-F`: Result codes indicating failure and their sources.
- `-t`: IP address receiving the most bytes from the server.

## Example Usage
### Top 10 Most Connection-Intensive IP Addresses
```bash
./netprobe.sh -L 10 -c thttpd.log
```
Output:
```
213.64.237.230 2438
213.64.225.123 1202
213.64.141.89 731
213.64.64.53 591
213.64.214.124 480
213.64.55.182 429
213.64.246.37 400
213.64.153.92 336
213.64.100.52 336
213.64.19.224 272
```

### Common Result Codes and Their Sources
```bash
./netprobe.sh -L 3 -r thttpd.log
```
Output:
```
404 127.0.0.1
404 xxx.xxx.xxx.xxx
404 xxx.xxx.xxx.xxx
200 xxx.xxx.xxx.xxx
200 xxx.xxx.xxx.xxx
200 127.0.0.1
403 xxx.xxx.xxx.xxx
403 xxx.xxx.xxx.xxx
```

### IP Address Receiving the Most Bytes
```bash
./netprobe.sh -L 3 -t thttpd.log
```
Output:
```
xxx.xxx.xxx.xxx 19109572
xxx.xxx.xxx.xxx 18043610
xxx.xxx.xxx.xxx 1915720
```

## Optional DNS Blacklist Check
To check for blacklisted IPs, use the `-e` option in combination with other arguments.
```bash
./netprobe.sh -L 200 -c -e thttpd.log
```
Output:
```
213.64.237.230 2438
213.64.225.123 1202
213.64.141.89 731
...
xxx.xxx.xxx.xxx *Blacklisted!*
...
```

## Requirements
- Shell environment (bash)
- DNS blacklist file: `dns.blacklist.txt`

## Note
This script avoids major processing using awk..

Feel free to customize and enhance the script based on your needs. Contributions and feedback are welcome!
