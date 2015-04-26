def find_path(i, m, colors):
	n = len(m)
	visited = set()
	path_cost = 0
	path_order = []
	same_color = 1
	red = 0
	blue = 0
	visited.add(i)
	path_order.append(i+1)
	if colors[i] == 'R':
		red += 1
	else:
		blue += 1
	while len(visited) < len(m):
		min_cost = float('inf')
		next = -1
		for j in range(0, len(m)):
			if m[i][j] < min_cost and j != i and not j in visited:
				if colors[i] == colors[j] and same_color >= 3:
					continue
				if colors[j] == 'R' and red == n/2 - 1 and blue <= n/2 - 4:
					continue
				if colors[j] == 'B' and blue == n/2 - 1 and red <= n/2 - 4:
					continue
				next = j
				min_cost = m[i][j]
		path_order.append(next+1)
		path_cost += m[i][next]
		visited.add(next)

		if colors[next] == 'R':
			red += 1
		else:
			blue += 1

		if colors[i] == colors[next]:
			same_color += 1
		else:
			same_color = 1
		min_cost = float('inf')
		i = next
	return path_order, path_cost
