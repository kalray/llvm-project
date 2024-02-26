#!/usr/bin/env python3
# Do ./errors_filter.py csw/build_llvm_Release/results.json to update errors.log

import os
import sys
import json

data    = json.loads(open (sys.argv[1]).read())
names = []
for d in data['tests']:
    if (d['code'] == 'PASS') or (d['code'] == 'XFAIL') or (d['code'] == 'UNSUPPORTED'):
        continue
    s = d['code'] + ": " + d['name']
    names.append(s)
    print ("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV")
    print (s)
    print ("")
    print ("")
    print (d['output'])
    print ("")
    print ("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")

names.sort()
with open("errors.log", "w") as f:
    for d in names:
        print ("\t" + d, file=f)
    print ("Failures: ", len(names), file=f)
