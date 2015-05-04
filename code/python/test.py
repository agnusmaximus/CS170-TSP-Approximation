import sys
import tsp_approximate

T = 1 # number of test cases

for t in xrange(1, T+1):
    N = int(sys.stdin.readline())
    d = [[] for i in range(N)]
    for i in xrange(N):
        d[i] = [int(x) for x in sys.stdin.readline().split()]
    c = sys.stdin.readline().strip()

    # find an answer, and put into assign
    assign, cost = tsp_approximate.approximate_tsp(N, d, c)

    #sys.stdout.write("%s\n" % " ".join(map(str, assign)))
    print(cost)
