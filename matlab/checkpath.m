function [is_ok] = check_path(p, colors)
    % Check colors 
    is_valid=true;        
    for i=4:length(p)
        c1=colors(p(i));
        c2=colors(p(i-1));
        c3=colors(p(i-2));
        c4=colors(p(i-3));
        if c1==c2 && c2==c3 && c3==c4
            is_valid=false;
        end
    end
    if is_valid==false
        disp('Fails Color Check')
    end
        
    % Check visited every city
    cities=zeros(1,length(colors));
    for i=1:length(p)
        cities(p(i))=1;
    end
    is_valid2=sum(cities)==length(colors);
    if is_valid2==false
        disp('Fails Cover Check')
    end
    is_ok=is_valid && is_valid2 && length(p)==length(colors);
end