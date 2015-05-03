function [invalidPaths] = detectFourConsecutives(x_tsp,color,nStops)
    mapobj=zeros(nStops+1,nStops+1);
    c=1;
    for i=1:nStops+1
        for j=i+1:nStops+1
            mapobj(i,j)=c;
            mapobj(j,i)=c;
            c=c+1;
        end
    end
    invalidPaths = [];
    nodePath=printpath(x_tsp,nStops);
    for i=4:length(nodePath)
        n1=nodePath(i);
        n2=nodePath(i-1);
        n3=nodePath(i-2);
        n4=nodePath(i-3);
        c1=color(n1);
        c2=color(n2);
        c3=color(n3);
        c4=color(n4);
        if c1==c2 && c2==c3 && c3==c4
            disp([n1,n2,n3,n4])
            badedges=zeros(1,(nStops*(nStops+1))/2);
            badedges(mapobj(n1,n2))=1;
            badedges(mapobj(n2,n3))=1;
            badedges(mapobj(n3,n4))=1;
            invalidPaths=[invalidPaths;badedges];
        end
    end
end