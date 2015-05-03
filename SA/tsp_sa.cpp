#include <iostream>
#include <math.h>
#include <set>
#include <vector>
#include <time.h>
#include <cstdlib>
#include <algorithm>

using namespace std;

#define MAX_CITIES 50
#define RED 0
#define BLUE 1

#define MATH_E 2.71828

#define T_END .1
#define C .99999

#define GAP 100000
#define DEBUG 1
#define N_ITER 5000
#define NN_ITER 10

int n_nodes;
int dist[MAX_CITIES][MAX_CITIES];
int colors[MAX_CITIES];

typedef struct path {
    int cities[MAX_CITIES];
    int cost;
} Path;

double rand01() {
    return ((double) rand() / (RAND_MAX));
}

void read_input() {
    //Read input
    cin >> n_nodes;
    for (int i = 0; i < n_nodes; i++)
	for (int j = 0; j < n_nodes; j++) {
	    cin >> dist[i][j];
	}
    for (int i = 0; i < n_nodes; i++) {
	char color;
	cin >> color;
	colors[i] = (color == 'R') ? RED : BLUE;
    }
}

int is_valid(int n1, int n2, int n3, int n4) {
    return !(colors[n1] == colors[n2] &&
	     colors[n2] == colors[n3] &&
	     colors[n3] == colors[n4]);
}

void add_random_valid_city(Path &p, set<int> &candidates, int n_nodes_added) {
    set<int>::iterator cand_itr;
    int rand_index, i, random_value;
    while (true) {
	rand_index = rand() % candidates.size();
	for (cand_itr = candidates.begin(), i = 0; i < rand_index; i++, cand_itr++);
	random_value = *cand_itr;
	cout << n_nodes_added << " " << candidates.size() << " " << rand_index << endl;
	if (n_nodes_added < 3 || is_valid(random_value, p.cities[n_nodes_added-1],
					  p.cities[n_nodes_added-2], p.cities[n_nodes_added-3])) {
	    p.cities[n_nodes_added] = random_value;
	    candidates.erase(cand_itr);
	    break;
	}
    }
}

void print_path(Path &p) {
    cout << "Cost: " << p.cost << endl;
    for (int i = 0; i < n_nodes; i++) {
	cout << p.cities[i] << " ";
    }
    cout << endl;
}

int score_path(Path &p) {
    int c = 0;
    for (int i = 1; i < n_nodes; i++)
	c += dist[p.cities[i]][p.cities[i-1]];
    return c;
}

void create_initial_path(Path &p) {
    set<int> candidates;
    for (int i = 0; i < n_nodes; i++)
	candidates.insert(i);
    int n_nodes_added = 0;
    for (int n_nodes_added = 0; n_nodes_added < n_nodes; n_nodes_added++)
	add_random_valid_city(p, candidates, n_nodes_added);
    p.cost = score_path(p);
}

void swap_cities(Path &p, int i1, int i2) {
    int t = p.cities[i1];
    p.cities[i1] = p.cities[i2];
    p.cities[i2] = t;
}

int is_valid_path(Path &p) {
    for (int i = 3; i < n_nodes; i++)
	if (!is_valid(p.cities[i],
		      p.cities[i-1],
		      p.cities[i-2],
		      p.cities[i-3])) return 0;
    return 1;
}

int can_swap_cities(Path &p, int i1, int i2) {
    swap_cities(p, i1, i2);
    int is_valid = is_valid_path(p);
    swap_cities(p, i1, i2);
    return is_valid;
}

void perturb_path(Path &p) {
    int r1 = 0, r2 = 0;
    while (r1 == r2 || !can_swap_cities(p, r1, r2)) {
	r1 = rand() % n_nodes;
	r2 = rand() % n_nodes;
    }
    swap_cities(p, r1, r2);
    p.cost = score_path(p);
}

void copy_path(Path &src, Path &dst) {
    dst.cost = src.cost;
    memcpy(dst.cities, src.cities, sizeof(int)*n_nodes);
}

