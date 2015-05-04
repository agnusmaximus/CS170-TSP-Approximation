function [retvalue] = solve(input_directory,output_directory)
    % Get all files, process in sorted order
    unsorted_files=dir(fullfile('', strcat(input_directory, '*.in')));
    files={unsorted_files.name};
    str=sprintf('%s#',files{:});
    num=sscanf(str,'%d.in#');
    [dummy,index]=sort(num);
    files=files(index);
    
    % Process files
    validationfilepath=strcat(output_directory,'validation_output');
    totaloutputfilepath=strcat(output_directory,'all_output');
    totaloutputfile=fopen(totaloutputfilepath,'w');
    validationfile=fopen(validationfilepath,'w');
    n_optimal=0;
    for i=1:length(files)
        % Debug print
        filepath=strcat(input_directory,char(files(i)));
        fprintf('%s\n',strcat('Processing:',filepath));
        
        % Individual output file
        [pathstr,name,ext]=fileparts(char(files(i)));
        cur_out_file=fopen(strcat(output_directory,name,'.out'),'w');
        
        % Solve
        [path,costopt,isopt]=TSP(filepath,0);
        
        % Write to outputs
        g=sprintf('%d ',path);
        fprintf(totaloutputfile,'%s\n',g);
        fprintf(cur_out_file,'%s\n',g);
        fprintf(validationfile,'%g\n',costopt);        
        
        % Close file
        fclose(cur_out_file);
        
        % Count optimal answers
        if isopt==true
            n_optimal=n_optimal+1;
        end
    end
    fclose(totaloutputfile);
    fclose(validationfile);
    
    % Print statistics
    fprintf('%d optimal answers out of %d inputs\n',n_optimal,length(files));    
end