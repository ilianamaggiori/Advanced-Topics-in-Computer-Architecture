#!/usr/bin/env python3

import sys
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Initialize lists to hold the data
x_Axis = []
mpki_Axis = []

# Process each output file passed as a command-line argument
for outFile in sys.argv[1:]:
    with open(outFile, 'r') as fp:
        for line in fp:
            if line.startswith("For RAS with"):
                # Extract predictor name
                tokens = line.split()
                predictor = tokens[3]
                x_Axis.append(predictor)
            elif line.startswith("Mean MPKI:"):
                # Extract MPKI value
                tokens = line.split()
                mpki = float(tokens[2])
                mpki_Axis.append(mpki)

# Verify that data has been collected correctly
print(x_Axis)
print(mpki_Axis)

# Plot the data
fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("Entries")

#xAx = np.arange(len(x_Axis))
#ax1.set_xticks(xAx)
#ax1.set_xticklabels(x_Axis, rotation=45)
#ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
#ax1.set_ylim(0, max(mpki_Axis) * 1.05)
#ax1.set_ylabel("Mean MPKI")
xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(mpki_Axis) - 0.05, max(mpki_Axis) + 0.05)
ax1.set_ylabel("$MPKI$")


# Plot MPKI values
line1 = ax1.plot(xAx, mpki_Axis, label="MPKI", color="blue", marker='o')

# Set plot title and legend
plt.title("Mean MPKI for Different Number of Entries (RAS)")
plt.legend()
plt.tight_layout()

# Save the plot to a file
plt.savefig("ras_MPKI.png", bbox_inches="tight")

