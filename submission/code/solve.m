function [retvalue] = solve(input_directory,output_directory,done_directory,timeout_directory,tlimitsec)
    % Get all files, process in sorted order
    all_files=dir(strcat(input_directory,'*.in'));
    files={};
    for i=1:length(all_files)
       files{i}=all_files(i).name;
    end
    
    % Files that took too long
    timeout_files={};
    
    % Process files
    n_optimal=0;
    ntimedout=1;
    for i=1:length(files)
        % Debug print
        filepath=strcat(input_directory,char(files(i)));
        fprintf('%s\n',strcat('Processing:',filepath));       
        
        % Solve
        [path,costopt,isopt,exitval]=TSP(filepath,0,tlimitsec);
        
        if exitval==1
            % Individual output file
            [pathstr,name,ext]=fileparts(char(files(i)));
            cur_out_file=fopen(strcat(output_directory,name,'.out'),'w');
            fprintf('%s\n',strcat('Writing To:',strcat(output_directory,name,'.out')));
            
            % Validation file output
            val_out_file=fopen(strcat(output_directory,name,'.out_validation'),'w');
            fprintf(val_out_file,'%g\n',costopt);
            
            % Write to outputs
            g=sprintf('%d ',path);
            fprintf(cur_out_file,'%s\n',g);
        
            % Close file
            fclose(cur_out_file);
            
            % Count optimal answers
            if isopt==true
                n_optimal=n_optimal+1;
            end
            
            % Move solved input
            copyfile(filepath,strcat(done_directory,char(files(i))));
            delete(filepath);
        else
            fprintf('Timeout %s\n', filepath);
            timeoutfiles{ntimedout}=filepath;
            ntimedout=ntimedout+1;
            
            % Move timoue to timeoutdir
            copyfile(filepath,strcat(timeout_directory,char(files(i))));
            delete(filepath);
        end
    end
    
    % Print statistics
    fprintf('%d optimal answers out of %d inputs\n',n_optimal,length(files));    
    disp('Files that timed out');
    disp(timeoutfiles);
end