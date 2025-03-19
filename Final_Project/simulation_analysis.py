#!/usr/bin/env python3
import matplotlib.pyplot as plt

def main():
    # You can set the absolute path here
    filename = r"C:\Users\Gavin Garrison\final_project\final_project.sim\sim_1\behav\xsim\simulation_output.txt"

    # Lists to store data
    times = []
    phase_errors = []
    gain_adjustments = []
    predicted_errors = []
    control_words = []

    # Read the file
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue  # skip empty lines
            # Expecting: time, phase_error, gain_adjustment, predicted_error, control_word
            parts = line.split(",")
            if len(parts) != 5:
                continue  # skip malformed lines
            try:
                t = int(parts[0])
                pe = int(parts[1])
                ga = int(parts[2])
                pre = int(parts[3])
                cw = int(parts[4], 0)  # auto-detect hex or decimal
            except ValueError:
                continue

            times.append(t)
            phase_errors.append(pe)
            gain_adjustments.append(ga)
            predicted_errors.append(pre)
            control_words.append(cw)

    if not times:
        print("No valid data found in file:", filename)
        return

    # Compute basic statistics
    avg_phase_error = sum(abs(pe) for pe in phase_errors) / len(phase_errors)
    avg_gain = sum(abs(ga) for ga in gain_adjustments) / len(gain_adjustments)
    avg_control_word = sum(control_words) / len(control_words)

    print("=== Basic Statistics ===")
    print(f"Number of samples: {len(times)}")
    print(f"Average |phase_error|: {avg_phase_error:.2f}")
    print(f"Average |gain_adjustment|: {avg_gain:.2f}")
    print(f"Average control_word: {avg_control_word:.2f}")

    # 1. Downsample
    downsample = 100
    times_ds = times[::downsample]
    phase_errors_ds = phase_errors[::downsample]
    gain_adjustments_ds = gain_adjustments[::downsample]
    predicted_errors_ds = predicted_errors[::downsample]
    control_words_ds = control_words[::downsample]

    # 2. Plot
    plt.figure(figsize=(10, 6))

    plt.subplot(2,2,1)
    plt.plot(times_ds, phase_errors_ds)
    plt.title("Phase Error")
    plt.xlabel("Time (ns)")
    plt.ylabel("phase_error")
    # Zoom in on the first 1e7 ns for clarity (adjust as needed)
    plt.xlim(0, 1e7)

    plt.subplot(2,2,2)
    plt.plot(times_ds, gain_adjustments_ds, color="orange")
    plt.title("Gain Adjustment")
    plt.xlabel("Time (ns)")
    plt.ylabel("gain_adjustment")
    plt.xlim(0, 1e7)

    plt.subplot(2,2,3)
    plt.plot(times_ds, predicted_errors_ds, color="green")
    plt.title("Predicted Error")
    plt.xlabel("Time (ns)")
    plt.ylabel("predicted_error")
    plt.xlim(0, 1e7)

    plt.subplot(2,2,4)
    plt.plot(times_ds, control_words_ds, color="red")
    plt.title("Control Word")
    plt.xlabel("Time (ns)")
    plt.ylabel("control_word")
    plt.xlim(0, 1e7)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()
