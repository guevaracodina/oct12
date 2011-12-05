function sinfo=SiemensInfo(info)
% This function reads the information from the Siemens Private tag 0029 1020 
% from a struct with all dicom info.
%
%
% dcminfo=dicominfo('example.dcm');
% info = SiemensInfo(dcminfo)
%
%
%
str=char(info.Private_0029_1020(:))';
a1=strfind(str,'### ASCCONV BEGIN ###');
a2=strfind(str,'### ASCCONV END ###');
str=str((a1+22):a2-2);
request_lines = regexp(str, '\n+', 'split');
request_words = regexp(request_lines, '=', 'split');
sinfo=struct;
for i=1:length(request_lines)
    s=request_words{i};
    name=s{1};
    while(name(end)==' '); name=name(1:end-1); end
    while(name(1)==' '); name=name(2:end); end
    value=s{2}; value=value(2:end);
    if(any(value=='"'))
        value(value=='"')=[];
        valstr=true;
    else
        valstr=false;
    end
    names = regexp(name, '\.', 'split');
    ind=zeros(1,length(names));
    for j=1:length(names)
        name=names{j};
        ps=find(name=='[');
        if(~isempty(ps))
            pe=find(name==']');
            ind(j)=str2double(name(ps+1:pe-1))+1;
            names{j}=name(1:ps-1);
        end
    end
    try
    evalstr='sinfo';
    for j=1:length(names)
        if(ind(j)==0)
            evalstr=[evalstr '.(names{' num2str(j) '})'];
        else
            evalstr=[evalstr '.(names{' num2str(j) '})(' num2str(ind(j)) ')'];
        end
    end
    if(valstr)
        evalstr=[evalstr '=''' value ''';'];
    else
        if(strcmp(value(1:min(2:end)),'0x'))
            evalstr=[evalstr '='  num2str(hex2dec(value(3:end))) ';'];
        else
        evalstr=[evalstr '=' value ';'];
        end
    end
    eval(evalstr);
    catch ME
        warning(ME.message);
    end
end
