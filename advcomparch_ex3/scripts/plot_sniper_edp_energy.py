#!/usr/bin/env python

import sys, os
import itertools, operator
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def get_params_from_basename(basename):
    tokens = basename.split('.')
    lock_type = tokens[0].replace('d', '')
    n_threads = int(tokens[1].split('-')[0].split('_')[1])
    grain_size = int(tokens[1].split('-')[1].split('_')[1])
    return (lock_type, n_threads, grain_size)

def get_energy_from_output_file(output_file):
    EDP_1 = 0
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
    return (energy, EDP_1)

def get_time_from_output_file(output_file):
    time = -999
    with open(output_file, "r") as fp:
        for line in fp:
            if line.strip().startswith("Time"):
                time = float(line.split()[3]) / 10**6
    return time

def get_tuples_by_lock_type(tuples):
    ret = []
    tuples_sorted = sorted(tuples, key=lambda x: (x[0], x[1]))  # Sort by lock type and then by number of threads
    for key, group in itertools.groupby(tuples_sorted, operator.itemgetter(0)):
        group_list = list(group)
        group_list_sorted = sorted(group_list, key=lambda x: x[1])  # Ensure the group is sorted by number of threads
        ret.append((key, list(zip(*map(lambda x: x[1:], group_list_sorted)))))
    return ret

if len(sys.argv) < 2:
    print("usage:", sys.argv[0], "<output_directories>")
    sys.exit(1)

energy_tuples = {}
edp_tuples = {}

# Define a color map for lock types
color_map = {
    'mutex': '#ff595e',
    'tas_cas': '#ffca3a',
    'tas_ts': '#8ac926',
    'ttas_cas': '#1982c4',
    'ttas_ts': '#6a4c93'
}
default_color = 'black'

base_dir = sys.argv[1]
for dirname in os.listdir(base_dir):
    full_path = os.path.join(base_dir, dirname)
    if os.path.isdir(full_path):
        basename = os.path.basename(dirname)
        output_file = full_path + "/power.total.out"
        output_file2 = full_path + "/sim.out"

        (lock_type, n_threads, grain) = get_params_from_basename(basename)
        (energy, edp) = get_energy_from_output_file(output_file)

        energy_tuples.setdefault(grain, []).append((lock_type, n_threads, energy))
        edp_tuples.setdefault(grain, []).append((lock_type, n_threads, edp))

for grain_size in energy_tuples.keys():
    markers = ['.', 'o', 'v', '*', 'D']

    # Plot Energy vs. Number of Threads
    fig_energy, ax_energy = plt.subplots(figsize=(10, 8))
    ax_energy.set_title('Total Energy - '+'Grain Size: ' + str(grain_size) , fontsize=16)
    ax_energy.set_xlabel(r"$Number\ of\ Threads$", fontsize=14)
    ax_energy.set_ylabel(r"$Energy\ (J)$", fontsize=14)

    energy_tuples_by_lock_type = get_tuples_by_lock_type(energy_tuples[grain_size])
    edp_tuples_by_lock_type = get_tuples_by_lock_type(edp_tuples[grain_size])

    for i, tuple in enumerate(energy_tuples_by_lock_type):
        nthread_axis = tuple[1][0]
        lock_type = tuple[0]
        energy_axis = tuple[1][1]
        x_ticks = 2**np.arange(0, len(energy_axis))
        color = color_map.get(lock_type, default_color)  # Use the color from the color map
        ax_energy.plot(x_ticks, energy_axis, linewidth=1, label=str(lock_type), marker=markers[i % len(markers)], color=color)

    ax_energy.grid(visible=True)
    x_labels = map(str, nthread_axis)
    x_ticks = 2**np.arange(0, len(energy_axis))
    ax_energy.set_xticks(x_ticks)
    ax_energy.set_xticklabels(x_labels)
    ax_energy.legend(loc='upper left', prop={'size': 12})

    output_base_energy = '/home/manolis/Desktop/graphs/sniper/energy/'
    output_energy = output_base_energy + 'grain-' + str(grain_size) + '-energy.png'
    print("Saving: " + output_energy)
    fig_energy.savefig(output_energy, bbox_inches='tight')

    # Plot EDP vs. Number of Threads
    fig_edp, ax_edp = plt.subplots(figsize=(10, 8))
    ax_edp.set_title('EDP - '+'Grain Size: ' + str(grain_size), fontsize=16)
    ax_edp.set_xlabel(r"$Number\ of\ Threads$", fontsize=14)
    ax_edp.set_ylabel(r"$EDP\ (J*sec)$", fontsize=14)

    for i, tuple in enumerate(edp_tuples_by_lock_type):
        lock_type = tuple[0]
        energy_axis = tuple[1][1]
        x_ticks = 2**np.arange(0, len(energy_axis))
        color = color_map.get(lock_type, default_color)  # Use the color from the color map
        ax_edp.plot(x_ticks, energy_axis, linewidth=1, label=str(lock_type), marker=markers[i % len(markers)], color=color)

    ax_edp.grid(visible=True)
    x_labels = map(str, nthread_axis)
    x_ticks = 2**np.arange(0, len(energy_axis))
    ax_edp.set_xticks(x_ticks)
    ax_edp.set_xticklabels(x_labels)
    ax_edp.legend(loc='upper left', prop={'size': 12})
    output_base_edp = '/home/manolis/Desktop/graphs/sniper/edp/'
    output_edp = output_base_edp + 'grain-' + str(grain_size) + '-edp.png'
    print("Saving: " + output_edp)
    fig_edp.savefig(output_edp, bbox_inches='tight')
