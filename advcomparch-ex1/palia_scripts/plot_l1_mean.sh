#!/usr/bin/env python3

import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

output_folder = "/home/iliana/Downloads/parsec-3.0/parsec_workspace/outputs"
CONFS = ["32_4_32", "32_4_64", "32_4_128", "32_8_32", "32_8_64", "32_8_128", 
         "64_4_64", "64_8_32", "64_8_64", "64_8_128", "128_8_32", "128_8_64", "128_8_128"]

x_Axis = []
ipc_Axis = []
mpki_Axis = []

for conf in CONFS:
    file_name = "L1_" + conf + "_mean_values.txt"
    with open(os.path.join(output_folder, file_name), 'r') as file:
        mean_ipc = None
        mean_mpki = None
        for line in file:
            if line.startswith("Mean IPC:"):
                mean_ipc = float(line.split(":")[1])
            elif line.startswith("Mean MPKI:"):
                mean_mpki = float(line.split(":")[1])
            if mean_ipc is not None and mean_mpki is not None:
                break
        if mean_ipc is not None and mean_mpki is not None:
            x_Axis.append(conf.replace("_", "."))
            ipc_Axis.append(mean_ipc)
            mpki_Axis.append(mean_mpki)

fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("CacheSize{K}.Assoc.BlockSize{B}")

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(ipc_Axis) - 0.05 * min(ipc_Axis), max(ipc_Axis) + 0.05 * max(ipc_Axis))
ax1.set_ylabel("$IPC$")
line1 = ax1.plot(ipc_Axis, label="ipc", color="red", marker='x')

ax2 = ax1.twinx()
ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax2.set_xticklabels(x_Axis, rotation=45)
ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
ax2.set_ylim(min(mpki_Axis) - 0.05 * min(mpki_Axis), max(mpki_Axis) + 0.05 * max(mpki_Axis))
ax2.set_ylabel("$MPKI$")
line2 = ax2.plot(mpki_Axis, label="L1D_mpki", color="green", marker='o')

lns = line1 + line2
labs = [l.get_label() for l in lns]

plt.title("IPC vs MPKI")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("L1_mean.png", bbox_inches="tight")
