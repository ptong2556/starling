import os
import pandas as pd
import matplotlib.pyplot as plt

class VisualizeBenchmarks():
    def __init__(self, directory):
        self.data_dict = self.read_and_process_csv_files(directory)
        
    def read_and_process_csv_files(self, directory_path):
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

    def compare_visualizations(self, output_file, data_files):
        plt.figure(figsize = (20, 10))
        for file in data_files:
            csv_data = self.data_dict[file]
            cpu_utilizations = [float(line.split()[-4]) for i, line in enumerate(csv_data) if i % 3 == 0]
            iterations = [i for i in range(1, len(cpu_utilizations) + 1)]
            
            plt.plot(iterations, cpu_utilizations, label = file, marker = 'o')
        
        plt.legend()
        output_path = 'cpu_utilization_visualizations/' + output_file
        plt.savefig(output_path)

    def plot_cpu_utilization(self, output_file, data_file):
        """
        Plots the CPU utilization from a given CSV file.

        Parameters:
        - file_name (str): The name of the file to plot (without directory).
        - csv_data (list): The data from the CSV file.

        Returns:
        - None
        """
        csv_data = self.data_dict[data_file]
        plt.figure(figsize = (20, 10))
        cpu_utilizations = [float(line.split()[-4]) for i, line in enumerate(csv_data) if i % 3 == 0]
        iterations = [i for i in range(1, len(cpu_utilizations) + 1)]
        
        plt.plot(iterations, cpu_utilizations, marker = 'o')
        output_path = 'cpu_utilization_visualizations/' + output_file
        plt.savefig(output_path)

if __name__ == '__main__':
    visualize_benchmarks = VisualizeBenchmarks("cpu_results/")
    visualize_benchmarks.plot_cpu_utilization('10_0_0_16_results.jpeg', '10_0_0_16_results.csv')
    sample_files = ['10_0_0_16_results.csv', '10_0_1000000_16_results.csv', '10_0_10000000_16_results.csv']
    visualize_benchmarks.compare_visualizations('test.jpeg', sample_files)


