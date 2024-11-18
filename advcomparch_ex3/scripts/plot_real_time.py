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

def get_time_from_output_file(output_file):
    time = -999
    with open(output_file, "r") as fp:
        for line in fp:
            if line.strip().startswith("Execution"):
                time = float(line.split(':')[1].split()[0])
    return time

def get_tuples_by_lock_type(tuples):
    ret = []
    tuples_sorted = sorted(tuples, key=operator.itemgetter(0))
    for key, group in itertools.groupby(tuples_sorted, operator.itemgetter(0)):
        ret.append((key, list(zip(*map(lambda x: x[1:], list(group))))))
    return ret

if len(sys.argv) < 2:
    print("usage:", sys.argv[0], "<output_directories>")
    sys.exit(1)

results_tuples = {}

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
        output_file = full_path + "/info.out"

        (lock_type, n_threads, grain) = get_params_from_basename(basename)
        time = get_time_from_output_file(output_file)
        results_tuples.setdefault(grain, []).append((lock_type, n_threads, time))

# Sort each list of tuples by the number of threads
for grain_size in results_tuples:
    results_tuples[grain_size].sort(key=lambda x: x[1])

for (grain_size, res_tuples) in results_tuples.items():
    markers = ['.', 'o', 'v', '*', 'D']
    fig, ax = plt.subplots()
    plt.grid(True)
    ax.set_xlabel(r"$Number\ of\ Threads$", fontsize=14)
    ax.set_ylabel(r"$Time\ (sec)$", fontsize=14)

    i = 0
    tuples_by_lock_type = get_tuples_by_lock_type(res_tuples)

    for tuple in tuples_by_lock_type:
        lock_type = tuple[0]
        nthread_axis = tuple[1][0]
        time_axis = tuple[1][1]
        x_ticks = 2**np.arange(0, len(time_axis))

        color = color_map.get(lock_type, default_color)  # Get color from color_map, fallback to default_color
        ax.plot(x_ticks, time_axis, linewidth=1, label=str(lock_type), marker=markers[i % len(markers)], color=color)
        i += 1


    x_labels = map(str, x_ticks)
    ax.xaxis.set_ticks(x_ticks)
    ax.xaxis.set_ticklabels(x_labels)

    # Shrink current axis by 20%
    box = ax.get_position()
    # ax.set_position([box.x0, box.y0, box.width * 0.8, box.height])
    # Put a legend to the right of the current axis
    lgd = ax.legend(ncol=1, loc='upper left', bbox_to_anchor=(0, 0.9), prop={'size': 10})
    plt.title('Grain Size: ' + str(grain_size))
    output_base = '/home/manolis/Desktop/graphs/real/'
    output = output_base + 'grain-' + str(grain_size) + '.png'
    print("Saving: " + output)
    plt.savefig(output, bbox_extra_artists=(lgd,), bbox_inches='tight')
