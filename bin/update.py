#!/usr/bin/python
import colorama
from colorama import Fore,Style
import json
import requests
import os
from datetime import datetime
import subprocess

def log_info():
    return Style.BRIGHT + '[' + Fore.GREEN + 'INFO' + Fore.RESET + ']' + Style.RESET_ALL

def log_error():
    return Style.BRIGHT + '[' + Fore.RED + 'ERROR' + Fore.RESET + ']' + Style.RESET_ALL

def check_update(package):
    print(log_info(), "Package: ", package)
    response = requests.get(
            'https://aur.archlinux.org/rpc/',
            params={ 'v' : '5' , 'type': 'info', 'arg[]': package}
            )
    if response:
        json_response = response.json()
        if json_response['type'] == 'error':
            print(log_error(), json_response['error'])
            return
        elif json_response['type'] == 'multiinfo':
            if int(json_response['resultcount']) == 0:
                print(log_error(), "Couldn't find package: ", package)
                return
            remote_time = json_response['results'][0]['LastModified']
            time = os.path.getmtime(package + "/PKGBUILD")
            print(log_info(), "Local Modification Time:", datetime.utcfromtimestamp(time).strftime("%Y/%m/%d %H:%M:%S"))
            print(log_info(),"Remote Modification Time:", datetime.utcfromtimestamp(remote_time).strftime("%Y/%m/%d %H:%M:%S"))
            if time < remote_time:
                print(log_info(),"Updating package:", package)
                updater = subprocess.Popen(["auracle", "download", package], universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                out = updater.stdout
                for line in out:
                    print(line, end='')
                

        else:
            print(log_error(), "Fucking Error")
            print(json_response)

def main():
    for pkg in [f.name for f in os.scandir(".") if f.is_dir()]:
        check_update(pkg)
        print("\n")


if __name__ == "__main__":
    colorama.init(autoreset=True)
    main()
