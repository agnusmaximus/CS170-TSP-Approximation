#include <iostream>
#include <math.h>
#include <set>
#include <vector>
#include <time.h>
#include <queue>

using namespace std;

#define RED 0
#define BLUE 1
#define NO_COLOR 2
#define MAX_CITIES 51
#define MAX_VALUE 1000000

typedef struct state {
    int nodes, curnode, lc, llc, score;
    vector<int> path;
} State;

int n_nodes;
int dist[MAX_CITIES][MAX_CITIES];
int colors[MAX_CITIES];

int n_pruned = 0;

void read_input() {
    cin >> n_nodes;
    for (int i = 0; i < n_nodes; i++)
	for (int j = 0; j < n_nodes; j++)
	    cin >> dist[i][j];
    for (int i = 0; i < n_nodes; i++) {
	char color;
	cin >> color;
	colors[i] = (color == 'R') ? RED : BLUE;
    }
}

void print_path(vector<int> &path) {
    for (int i = 0; i < path.size(); i++)
	cout << path[i] << " ";
    cout << endl;
}

int add_node(int nodeset, int node) {
    return nodeset ^ (1 << (node));
}

int in_set(int nodeset, int node) {
    return (nodeset & (1 << node)) != 0;
}

int is_valid_move(int n1, int n2, int lc, int llc) {
    return (n1 != n2) && !(colors[n1] == colors[n2] && colors[n2] == lc && lc == llc);
}

int lower_bound_value(int nodeset) {
    int c = 0, largest_edge = -MAX_VALUE;
    for (int i = 0; i < n_nodes; i++) {
	if (in_set(nodeset, i)) {
	    vector<int> ds;
	    for (int j = 0; j < n_nodes; j++)
		if (in_set(nodeset, j))
		    ds.push_back(dist[i][j]);
	    sort(ds.begin(), ds.end(), less<int>());
	    if (ds.size() >= 1) {
		largest_edge = max(largest_edge, ds[0]);
		c += ds[0];
	    }
	    if (ds.size() >= 2) {
		largest_edge = max(largest_edge, ds[1]);
		c += ds[1];
	    }
	}
    }
    if (largest_edge == -MAX_VALUE) largest_edge = 0;
    return c - largest_edge;
}

int upper_bound_value(int nodeset) {

}

int BB(queue<State> &q) {
    int best = MAX_VALUE;
    vector<int> best_path;
    while (!q.empty()) {

	//Get the state from the queue
	State top = q.front();
	q.pop();

	//Extract variables
	int cur_node = top.curnode, nodeset = top.nodes, score = top.score;
	int lc = top.lc, llc = top.llc, n_valid_nodes = 0;
	vector<int> path = top.path;

	//Compute upper and lower bounds
	int lower_bound = lower_bound_value(nodeset);
	int upper_bound = upper_bound_value(nodeset);

	if (lower_bound >= best) {
	    n_pruned++;
	    continue;
	}

	int max_bound_children = MAX_VALUE;
	for (int i = 0; i < n_nodes; i++) {
	    if (in_set(nodeset, i)) {
		int set = add_node(nodeset, i);
		max_bound_children = min(max_bound_children, upper_bound_value(set));
	    }
	}

	for (int i = 0; i < n_nodes; i++) {
	    if (in_set(nodeset, i)) {
		if (lower_bound_value(add_node(nodeset, i)) >= max_bound_children) {
		    n_pruned++;
		    continue;
		}
		n_valid_nodes++;
		if (is_valid_move(cur_node, i, lc, llc)) {
		    vector<int> cp = path;
		    cp.push_back(i);
		    q.push((State){add_node(nodeset, i), i, colors[cur_node], lc, score+dist[i][cur_node], cp});
		}
	    }
	}
	if (n_valid_nodes == 0) {
	    best = min(best, score);
	    if (best == score) {
		best_path = path;
	    }
	}
    }
    print_path(best_path);
    return best;
}

int solve() {
    queue<State> q;
    for (int i = 0; i < n_nodes; i++) {
	int nodeset = 0;
	for (int j = 0; j < n_nodes; j++)
	    if (j != i)
		nodeset = add_node(nodeset, j);
	vector<int> path;
	path.push_back(i);
	q.push((State){nodeset, i, NO_COLOR, NO_COLOR, 0, path});
    }

    return BB(q);
}

int main(void) {
    read_input();
    cout << solve() << endl;
    cout << "Pruned " << n_pruned << " nodes " << endl;
}
