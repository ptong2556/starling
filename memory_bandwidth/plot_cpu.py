import os
import pandas as pd
import matplotlib.pyplot as plt

def read_and_process_csv_files(directory_path):
    """
    Reads all CSV files in the given directory and processes their data.

    Parameters:
    - directory_path (str): The path to the directory containing CSV files.

    Returns:
    - data_dict (dict): A dictionary where keys are filenames and values are DataFrames of CSV data.
    """
    data_dict = {}

    for filename in os.listdir(directory_path):
        file_path = os.path.join(directory_path, filename)
        try:
            with open(file_path, 'r') as file:
                lines = file.read().splitlines()
            #df = pd.read_csv(file_path)
            data_dict[filename] = lines
        except Exception as e:
            print(f"Error reading {filename}: {e}")

    return data_dict

def plot_cpu_utilization(file_name, csv_data):
    plt.figure(figsize = (20, 10))
    cpu_utilizations = [float(line.split()[-4]) for i, line in enumerate(csv_data) if i % 3 == 0]
    iterations = [i for i in range(1, len(cpu_utilizations) + 1)]
            #print(cpu_utilization)
    
    plt.scatter(iterations, cpu_utilizations)
    output_path = 'cpu_utilization_visualizations/' + file_name
    plt.savefig(output_path)


if __name__ == '__main__':
    data_dict = read_and_process_csv_files("cpu_results/")
    plot_cpu_utilization('10_0_0_16_results.jpeg', data_dict['10_0_0_16_results.csv'])
    plot_cpu_utilization('10_0_1000000_16_results.jpeg', data_dict['10_0_1000000_16_results.csv'])


