function [retvalue] = solve(input_directory,output_file_path,validation_file_path)
    % Get all files, process in sorted order
    unsorted_files=dir(fullfile('', strcat(input_directory, '*.in')));
    files={unsorted_files.name};
    str=sprintf('%s#',files{:});
    num=sscanf(str,'%d.in#');
    [dummy,index]=sort(num);
    files=files(index);
    
    % Process files
    outputfile=fopen(output_file_path,'w');
    validationfile=fopen(validation_file_path,'w');
    n_optimal=0;
    for i=1:length(files)
        filepath=strcat(input_directory,char(files(i)));
        fprintf('%s\n',strcat('Processing:',filepath));
        [path,costopt,isopt]=TSP(filepath,0);
        g=sprintf('%d ',path);
        fprintf(outputfile,'%s\n',g);
        fprintf(validationfile,'%d\n',costopt);
        if isopt==true
            n_optimal=n_optimal+1;
        end
    end
    fclose(outputfile);
    fclose(validationfile);
    
    % Print statistics
    fprintf('%d optimal answers out of %d inputs\n',n_optimal,length(files));    
end