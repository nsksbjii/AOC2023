def extrapolate_history(sequence):
    # Initialize a list to store sequences of differences
    differences = [sequence]

    # Generate sequences of differences until an all-zero sequence is obtained
    while any(differences[-1]):
        new_sequence = [
            differences[-1][i + 1] - differences[-1][i]
            for i in range(len(differences[-1]) - 1)
        ]
        differences.append(new_sequence)

    # Add a placeholder zero at the end of the last sequence
    differences[-1].append(0)

    # Fill in placeholders from the bottom up
    for i in range(len(differences) - 2, -1, -1):
        for j in range(len(differences[i]) - 1):
            differences[i][j] = differences[i][j + 1] + differences[i + 1][j]

    # The first value in the history is the result of the topmost sequence
    next_value = differences[0][0]

    return next_value


# Example usage:
history_1 = [0, 3, 6, 9, 12, 15]
history_2 = [1, 3, 6, 10, 15, 21]
history_3 = [10, 13, 16, 21, 30, 45, 68]

next_value_1 = extrapolate_history(history_1)
next_value_2 = extrapolate_history(history_2)
next_value_3 = extrapolate_history(history_3)

print(f"The next value of the first history is: {next_value_1}")
print(f"The next value of the second history is: {next_value_2}")
print(f"The next value of the third history is: {next_value_3}")
