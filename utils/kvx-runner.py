#! /usr/bin/python3
#
# Copyright (C) 2020-2020 Kalray SA.
#
# All rights reserved.
#

import re,os,subprocess,sys

usage="usage: kvx-runner.py [-march <arch>] [-no_omp_envs] [-env <var>=<value>] [-p] --(hw|iss|qemu) <exec> <args>"

if(len(sys.argv) < 3):
    print(usage)
    exit(1)

args = sys.argv[1:]
#Get arch, currently it only supports kv3-1 and kv3-2
arch="kv3-1"
if (args[0] == "-march"):
    arch = args[1]
    args = args[2:]

envs=[]
# Get OMP/KMP variables from the environment
if (args[0] == '-no_omp_envs'):
    args = args[1:]
else:
    envs = [f"{k}='{os.environ[k]}'" for k in os.environ if re.match(r"^(OMP|KMP)", k)]

# Get all user defined -env values
while (args[0] == "-env"):
    envs.append(f"'{args[1]}'")
    args = args[2:]

env=" ".join(envs).strip()

#Find out the runner
runner = args[0]
args = args[1:]

if (arch != "kv3-1" and arch != "kv3-2"):
    print("Unsupported arch: " + arch)
    print(usage)
    exit(2)

if runner == "--hw":
    if (arch != "kv3-1"):
        print(f"--hw does not support running arch:{arch}")
        print(usage)
        exit(3)

    if (len(env)):
        all_clusters = "--envs=\""
        env = env.replace(",", "\,")
        # Fixme: for future archs the number of clusters might not be 5
        for x in range(5):
            all_clusters += f"Cluster{x}:{env} "
        env = all_clusters.strip() + '"'
    cmd = ["kvx-jtag-runner",
            env,
           "--no-printf-prefix",
           "--"] + args[0:]

elif runner == "--iss":
    cmd = ["kvx-mppa",
           f"--march={arch}",
           "--", env ] + args[0:]

elif runner == "--qemu":
    if (len(env)): #T21616
        env = env.replace(",", ",,").replace('"', '\\"')
        env = ',mppa-argarea-env="' + env + '"'


    cmd = ["qemu-system-kvx",
        "-display", "none",
        "-nographic",
        "-semihosting",
        "-m", "2G",
        "-M", f"mppa-coolidge-v{arch[-1]}" + env,
        "-kernel", args[0]]

    args = args[1:]

    if (len(args) != 0):
        cmd.append("-append")
        cmd.append("\"{}\"".format(" ".join(args).replace('"', '\\"')))

else:
    print(f"Unknown runner:{runner}")
    print(usage)
    exit(5)

cmd_str = " ".join(cmd)
ret = subprocess.run(cmd_str, shell=True).returncode
if (ret != 0):
    print(f"Failed command: {cmd_str}", file=sys.stderr)
sys.exit(ret)
