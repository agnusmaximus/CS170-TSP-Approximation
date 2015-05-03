function [nodes] = printpath(x_tsp, nStops)
    p=[];
    c=1;
    for i=1:nStops+1
        for j=i+1:nStops+1
            if x_tsp(c) ~= 0
                p=[p;[i,j]];
            end
            c=c+1;
        end
    end
    nodes=[p(1,:)];
    p(1,:)=[];
    termcond=nStops;
    while length(nodes) ~= nStops+1
        for i=1:length(p)
            if p(i,1)==nodes(1)
                nodes=[p(i,end),nodes];
                p(i,:)=[];
                break;
            end
            if p(i,1)==nodes(end)
                nodes=[nodes,p(i,end)];
                p(i,:)=[];
                break;
            end
            if p(i,end)==nodes(1)
                nodes=[p(i,1),nodes];
                p(i,:)=[];
                break;
            end
            if p(i,end)==nodes(end)
                nodes=[nodes,p(i,1)];
                p(i,:)=[];
                break;
            end
        end
    end
    dummyNodeIndex=find(nodes==nStops+1);
    nodes=[nodes(1,dummyNodeIndex+1:end),nodes(1,1:dummyNodeIndex-1)];
end