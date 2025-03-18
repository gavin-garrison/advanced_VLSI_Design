import os
import numpy as np

def generate_input_data():
    output_path = r"C:\Users\Gavin Garrison\fir_filter_baseline\input.data"
    clk_period_ns = 21276
    sample_rate = 1e9 / clk_period_ns
    num_samples_per_freq = 200
    freqs = np.logspace(np.log10(500), np.log10(20000), num=50)

    with open(output_path, "w") as f:
        for freq in freqs:
            for n in range(num_samples_per_freq):
                t = n / sample_rate
                val = int(10000 * np.sin(2 * np.pi * freq * t))
                val_bin = format(val & 0xFFFF, '016b')
                f.write(val_bin + '\n')

    print(f"Finished writing to {output_path}")

if __name__ == "__main__":
    generate_input_data()
