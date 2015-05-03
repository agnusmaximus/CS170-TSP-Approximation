def find_path(i, m, colors):
	n = len(m)
	visited = set()
	path_cost = 0
	path_order = []
	same_color = 1
	red = n/2
	blue = n/2
	visited.add(i)
	path_order.append(i+1)
	if colors[i] == 'R':
		red -= 1
	else:
		blue -= 1
	while len(visited) < len(m):
		min_cost = 101
		next = -1
		for j in range(0, len(m)):
			if m[i][j] < min_cost and j != i and not j in visited:
				if colors[i] == colors[j] and same_color >= 3:
					continue
				if colors[j] == 'R' and (red-1)*3 < blue and red > 1:
					continue
				if colors[j] == 'B' and (blue-1)*3 < red and blue > 1:
					continue
				next = j
				min_cost = m[i][j]
		path_order.append(next+1)
		path_cost += m[i][next]
		visited.add(next)

		if colors[next] == 'R':
			red -= 1
		else:
			blue -= 1

		if colors[i] == colors[next]:
			same_color += 1
		else:
			same_color = 1
		min_cost = 101
		i = next
	
	cost, valid = check_cost(path_order, m, colors)
	print path_order
	if valid:
		print "done"
	else:
		print "not done"
	return path_order, path_cost

def check_cost(perm, d, c):
	N = len(d)
	v = [0 for i in range(N)]
	prev = 'X'
	count = 0
	for i in range(len(perm)):
		if v[perm[i]-1] == 1:
			print "ERROR: not a permutation"
			return 0, False
		v[perm[i]-1] = 1
		cur = c[perm[i]-1]
		if cur == prev:
			count += 1
		else:
		    prev = cur
		    count = 1
		if count > 3:
			return 0, False
			print "ERROR: color violation at index ", perm[i]-1

	cost = 0
	for i in range(len(perm)-1):
		cur = perm[i]-1
		next = perm[i+1]-1

		cost += d[cur][next]
	return cost, True