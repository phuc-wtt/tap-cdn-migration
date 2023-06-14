#!/usr/bin/python3

import urllib.request
import sys

input = str(sys.argv[1])

try:
    status_code = urllib.request.urlopen('https://{}'.format(input)).getcode()
    print(status_code)
except Exception as e:
    print(e, 'Trying again...')


