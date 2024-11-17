import os
import sys
import matplotlib.pyplot as plt
import random


def read_branch_data(file_path):
    branches_data = {}
    with open(file_path, 'r') as file:
        for line in file:
            if line.strip().startswith("Total-Branches:"):
                total_branches = int(line.split(":")[1].strip())
                branches_data["Total-Branches"] = total_branches
            elif line.strip().startswith("Conditional-Taken-Branches:"):
                taken_branches = int(line.split(":")[1].strip())
                branches_data["Conditional-Taken-Branches"] = taken_branches
            elif line.strip().startswith("Conditional-NotTaken-Branches:"):
                not_taken_branches = int(line.split(":")[1].strip())
                branches_data["Conditional-NotTaken-Branches"] = not_taken_branches
            elif line.strip().startswith("Unconditional-Branches:"):
                unconditional_branches = int(line.split(":")[1].strip())
                branches_data["Unconditional-Branches"] = unconditional_branches
            elif line.strip().startswith("Calls:"):
                calls = int(line.split(":")[1].strip())
                branches_data["Calls"] = calls
            elif line.strip().startswith("Returns:"):
                returns = int(line.split(":")[1].strip())
                branches_data["Returns"] = returns
    return branches_data

def get_benchmark_name(file_name):
    return file_name.split('.cslab_branch_predictors.out')[0]  # Extract the benchmark name

def plot_branch_histogram(branches_data, benchmark_name):
    total_branches = branches_data["Total-Branches"]
    percentages = {key: (value / total_branches) * 100 for key, value in branches_data.items()}

    plt.figure(figsize=(10, 8))
    bars = plt.bar(percentages.keys(), percentages.values(), color='blue')
    plt.xlabel('Branch Types',fontweight='bold', fontsize=12)
    plt.ylabel('% Percentage of Branches',fontweight='bold',fontsize=12 )
    plt.title(f'Branch Statistics of benchmark "{benchmark_name}"', fontweight='bold',fontsize=13)
    plt.xticks(ha='center', rotation=45)

    plt.tight_layout()
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + (bar.get_width()+random.random()) / 2.0, height, f'Number of branches ={int(total_branches * height / 100)}', ha='center', va='bottom', rotation=20)

    plt.tight_layout()

    save_path = os.path.join('/home/iliana/Downloads/advcomparch-ex2-helpcode/outputs_4.1/plot_4.1', f'{benchmark_name}_branch_statistics.png')
    plt.savefig(save_path)


if __name__ == "__main__":
    files = [f for f in os.listdir('.') if f.endswith('.out')]  # List all files with .out extension in the current directory

    for file_name in files:
        benchmark_name = get_benchmark_name(file_name)  # Extract the benchmark name from the file name
        branches_data = read_branch_data(file_name)
        plot_branch_histogram(branches_data, benchmark_name)
        plt.close()  # Close the plot to prevent displaying multiple plots simultaneously

