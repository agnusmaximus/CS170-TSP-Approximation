function [Aconstr]=getconstr(curnode,color,n_cities)
    global Aconstr
    mapobj=zeros(n_cities+1,n_cities+1);
    c=1;
    for i=1:n_cities
        for j=i+1:n_cities+1
            mapobj(i,j)=c;
            mapobj(j,i)=c;
            c=c+1;
        end
    end
    Aconstr=[];
    visited=[curnode];
    dfs(curnode,visited,color,n_cities,mapobj);
end
function [V]=toedgearray(visited,n_cities,mapobj)
    V=zeros(1,(n_cities)*(n_cities+1)/2);
    V(mapobj(visited(1),visited(2)))=1;
    V(mapobj(visited(2),visited(3)))=1;
    V(mapobj(visited(3),visited(4)))=1;   
end
function dfs(curnode,visited,color,n_cities,mapobj)
    global Aconstr
    if length(visited)==4
        A=toedgearray(visited,n_cities,mapobj);
        Aconstr=[Aconstr;A];
        return
    end    
    for i=1:n_cities
        if ~any(visited==i) && color(i)==color(curnode)
            dfs(i,[visited,i],color,n_cities,mapobj);
        end
    end
end
