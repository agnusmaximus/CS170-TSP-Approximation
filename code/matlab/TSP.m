function [path,costopt,isopt,exitval] = TSP(filename,is_debug,limitsec)
    % Color definitions
    RED=0;
    BLUE=1;
    
    % Read file to get network properties
    fileid=fopen(filename,'r');
    n_cities=fscanf(fileid,'%d',1);
    adj_matrix=zeros(n_cities,n_cities);
    color=zeros(1,n_cities);
    for i=1:n_cities
        for j=1:n_cities
            distance=fscanf(fileid,'%d\n',1);
            adj_matrix(i,j)=distance;
            adj_matrix(j,i)=distance;
        end
    end
    for i=1:n_cities
        color_char=fscanf(fileid,'%c',1);
        if color_char=='R'
            color(i)=RED;
        else
            color(i)=BLUE;
        end
    end
    fclose(fileid);
     if is_debug
         disp('Adjacency Matrix:')
         disp(adj_matrix)
         disp('City Colors:')
         disp(color)
     end
    
    % Convert 2-D distances into 1-D values
    index=1;
    edges=nchoosek(1:n_cities+1,2);
    n_edges_total=(n_cities)*(n_cities+1)/2;
    dist=zeros(1,n_edges_total);
    for i=1:n_cities+1
        for j=i+1:n_cities+1
            if i==n_cities+1 || j==n_cities+1
                dist(index)=0;
            else
                dist(index)=adj_matrix(i,j);
            end
            index=index+1;
        end
    end   
    
    % Add constraints to TSP: 2 edges from each node
    Aeq=[spones(1:n_edges_total);spalloc(n_cities+1,n_edges_total,(n_cities)*(n_cities+1))];
    beq=[n_cities+1;2*ones(n_cities+1,1)];
    for ii=1:n_cities+1
        whichedges=(edges==ii);
        whichedges=sparse(sum(whichedges,2));
        Aeq(ii+1,:)=whichedges'; 
    end
    
    % Add constraints to TSP: integer solution, binary solution (take edge
    % or not)
    intcond=1:n_edges_total;
    lb=zeros(n_edges_total,1);
    ub=ones(n_edges_total,1);
    
    % Add color constraints
    A=[];
    b=[];
    if is_debug
        disp('Color Constraints...')
    end    
    for i=1:n_cities
       invalidpaths=getconstr(i,color,n_cities);
       A=[A;invalidpaths];
       b=[b;2*ones(size(invalidpaths,1),1)];
       if is_debug
           fprintf('Added constraints for node %d\n',i);
       end
    end
    if is_debug
        disp('Done With Color Constraints...')
    end
    
    % Set options, and solve initial relaxed problem
    opts=optimoptions('intlinprog','Display','iter','MaxTime',limitsec,'CutGenMaxIter',5,'TolGapAbs',30)
    [x_tsp,costopt,exitflag,output]=intlinprog(dist,intcond,A,b,Aeq,beq,lb,ub,opts);
    
    % Get subtours and invalid paths
    tours=detectSubtours(x_tsp,edges);
    numtours=length(tours);
    invalidpaths=[];
    isinvalid=0;
    if numtours==1
        invalidpaths=detectFourConsecutives(tours{1},color,n_cities);
        isinvalid=size(invalidpaths,1);
    end
        
    c=clock;
    
    % Inequality Constraints: Remove subtours and invalid consecutive paths
    while numtours>1 || isinvalid>0
        fprintf('Numtours: %d, NumInvalid:%d\n', numtours, isinvalid);
        % Break if time limit exceeded
        cprime=clock;
        if etime(cprime,c) > limitsec
            exitval=0;
            path=[];
            costopt=-1;
            isopt=0;
            return
        end

        % Get rid of subtours
        while numtours>1
            b=[b;zeros(numtours,1)]; 
            A=[A;spalloc(numtours,n_edges_total,n_cities+1)]; 
            for ii=1:numtours
                rowIdx=size(A,1)+1; 
                subTourIdx=tours{ii}; 
                variations=nchoosek(1:length(subTourIdx),2);
                for jj=1:length(variations)
                    whichVar=(sum(edges==subTourIdx(variations(jj,1)),2)) & ...
                             (sum(edges==subTourIdx(variations(jj,2)),2));
                    A(rowIdx,whichVar)=1;
                end
                b(rowIdx) = length(subTourIdx)-1; % One less trip than subtour stops
            end       
            % Try to optimize again & check subtours
            [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcond,A,b,Aeq,beq,lb,ub,opts);
            tours=detectSubtours(x_tsp,edges);
            numtours=length(tours);
        end
        
%         % Get invalid paths
%         invalidpaths=detectFourConsecutives(tours{1},color,n_cities);
%         isinvalid=size(invalidpaths,1);
%         
%         % Get rid of invalid consecutive paths
%         while isinvalid>0
%             % Add constraints
%             A=[A;invalidpaths];
%             b=[b;2*ones(size(invalidpaths,1),1)];
% 
%             % Try to optimize again
%             [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcond,A,b,Aeq,beq,lb,ub,opts);
%             
%             % Count subtours -- if it breaks into multiple, fix subtours
%             % again
%             tours=detectSubtours(x_tsp,edges);
%             numtours=length(tours);
%             if numtours>1
%                 break
%             end
%             
%             % Update invalid paths
%             invalidpaths = detectFourConsecutives(tours{1},color,n_cities);
%             isinvalid = size(invalidpaths,1);            
%         end
    end    
    
    path=printpath(tours{1},n_cities);
    isopt=output.absolutegap==0;
    exitval=1;
    if is_debug==1
        g=sprintf('%d ',path);
        disp(g);
        fprintf('Cost: %d\n',costopt);
        fprintf('Absolute Gap: %f\n',output.absolutegap);
        fprintf('Passes Check?: %d\n',checkpath(path,color));
    end  
end