int sum_top_nodes() {
    vector<int> vals;
    for (int i = 0; i < n_nodes; i++)
	for (int j = 0; j < n_nodes; j++)
	    vals.push_back(dist[i][j]);
    sort(vals.begin(), vals.end());
    int s = 0;
    for (int i = vals.size()-1; i >= vals.size()-1-n_nodes; i--)
	s += vals[i];
    return s;
}

void create_greedy_path(Path &p, int curr) {
	int visited[n_nodes];
	for (int i = 0; i < n_nodes; i++)
		visited[i] = 0;
	int same_color = 1;
	int red = n_nodes/2;
	int blue = n_nodes/2;
	if (colors[curr] == RED)
		red--;
	else
		blue--;
	visited[curr] = 1;
	p.cities[0] = curr;
	p.cost = 0;
	int index = 1;

	while(index < n_nodes) {
		int min_cost = 101;
		int next = -1;
		for (int j = 0; j < n_nodes; j++) {
			if(dist[curr][j] < min_cost && curr != j && visited[j] == 0) {
				if (colors[curr] == colors[j] && same_color >= 3)
					continue;
				if (colors[j] == RED && (red-1)*3 < blue && red > 1)
					continue;
				if (colors[j] == BLUE && (blue-1)*3 < red && blue > 1)
					continue;
				next = j;
				min_cost = dist[curr][j];
				// if (!(colors[curr] == colors[j] && same_color >= 3) && !(colors[j] == RED && red == n_nodes/2-1 && blue <= n_nodes/2-4) && !(colors[j] == BLUE && blue == n_nodes/2-1 && red <= n_nodes/2-4)) {
					// next = j;
					// min_cost = dist[curr][j];
				// }
			}
		}
		p.cities[index] = next;
		index++;
		p.cost += dist[curr][next];
		visited[next] = 1;

		if (colors[next] == RED)
			red--;
		else
			blue--;

		if (colors[curr] == colors[next])
			same_color++;
		else
			same_color = 1;
		min_cost = 101;
		curr = next;
	}
	// for (int i = 0; i < n_nodes; i++)
		// cout << "i: " << i << " val: " << visited[i];
	print_path(p);
	if (is_valid_path(p))
		cout << "done" << endl;
	else
		cout << "not done" << endl;
}

void diff_start_paths(Path &p) {
	Path temp_p;
	copy_path(p, temp_p);
	for (int i = 0; i < n_nodes; i++) {
		create_greedy_path(temp_p, i);
		if (temp_p.cost < p.cost)
			copy_path(temp_p, p);
	}
	temp_p.cost=score_path(p);
}


int main(void) {
    srand(time(NULL));
    read_input();
    Path cur_path, new_path, best_path;
    int iteration = 0, strt = sum_top_nodes() * 2;
   // create_initial_path(cur_path);
	 // create_greedy_path(cur_path, 6);

	diff_start_paths(cur_path);
    copy_path(cur_path, new_path);
    copy_path(cur_path, best_path);
    for (int k = 0; k < NN_ITER; k++) {
	for (int i = 0; i < N_ITER; i++) {
	    long double temp = strt / (i+1);
	    while (temp > T_END) {
		if (iteration % GAP == 0 && DEBUG) print_path(cur_path);
		perturb_path(new_path);
		if (new_path.cost < cur_path.cost ||
		    pow(MATH_E, -(new_path.cost-cur_path.cost)/(double)temp) > rand01()) {
		    copy_path(new_path, cur_path);
		}
		else {
		    copy_path(cur_path, new_path);
		}
		if (cur_path.cost < best_path.cost) {
		    copy_path(cur_path, best_path);
		}
		temp *= C;
	    iteration++;
	    }
	    if (rand() % (k+1) < N_ITER/2) {
		copy_path(best_path, cur_path);
		copy_path(best_path, new_path);
	    }
	}
    }
    print_path(best_path);
}
