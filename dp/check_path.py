import sys

n_nodes = int(sys.stdin.readline())
dist, colors = [], []
for i in range(n_nodes):
    dist.append([int(x) for x in sys.stdin.readline().split()])
colors = list(sys.stdin.readline().strip())
path = [int(x) for x in sys.stdin.readline().split()]
c = 0
for i in range(1, len(path)):
    c += dist[path[i]-1][path[i-1]-1]
for i in range(3, len(path)):
    if colors[path[i]-1] == colors[path[i-1]-1] and \
       colors[path[i-1]-1] == colors[path[i-2]-1] and \
       colors[path[i-2]-1] == colors[path[i-3]-1]:
        print("BAD")
        sys.exit(0)
print("ok")
print(c)
