import path
import itertools
import random
import math

DEBUG = 0

def approximate_tsp(n, m, c):
	max_edge = 0
	for i in m:
		row_max = max(i)
		if row_max > max_edge:
			max_edge = row_max


	metric_m = []
	for row in m:
		new_row = [max_edge + i for i in row]
		metric_m.append(new_row)

	p, cost = path.find_path(0, m, c)
	p = check_start_paths(n, m, c)
	# k = int(math.ceil(len(m)/8))
	# if k < 2:
		# k = 2
	p = k_search(3, n, m, c, p, 1000)
	# p, cost = path.find_path(0, metric_m, c)
	# p = check_start_paths(n, metric_m, c)
	# p = k_search(6, n, metric_m, c, p, 100)

	cost, x = check_cost(p, m, c)
        if DEBUG:
                print p, cost
	return p, cost

def check_start_paths(n, m, c):
	best_p, best_cost = path.find_path(0, m, c)
	for i in range(1,len(m)):
		p, cost = path.find_path(i, m, c)
		if cost < best_cost:
			best_cost = cost
			best_p = p
			# p = k_search(2, n, m, c, best_p, 100000)
        if DEBUG:
                print best_p, best_cost
	return best_p


def k_search(k, n, m, colors, path, num_times):
	total = num_times # for printing out, not necessary
	best_cost, x = check_cost(path, m, colors)
        if DEBUG:
                print "cost", best_cost
	best_path = path[:] #list(range(1, len(colors)+1))

	possible_values = []
	for i in range(k):
		lst = [j for j in range(n-i+1)]
		possible_values.append(lst)
	all_placements = list(itertools.product(*possible_values))

	while num_times > 0:
		nums = [random.randint(1, len(m))]
		while len(nums) < k:
			i = random.randint(1, len(m))
			if i not in nums:
				nums.append(i)

		p = [i for i in best_path if i not in nums]
		for placement in all_placements:
			new_p = p[:]
			for i in range(len(nums)):
				new_p.insert(placement[i], nums[i])
			cost, valid = check_cost(new_p, m, colors)
			if cost < best_cost and valid:
				if DEBUG:
						print "new path", new_p, cost, "iteration", total - num_times, " best ", best_path
				best_cost = cost
				best_path = new_p[:]
		num_times -= 1
	return best_path



# def k_random(k, num_times, m, c):
	# best_cost, x = check_cost(path, m, colors)
        # if DEBUG:
                # print "cost", best_cost
	# best_path = list(range(1, len(colors)+1))


	# while num_times > 0:

		# p = [i for i in best_path if i not in nums]
		# for placement in all_placements:
			# new_p = p[:]
			# for i in range(len(nums)):
				# new_p.insert(placement[i], nums[i])
			# cost, valid = check_cost(new_p, m, colors)
			# if cost < best_cost and valid:
				# if DEBUG:
						# print "new path", new_p, cost, "iteration", total - num_times, " best ", best_path
				# best_cost = cost
				# best_path = new_p[:]
		# num_times -= 1
	# return best_path

def check_cost(perm, d, c):
	N = len(d)
	v = [0 for i in range(N)]
	prev = 'X'
	count = 0
	for i in range(len(perm)):
		if v[perm[i]-1] == 1:
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

	cost = 0
	for i in range(len(perm)-1):
		cur = perm[i]-1
		next = perm[i+1]-1

		cost += d[cur][next]
	return cost, True
