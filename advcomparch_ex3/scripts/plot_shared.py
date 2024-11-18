#!/usr/bin/env python

import sys
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def get_params_from_basename(basename):
    tokens = basename.split('.')
    lock_type = tokens[0].replace('d', '')
    n_threads = int(tokens[1].split('-')[0].split('_')[1])
    grain_size = int(tokens[1].split('-')[1].split('_')[1])
    name = tokens[1].split('_')[3]
    return (lock_type, n_threads, grain_size, name)

def get_time_from_output_file(output_file):
    time = -999
    with open(output_file, "r") as fp:
        for line in fp:
            if line.strip().startswith("Cycles"):
                time = float(line.split()[2])
                break
    return time

def get_energy_from_output_file(output_file):
    EDP_1 = 0
    energy = 0
    with open(output_file, "r") as fp:
        for line in fp:
            if 'total' in line:
                power = float(line.split()[1])
                if line.split()[2] == 'kW':
                    power *= 1000.0
                elif line.split()[2] == 'mW':
                    power /= 1000.0

                energy = float(line.split()[3])
                if line.split()[4] == 'kJ':
                    energy *= 1000.0
                elif line.split()[4] == 'mJ':
                    energy /= 1000.0

                delay = energy / power
                EDP_1 = energy * delay
                break
    return (energy, EDP_1)

if len(sys.argv) < 2:
    print("usage:", sys.argv[0], "<output_directories>")
    sys.exit(1)

results_tuples = {}
base_dir = sys.argv[1]
for dirname in os.listdir(base_dir):
    full_path = os.path.join(base_dir, dirname)
    if os.path.isdir(full_path):
        basename = os.path.basename(full_path)
        output_file = os.path.join(full_path, "sim.out")
        output_file2 = os.path.join(full_path, "power.total.out")

        (lock_type, n_threads, grain, name) = get_params_from_basename(basename)
        time = get_time_from_output_file(output_file)
        (en, edp) = get_energy_from_output_file(output_file2)
        results_tuples.setdefault((name), []).append((lock_type, time, en, edp))

def plot_metric(ax, metric, ylabel, title, results_tuples, colors, width):
    i = 0
    for lock_type, values_tuples in results_tuples.items():
        y = [val for (_, val, _, _) in sorted(values_tuples, key=lambda x: x[0])] if metric == 'time' else \
            [val for (_, _, val, _) in sorted(values_tuples, key=lambda x: x[0])] if metric == 'energy' else \
            [val for (_, _, _, val) in sorted(values_tuples, key=lambda x: x[0])]
        
        topologies = [typ for (typ, _, _, _) in sorted(values_tuples, key=lambda x: x[0])]
        x = np.arange(len(topologies))

        ax.bar(x + i * width, y, color=colors[i], width=width, label=lock_type, zorder=4)
        i += 1

    axes = plt.gca()
    axes.yaxis.grid(zorder=1)
    plt.xticks(x + 1.5 * width, topologies)
    ax.set_xlabel(r"$Synchronization\ Mechanism$", fontsize=14)
    ax.set_ylabel(ylabel, fontsize=14)
    ax.set_title(title, fontsize=16)
    box = ax.get_position()
    ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))

colors = ['green', 'lightblue', 'hotpink']
width = 0.20

# Plotting Cycles
fig, ax = plt.subplots(figsize=(15, 10))
plot_metric(ax, 'time', r"$Cycles$", r"$Time\ Analysis$", results_tuples, colors, width)
ax.title.set_fontsize(18)
output_base = '/home/iliana/Downloads/advcomparch_ask3/graphs/shared'
output = os.path.join(output_base, 'time-analysis.png')
print("Saving:", output)
plt.savefig(output, bbox_inches='tight')

# Plotting Energy
fig, ax = plt.subplots(figsize=(15, 10))
plot_metric(ax, 'energy', r"$Energy\ (J)$", r"$Energy\ Analysis$", results_tuples, colors, width)
ax.title.set_fontsize(18)
output = os.path.join(output_base, 'energy-analysis.png')
print("Saving:", output)
plt.savefig(output, bbox_inches='tight')

# Plotting EDP
fig, ax = plt.subplots(figsize=(15, 10))
plot_metric(ax, 'edp', r"$EDP\ (J*s)$", r"$EDP\ Analysis$", results_tuples, colors, width)
ax.title.set_fontsize(18)
output = os.path.join(output_base, 'edp-analysis.png')
print("Saving:", output)
plt.savefig(output, bbox_inches='tight')
