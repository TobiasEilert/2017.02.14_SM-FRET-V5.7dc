% zeile 88 contains threshold!!
% 1st column: movie number
% 2nd column: molecule number
% 4th column in MW: FRET value
% 6th column in MW: gamma value
% 7th column in FRW: FRET value

%load files for Molecule-wise analysis
[file path] = uigetfile('*_res.txt','Loading FRET Results','MultiSelect','on');
file_temp = file(1,2:end);      %somehow MultiSelect messes up the order... --> dirty fix!
file = [file_temp, file(1,1)];
clear file_temp;
data_MW= [];
number_of_files = size(file,2)
for i=1:number_of_files
    filename = strcat(path,file{1,i});
    disp(['  Loading "' filename '"...']);
    append = load(filename);
    thpos = strfind(filename,'_th');                      %add movie number to table
    thpos2= thpos - 3;                                    %add movie number to table
    movnum = filename(thpos2:thpos-1);                    %add movie number to table         
    movnum1 = movnum(strfind(movnum,'_')+1:numel(movnum));%add movie number to table
    movnum1 = str2num(movnum1);                           %add movie number to table
    bli = size(append,1);%bli is row numbers of append
    bla = ones(bli,1)*movnum1;%bla is vector with as many rows filled with movienumber as molecules
    append = [bla append];
    disp(['file: ', filename, 'loaded']);
    data_MW = [data_MW; append];
    clear append;
    clear bli
    clear bla
end

%load files with Framewise-analysis
[file path] = uigetfile('*_FRETonly_trace.txt','Loading FRET Results','MultiSelect','on');
file_temp = file(1,2:end);      %somehow MultiSelect messes up the order... --> dirty fix!
file = [file_temp, file(1,1)];
clear file_temp;
data_FRW= [];
number_of_files = size(file,2)
for i=1:number_of_files
    filename = strcat(path,file{1,i});
    disp(['  Loading "' filename '"...']);
    append = load(filename);
    thpos = strfind(filename,'_th');
    thpos2= thpos - 3;
    movnum = filename(thpos2:thpos-1);         
    movnum1 = movnum(strfind(movnum,'_')+1:numel(movnum));
    movnum1 = str2num(movnum1);
    bli = size(append,1);%bli is row numbers of append (varies with moleculenr/movie)
    bla = ones(bli,1)*movnum1;%bla is vector with as many rows filled with movienumber as molecules
    append = [bla append];
    disp(['file: ', filename, 'loaded']);
    data_FRW = [data_FRW; append];
    clear append;
end

thilodummy = data_MW;
zeilen = length(data_MW);
output_FRW = [];
output_MW = [];
output_FRW_DIFF_MOVNR = diff(data_FRW(:,1));%change in movie number
output_FRW_DIFF_MOVNR(output_FRW_DIFF_MOVNR~=0) = 1;%set it to 1
output_FRW_DIFF_MOVNR = [1;output_FRW_DIFF_MOVNR];% add 1 to get the correct row number

output_FRW_DIFF = diff(data_FRW(:,2));%change in molecule number in data_FRW
output_FRW_DIFF(output_FRW_DIFF~=0) = 1;%set diff to 1
output_FRW_DIFF = [1;output_FRW_DIFF];%add 1 to get the correct row number

NEWMOL_ROW = output_FRW_DIFF | output_FRW_DIFF_MOVNR; 

            %account for bug: sometimes in two adjacent movies the same molecule nr. 
            %is chosen => diff(molenr)=0 but not diff(movnr) => molecule
            %can still be found 

nonzero_FRW_DIFF = find(NEWMOL_ROW(:,1));


output_FRW_dummy = [];
output_MW_dummy = [];

j= 1;% j counts zeilen in output_FRW_dummy
     % l counts zeilen in data_FRW 
     % i counts zeilen in data_MW
k=1; % k counts zeilen in output_MW_dummy
       
    for i = 1:zeilen
        if (thilodummy(i,6)<0.25) | (thilodummy(i,6) > 1.5); %Here an arbitrary threshold is set between 0.25 and 1.5
           output_MW_dummy(1,1) = k; %fortlaufende zeilennummer
           output_MW_dummy(1,2) = data_MW(i,1); % molecule number
           output_MW_dummy(1,3) = data_MW(i,4); % FRET value per molecule
           output_MW_dummy(1,4) = data_MW(i,6); % gamma value per molecule
           k=k+1;
           l = nonzero_FRW_DIFF(i,1); %l counts zeilen in data_FRW 
          if i~=zeilen
           b=(nonzero_FRW_DIFF(i+1,1)-nonzero_FRW_DIFF(i,1));%b counts how many frames are in one molecule
          else
           b=length(data_FRW)-nonzero_FRW_DIFF(i,1);
          end
           for j = 1:b
                output_FRW_dummy(j,1) = data_FRW(l,2);%molecule number
                output_FRW_dummy(j,2) = data_FRW(l,7);%FRW fret value
                output_FRW_dummy(j,3) = data_MW(i,6);%gamma value for the molecule (from MW table)
                l=l+1;
             end
             output_MW = [output_MW; output_MW_dummy];
             output_FRW = [output_FRW; output_FRW_dummy];
             clear output_FRW_dummy
             clear output_MW_dummy
           end
    end
    
%save MW output    
[filename, pathname] = uiputfile({'*.dat';'*.*'}, 'Save MOLECULE-WISE Data-file', path);
if isequal(filename,0) | isequal(pathname,0) disp('Data not saved.'); return; end;
em_name=[pathname filename];
if isempty(findstr(em_name,'.dat'))
    em_name=strcat(em_name,'.dat');
end 
save(em_name,'output_MW','-ASCII');
strcat('Data written to ',em_name)

%save FRW output
[filename, pathname] = uiputfile({'*.dat';'*.*'}, 'Save FRAME-WISE Data-file', path);
if isequal(filename,0) | isequal(pathname,0) disp('Data not saved.'); return; end;
em_name=[pathname filename];
if isempty(findstr(em_name,'.dat'))
    em_name=strcat(em_name,'.dat');
end 
save(em_name,'output_FRW','-ASCII');
strcat('Data written to ',em_name)