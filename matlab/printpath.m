function [nodes] = printpath(x_tsp, nStops)
    p=[];
    c=1;
    for i=1:nStops+1
        for j=i+1:nStops+1
            if x_tsp(c) ~= 0 && i~=nStops+1 && j~=nStops+1
                p=[p;[i,j]];
            end
            c=c+1;
        end
    end
    nodes=[p(1,:)];
    p(1,:)=[];
    while length(nodes) ~= nStops
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
end