[file path] = uigetfile('*_res.txt','Loading FRET Results','MultiSelect','on');
file_temp = file(1,2:end);      %somehow MultiSelect messes up the order... --> dirty fix!
file = [file_temp, file(1,1)];
clear file_temp;
data= [];
number_of_files = size(file,2)
for i=1:number_of_files
    filename = strcat(path,file{1,i});
    disp(['  Loading "' filename '"...']);
    append = load(filename);
    disp(['file: ', filename, 'loaded']);
    data = [data; append];
    clear append;
end


[filename, pathname] = uiputfile({'*.dat';'*.*'}, 'Save as Data-file', path);
if isequal(filename,0) | isequal(pathname,0) disp('Data not saved.'); return; end;
em_name=[pathname filename];
if isempty(findstr(em_name,'.dat'))
    em_name=strcat(em_name,'.dat');
end 
save(em_name,'data','-ASCII');
strcat('Data written to ',em_name)