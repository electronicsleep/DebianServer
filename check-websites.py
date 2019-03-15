#!/usr/bin/env python

# Author: https://github.com/electronicsleep
# Purpose: DebianServer: Simple Python website check
# Released under the BSD license

import requests
import subprocess
import os

host = "check-websites-server"
server_dir = "/home/server/"

if os.path.exists(server_dir):
    cwd = server_dir
    print("Using server dir")
else:
    print("Using local dir")
    cwd = './'

path = os.path.join(cwd, "check-websites-inventory.txt")

check_websites_list = []

with open(path, 'r') as f:
    for line in f:
        check_websites_list.append(line)

if len(check_websites_list) == 0:
    print("Error: No websites defined")
    exit(1)

website_errors_list = []

count = 0
for website in check_websites_list:
    website = website.strip()
    count += 1
    try:
        r = requests.get(website)
        print(r)
        print("OK: " + website)
    except Exception as e:
        print("Error: Check website: " + website + " " + str(e))
        website_errors = "Error: Check website: " + website
        website_errors_list.append(website_errors)

if len(website_errors_list) == 0:
    print("All websites ok " + str(count) + " | error=0")
else:
    print("Website Errors found:")
    print(website_errors_list)
    subprocess.call(["bash", cwd + "slackpost.sh", host])
    subprocess.call(["bash", cwd + "slackpost.sh", str(website_errors_list)])
    exit(1)
