[file path] = uigetfile('*_FRETonly_trace.txt','Loading FRET Results','MultiSelect','on');
file_temp = file(1,2:end);      %somehow MultiSelect messes up the order... --> dirty fix!
file = [file_temp, file(1,1)];
clear file_temp;
data= [];
number_of_files = size(file,2)
for i=1:number_of_files
    filename = strcat(path,file{1,i});
    disp(['  Loading "' filename '"...']);
    thilodummy = load(filename);
    zeilen = size(thilodummy,1);
    bla = [];
    blubb = [];
    for i = 1:zeilen
        if thilodummy(i,3) > 0.25;
           append = load(filename);
           thpos = strfind(filename,'_th');
           thpos2= thpos - 3;
           movnum = filename(thpos2:thpos-1);         
           movnum1 = movnum(strfind(movnum,'_')+1:numel(movnum));
           blubb(i,1) = str2num(movnum1);
           blubb(i,2) = thilodummy(i,3);
         end
    end
    disp(['file: ', filename, 'loaded']);
    data = [data; blubb];
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