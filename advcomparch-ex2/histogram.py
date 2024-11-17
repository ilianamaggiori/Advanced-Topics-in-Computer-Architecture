import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Function to extract branch statistics from a file
def extract_branch_stats(filename):
    try:
        with open(filename, 'r') as file:
            lines = file.readlines()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)

    stats = {
        'Total': 0,
        'Conditional Taken': 0,
        'Conditional Not Taken': 0,
        'Unconditional': 0
    }

    for line in lines:
        line = line.strip()
        if line.startswith('Total-Branches:'):
            stats['Total'] = int(line.split(':')[1].strip())
        elif line.startswith('Conditional-Taken-Branches:'):
            stats['Conditional Taken'] = int(line.split(':')[1].strip())
        elif line.startswith('Conditional-NotTaken-Branches:'):
            stats['Conditional Not Taken'] = int(line.split(':')[1].strip())
        elif line.startswith('Unconditional-Branches:'):
            stats['Unconditional'] = int(line.split(':')[1].strip())

    return stats

# Calculate percentages
def calculate_percentages(stats):
    total_branches = stats['Total']
    conditional_taken = stats['Conditional Taken']
    conditional_not_taken = stats['Conditional Not Taken']
    unconditional = stats['Unconditional']

    total_percent = total_branches / total_branches * 100
    conditional_taken_percent = conditional_taken / total_branches * 100
    conditional_not_taken_percent = conditional_not_taken / total_branches * 100
    unconditional_percent = unconditional / total_branches * 100

    return {
        'Total': total_percent,
        'Conditional Taken': conditional_taken_percent,
        'Conditional Not Taken': conditional_not_taken_percent,
        'Unconditional': unconditional_percent
    }

# Plotting function
def plot_histogram(percentages, filename):
    branches = list(percentages.keys())
    percentages = list(percentages.values())

    plt.barh(branches, percentages, color='skyblue')
    plt.xlabel('Percentage of Branches')
    plt.ylabel('Branch Type')
    plt.title('Branch Statistics')
    plt.gca().invert_yaxis()  # Invert y-axis to have the highest percentage at the top
    plt.savefig(filename)
    plt.show()

# Main function
def main():
    if len(sys.argv) != 2:
        print("Usage: python histogram.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    branch_stats = extract_branch_stats(filename)
    percentages = calculate_percentages(branch_stats)
    output_filename = filename.split('.')[0] + "_histogram.png"
    plot_histogram(percentages, output_filename)
    print(f"Histogram image saved as {output_filename}")

if __name__ == "__main__":
    main()

