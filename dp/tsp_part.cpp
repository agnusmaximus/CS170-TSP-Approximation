#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <sstream>
#include <vector>

using namespace std;

#define SSTR( x ) dynamic_cast< std::ostringstream & >( \
        ( std::ostringstream() << std::dec << x ) ).str()

#define DEBUG 0
#define CHECK 0
#define PRINT_PATH 0
#define PRINT_COST 1

#define MAX_CITIES 15
#define MAX_POWER (1<<MAX_CITIES)

typedef struct {
    int last_node, c1, c2, c3;
} recon;

typedef struct {
    int cost;
    vector<int> path;
} solution;

//Colors
#define RED 0
#define BLUE 1
#define NONE 2

//City info
int n_nodes;
int dist[MAX_CITIES][MAX_CITIES];
int colors[MAX_CITIES];

//DP C[S][i][color_before_i][color_before_before_i][colore_before_before_before_i]
int C[MAX_POWER][MAX_CITIES][3][3][3];
recon P[MAX_POWER][MAX_CITIES][3][3][3];

//Maximum path lenght
#define MAX_PATH_LENGTH 16843000

int city_bit_index(int k) {
    return 1 << k;
}

int in_set(int city, int set) {
    return (city_bit_index(city) & set) != 0;
}

int set_minus(int city, int set) {
    int i = city_bit_index(city);
    return set ^ i;
}

int sum_bits(int set) {
    int c = 0;
    while (set != 0) {
	c += (set & 1);
	set >>= 1;
    }
    return c;
}

void setup() {
    if (DEBUG) cout << "Memset C,P to 0 of size " << MAX_POWER*MAX_CITIES*27 << "..." << endl;
    memset(C, 0x1, sizeof(int)*MAX_POWER*MAX_CITIES*27);
    memset(P, 0x1, sizeof(recon)*MAX_POWER*MAX_CITIES*27);
    if (DEBUG) cout << "done." << endl;
}

void check_costs(solution &best_s) {
    int computed_cost = 0;
    for (int i = 1; i < best_s.path.size(); i++) {
	computed_cost += dist[best_s.path[i]][best_s.path[i-1]];
    }
    if (computed_cost != best_s.cost) {
	cout << "ERROR: Check Failed, costs do not match!\n" << endl;
	exit(0);
    }
}

void check_colors(solution &best_s) {
    int computed_cost = 0;
    for (int i = 1; i < best_s.path.size(); i++) {
	computed_cost += dist[best_s.path[i]][best_s.path[i-1]];
	}
    if (computed_cost != best_s.cost) {
	cout << "ERROR: Check Failed, costs do not match!\n" << endl;
	exit(0);
    }
}

