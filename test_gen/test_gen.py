from __future__ import print_function
import sys
import random

SMALLEST = 4
LARGEST = 15
N = 10
MAX_VALUE = 100
MIN_VALUE = 0

output_dir = sys.stdin.readline().strip()

def generate_case(n_cities, index, output_dir_str):
    print("Case %d" % (index))

    # File to write to
    if output_dir_str[-1] != "/":
        output_dir_str += "/"
    fname = output_dir_str + str(index)
    f = open(fname, "w")

    # Create adj_mat
    adj_mat = [[0 for i in range(n_cities)] for j in range(n_cities)]
    for i in range(n_cities):
        for j in range(i+1, n_cities):
            v = random.randint(MIN_VALUE, MAX_VALUE)
            adj_mat[i][j] = v
            adj_mat[j][i] = v

    # Create color string
    colors = ""
    for i in range(n_cities):
        c = 'R'
        if random.randint(0, 1) == 0:
            c = 'B'
        colors += c

    # Write adj matrix to file
    for row in adj_mat:
        for val in row:
            f.write(str(val) + " ")
        f.write("\n")
    print(colors, file=f)

for i in range(N):
    n_cities = random.randint(SMALLEST, LARGEST)
    generate_case(n_cities, i, output_dir)