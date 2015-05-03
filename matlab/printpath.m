function [nodes] = printpath(tour, nStops)
    dummyNodeIndex=find(tour==nStops+1);
    nodes=[tour(1,dummyNodeIndex+1:end),tour(1,1:dummyNodeIndex-1)];
end