solution path(int start) {
    //Initialize stuff
    setup();

    if (DEBUG) cout << "Initializing C..." << endl;

    if (n_nodes == 1) {
	cout << 0 << endl;
	return (solution){0, vector<int>()};
    }

    //Initialize sets with 2 nodes
    if (n_nodes >= 2) {
	for (int j = 0; j < n_nodes; j++) {
	    C[0|city_bit_index(start)|city_bit_index(j)][j][colors[start]][NONE][NONE] = dist[start][j];
	    P[0|city_bit_index(start)|city_bit_index(j)][j][colors[start]][NONE][NONE] = (recon){start, NONE, NONE, NONE};
	}
    }

    //Initialize sets with 3 nodes
    if (n_nodes >= 3) {
	for (int j = 0; j < n_nodes; j++) {
	    for (int k = 0; k < n_nodes; k++) {
		if (start != j && start != k && j != k) {
		    int best_dist = C[0|city_bit_index(start)|city_bit_index(j)][j][colors[start]][NONE][NONE] + dist[j][k];
		    C[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)][k][colors[j]][colors[start]][NONE] = best_dist;
		    P[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)][k][colors[j]][colors[start]][NONE] = (recon){j, colors[start], NONE, NONE};
		}
	    }
	}
    }

    //Initialize sets with 4 nodes
    if (n_nodes >= 4) {
	for (int j = 0; j < n_nodes; j++) {
	    for (int k = 0; k < n_nodes; k++) {
		for (int l = 0; l < n_nodes; l++) {
		    if (start != j && start != k && start != l &&
			j != k && j != l &&
			k != l) {
			if (colors[start] == colors[j] && colors[j] == colors[k] && colors[k] == colors[l]) {
			    C[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)|city_bit_index(l)][l][colors[k]][colors[j]][colors[start]] = MAX_PATH_LENGTH;
			}
			else {
			    int d1 = C[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)][k][colors[j]][colors[start]][NONE] + dist[k][l];
			    int d2 = C[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)][j][colors[k]][colors[start]][NONE] + dist[j][l];
			    C[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)|city_bit_index(l)][l][colors[k]][colors[j]][colors[start]] = min(d1, d2);
			    if (d1 < d2) P[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)|city_bit_index(l)][l][colors[k]][colors[j]][colors[start]] = (recon){k, colors[j], colors[start], NONE};
			    else P[0|city_bit_index(start)|city_bit_index(j)|city_bit_index(k)|city_bit_index(l)][l][colors[k]][colors[j]][colors[start]] = (recon){j, colors[k], colors[start], NONE};
			}
		    }
		}
	    }
	}
    }

    if (DEBUG) cout << "done." << endl;
    if (DEBUG) cout << "DP..." << endl;

    //DP loop
    for (int i = 4; i < n_nodes; i++) {
	for (int j = 0; j < MAX_POWER; j++) {
	    if (in_set(0, j) && sum_bits(j) > 4) {
		for (int l = 0; l < 2; l++) {
		    for (int m = 0; m < 2; m++) {
			for (int n = 0; n < 2; n++) {
			    for (int k = 0; k < n_nodes; k++) {
				if (in_set(k, j) && k != start) {
				    int bdst = MAX_PATH_LENGTH;
				    int last_node, c1, c2, c3;
				    if (!(l == m && m == n && n == colors[k])) {
					for (int o = 0; o < n_nodes; o++) {
					    if (in_set(o, j) && o != k && o != start && colors[o] == l) {
						bdst = min(bdst, C[set_minus(k, j)][o][m][n][RED] + dist[o][k]);
						bdst = min(bdst, C[set_minus(k, j)][o][m][n][BLUE] + dist[o][k]);
						if (bdst == C[set_minus(k, j)][o][m][n][RED] + dist[o][k]) {
						    last_node = o;
						    c1 = m;
						    c2 = n;
						    c3 = RED;
						}
						if (bdst == C[set_minus(k, j)][o][m][n][BLUE] + dist[o][k]) {
						    last_node = o;
						    c1 = m;
						    c2 = n;
						    c3 = BLUE;
						}
					    }
					}
				    }
				    C[j][k][l][m][n] = bdst;
				    P[j][k][l][m][n] = (recon){last_node, c1, c2, c3};
				}
			    }
			}
		    }
		}
	    }
	}
    }

    if (DEBUG) cout << "done." << endl;

    //Get best path length
    int best_dist = MAX_PATH_LENGTH;
    int end_city = -1, lc, llc, lllc;
    int all_cities = 0;
    for (int i = 0; i < n_nodes; i++) {
	all_cities |= city_bit_index(i);
    }
    for (int j = 0; j < n_nodes; j++) {
	if (j != start) {
	    for (int k = 0; k < 3; k++) {
		for (int l = 0; l < 3; l++) {
		    for (int m = 0; m < 3; m++){
			if (!(k == l && l == m && m == colors[j])) {
			    best_dist = min(best_dist, C[all_cities][j][k][l][m]);
			    if (best_dist == C[all_cities][j][k][l][m]) {
				end_city = j;
				lc = k;
			    llc = l;
			    lllc = m;
			    }
			}
		    }
		}
	    }
	}
    }

    if (best_dist >= MAX_PATH_LENGTH) return (solution){best_dist, vector<int>()};

    if (DEBUG) cout << "Reconstructing solution..." << endl;

    //reconstruct the path
    vector<int> path;
    while (end_city != start) {
	path.insert(path.begin(), end_city);
	recon r = P[all_cities][end_city][lc][llc][lllc];
	all_cities = set_minus(end_city, all_cities);
	end_city = r.last_node;
	lc = r.c1;
	llc = r.c2;
	lllc = r.c3;
    }
    path.insert(path.begin(), end_city);
    if (DEBUG) cout << "done." << endl;
    return (solution){best_dist, path};
}

int solve() {

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

    //Solve
    int best_cost = MAX_PATH_LENGTH;
    solution best_s;
    for (int i = 0; i < n_nodes; i++) {
	solution s = path(i);
	if (s.cost <= best_cost) {
	    best_cost = s.cost;
	    best_s = s;
	}
	if (DEBUG) cout << s.cost << endl;
    }

    //Print solution
    if (PRINT_COST)
	cout << best_s.cost << endl;
    for (int i = 0; i < best_s.path.size(); i++) {
	if (PRINT_PATH)
	    cout << best_s.path[i] << " ";
    }
    if (PRINT_PATH)
	cout << endl;

    //Check solution
    if (CHECK) {
	if (DEBUG) cout << "Checking solution..." << endl;

	if (best_s.cost < MAX_PATH_LENGTH) {
	    //Check costs
	    check_costs(best_s);

	    //Check different colors
	    check_colors(best_s);
	}

	if (DEBUG) cout << "Checks Passed." << endl;
    }
    return best_s.cost;
}

int main(void) {
    solve();
}
