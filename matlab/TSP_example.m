profile on

RED=0;
BLUE=1;
NOCOLOR=2;

figure;

load('usborder.mat','x','y','xx','yy');
%rng(39,'twister') % makes a plot with stops in Maine & Florida, and is reproducible
rng('shuffle', 'twister')
nStops = 50; % you can use any number, but the problem size scales as N^2
stopsLon = zeros(nStops,1); % allocate x-coordinates of nStops
stopsLat = stopsLon; % allocate y-coordinates
% color = [];
color = [ones(1, nStops/2), zeros(1, nStops/2)];
color = color(randperm(length(color)));
n = 1;
while (n <= nStops+1)
    xp = rand*1.5;
    yp = rand;
    if inpolygon(xp,yp,xx,yy) % test if inside the border
        stopsLon(n) = xp;
        stopsLat(n) = yp;
        n = n+1;
    end
end

color(nStops+1)=NOCOLOR;
redxs=[];
redys=[];
bluexs=[];
blueys=[];
for i=1:nStops
    if color(i)==RED
        redxs=[redxs,stopsLon(i)];
        redys=[redys,stopsLat(i)];
    else
        bluexs=[bluexs,stopsLon(i)];
        blueys=[blueys,stopsLat(i)];
    end
end

labels = cellstr(num2str([1:nStops+1]'));
plot(x,y,'Color','red'); % draw the outside border
hold on
% Add the stops to the map
% plot(stopsLon(1:nStops),stopsLat(1:nStops),'*b')
plot(bluexs,blueys,'*b')
plot(redxs,redys,'*r')
plot(stopsLon(nStops+1),stopsLat(nStops+1),'*g')
text(stopsLon, stopsLat, labels, 'VerticalAlignment','bottom', ...
                                 'HorizontalAlignment','right')
hold off

idxs = nchoosek(1:nStops+1,2);
dist = round(100*hypot(stopsLat(idxs(:,1)) - stopsLat(idxs(:,2)), ...
             stopsLon(idxs(:,1)) - stopsLon(idxs(:,2))));
count=1;
for i=1:nStops+1
    for j=i+1:nStops+1
        if i == nStops+1 || j == nStops+1
            dist(count)=0;
        end
        count=count+1;
    end
end

lendist = length(dist);

Aeq = spones(1:length(idxs)); % Adds up the number of trips
beq = nStops+1;

Aeq = [Aeq;spalloc(nStops+1,length(idxs),nStops*(nStops+1))]; % allocate a sparse matrix
beq = [beq; 2*ones(nStops+1,1)];
for ii = 1:nStops+1
    whichIdxs = (idxs == ii); % find the trips that include stop ii
    whichIdxs = sparse(sum(whichIdxs,2)); % include trips where ii is at either end
    Aeq(ii+1,:) = whichIdxs'; % include in the constraint matrix
end

intcon = 1:lendist;
lb = zeros(lendist,1);
ub = ones(lendist,1);

opts = optimoptions('intlinprog','Display','off','CutGenMaxIter',5);
[x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);

% Remove dummy node
c=1;
xx_tsp = x_tsp;
for i=1:nStops+1
    for j=i+1:nStops+1
        if i==nStops+1 || j==nStops+1
            xx_tsp(c)=0;
        end
        c = c+1;
    end
end

hold on
segments = find(xx_tsp); % Get indices of lines on optimal path
lh = zeros(nStops+1,1); % Use to store handles to lines on plot
lh = updateSalesmanPlot(lh,xx_tsp,idxs,stopsLon,stopsLat);
title('Solution with Subtours');

% Get subtours
tours = detectSubtours(x_tsp,idxs);
numtours = length(tours); % number of subtours
fprintf('# of subtours: %d\n',numtours);

% Get invalid paths
invalidPaths = [];
isinvalid = 0;
if numtours == 1
    invalidPaths = detectFourConsecutives(x_tsp,color,nStops);
    isinvalid = length(invalidPaths);
end

A = spalloc(0,lendist,0); % Allocate a sparse linear inequality constraint matrix
b = [];
while numtours > 1 || isinvalid > 0 % repeat until there is just one subtour
    while numtours > 1
        % Add the subtour constraints
        b = [b;zeros(numtours,1)]; % allocate b
        A = [A;spalloc(numtours,lendist,nStops+1)]; % a guess at how many nonzeros to allocate
        for ii = 1:numtours
            rowIdx = size(A,1)+1; % Counter for indexing
            subTourIdx = tours{ii}; % Extract the current subtour
    %         The next lines find all of the variables associated with the
    %         particular subtour, then add an inequality constraint to prohibit
    %         that subtour and all subtours that use those stops.
            variations = nchoosek(1:length(subTourIdx),2);
            for jj = 1:length(variations)
                whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                           (sum(idxs==subTourIdx(variations(jj,2)),2));
                A(rowIdx,whichVar) = 1;
            end
            b(rowIdx) = length(subTourIdx)-1; % One less trip than subtour stops
        end

        % Try to optimize again
        [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);

        % Visualize result / (also remove dummy node edges)
         c=1;
         xx_tsp = x_tsp;
         for i=1:nStops+1
             for j=i+1:nStops+1
                 if i==nStops+1 || j==nStops+1
                     xx_tsp(c)=0;
                 end
                 c = c+1;
             end
         end
        lh = updateSalesmanPlot(lh,xx_tsp,idxs,stopsLon,stopsLat);

        % How many subtours this time?
        tours = detectSubtours(x_tsp,idxs);
        numtours = length(tours); % number of subtours
        fprintf('# of subtours: %d\n',numtours);
    end

    % Get invalid paths
    invalidPaths = detectFourConsecutives(x_tsp,color,nStops);
    isinvalid = size(invalidPaths,1);

    % How many partial paths?
    while isinvalid > 0 && numtours == 1
        % Add constraints
        A = [A;invalidPaths];
        b = [b;2*ones(size(invalidPaths,1),1)];

        % Try to optimize again
        [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);

        % Visualize result / (also remove dummy node edges)
         c=1;
         xx_tsp = x_tsp;
         for i=1:nStops+1
             for j=i+1:nStops+1
                 if i==nStops+1 || j==nStops+1
                     xx_tsp(c)=0;
                 end
                 c = c+1;
             end
         end
        lh = updateSalesmanPlot(lh,xx_tsp,idxs,stopsLon,stopsLat);

        % How many subtours this time?
        tours = detectSubtours(x_tsp,idxs);
        numtours = length(tours); % number of subtours

        if numtours ~= 1
            break
        end

        % Get invalid paths again
        invalidPaths = detectFourConsecutives(x_tsp,color,nStops);
        isinvalid = size(invalidPaths,1);
    end
end

disp('Cost')
disp(costopt)

% Print path
nodes=printpath(x_tsp, nStops);
fprintf('Path:\n')
disp(nodes)
fprintf('Absolute Gap(0 means optimal): %d\n', output.absolutegap)
fprintf('Does Pass Checks? 0 for no, 1 for yes: %d\n', checkpath(nodes,color))

title('Solution with Subtours Eliminated');
hold off

profile viewer