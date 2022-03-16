% Jorge Rey-Martinez (C) 2020 
%
% ONLY FOR SPANISH EXPORTED FILES, where field separator is ";" and decimal
% separator is ",". The script should be modified for english scv files
% computation
%
% read = error in file access
% name
% gainR
% gainL
% numberHIT number of different date HIT test
% date test date
% testN: The number of test to read... by default should be 1 on a second
% external call can be set to other values
function [read,name,gainR,gainL,numberHIT,type,date] = readCSV(file,testN)
type = 'unknown';
date = 'unknown';
read = 1;
name = 'Error';
readFile = fopen(file);
gainR = [];
gainL = [];
numberHIT = 0;
if readFile == -1
    disp(['File NOT loaded: ', file])
    read = -1;
    return
else
    disp(['File loaded: ',file])
end
nline = fgetl(readFile);
isFirst = 1;
numberHIT = 0;
%Read line by line
while ischar(nline)
    if isFirst == 1
        isFirst = 0;
        rawName = nline;
        cutName = strsplit(rawName,';');
        name = [cutName{2} ', ' cutName{3}];
    end
    
    if strcmp(nline,'Test Type;VVOR — Horizontal')||strcmp(nline,'Test Type;RVVO ? Horizontal')||strcmp(nline,'Tipo de Prueba;RVVO — Horizontal')||strcmp(nline,'Test Type;RVVO — Horizontal')
        %VVOR
    end
    
    if strcmp(nline,'Test Type;VORS — Horizontal')||strcmp(nline,'Test Type;VORS ? Horizontal')||strcmp(nline,'Test Type;SRVO — Horizontal')||strcmp(nline,'Tipo de Prueba;SRVO — Horizontal')
        %VORS
    end
    
    if strcmp(nline,'Test Type;Head Impulse Lateral')||strcmp(nline,'Tipo de Prueba;Head Impulse Lateral')
        %vHIT Lateral
        numberHIT = numberHIT + 1;
        if numberHIT == testN
            type = 'HIT-Lateral';
            rawDate = previousLine;
            cutDate = strsplit(rawDate,';');
            date = cutDate{2};
            [gainR, gainL] = getGain(readFile);
        end
        
    end
    
    if strcmp(nline,'Test Type;Head Impulse RALP')
        %vHIT RALP
    end
    
    if strcmp(nline,'Test Type;Head Impulse RALP')
        %vHIT LARP
    end
    previousLine = nline;
    nline = fgetl(readFile);
    
end
fclose(readFile);
% Analysis function
end
function [gainR, gainL] = getGain(readFile)
gainR = NaN;
gainL = NaN;
loopEnd = true;
cuenta = 0;
while loopEnd
    nline = fgetl(readFile);
    if ~isempty(nline)
        cutLine = strsplit(nline,';');
        if strcmp (cutLine{1},'Impulse 1')||strcmp (cutLine{1},'Impulso 1')
            hitLines = string(nline);
            while ~isempty(nline)
                nline = fgetl(readFile);
                hitLines = vertcat(hitLines,string(nline));
            end
            [allGainR,allGainL] = readHIT(hitLines);
            gainR = mean(allGainR);
            gainL = mean(allGainL);
            return
        end
        
        if cuenta > 4000
            disp('HIT loop aborted, file is too long!')
            return
        end
    end
    cuenta = cuenta + 1;
end

end

function [gainR,gainL] = readHIT(hitLines)
gainR = [];
gainL = [];
[s,~] = size(hitLines);
actualLine = 1;
while actualLine < s
    rawLine = hitLines(actualLine);
    sectorLine = strsplit(rawLine,';');
    wordFist = strsplit(sectorLine{1}," ");
    if strcmp(wordFist{1},'Impulse')||strcmp(wordFist{1},'Impulso')
        side = sectorLine{3};
    end
    if strcmp(sectorLine{2},'Gain')||strcmp(sectorLine{2},'Ganancia')
        rawGain = sectorLine{3};
        %decimal , to . conversion
        if contains(rawGain, ',')
            engGain = strrep(rawGain,',','.');
            preGain = str2double(engGain);
        else
            preGain = str2double(rawGain);
        end
        actualLine = (actualLine + 5);
        %some files has one extra line !!! shit programming GN
        preCheck = hitLines(actualLine);
        preCheckEye = strsplit(preCheck,';');
        if strcmp(preCheckEye{2},'Head')||strcmp(preCheckEye{2},'Cabeza')
            actualLine = actualLine-1;
        end
        rawEye = hitLines(actualLine);
        actualLine = (actualLine + 1);
        rawHead = hitLines(actualLine);
        actualLine = (actualLine + 1);
        rawDeleted = hitLines(actualLine);
        preDeleted = strsplit(rawDeleted,';');
        isDeleted = preDeleted{3};
        if strcmp(side,'Left')||strcmp(side,'Izquierda')
            if strcmp(isDeleted,"No")
                gainL = vertcat(gainL,preGain);
            end
        else
            if strcmp(isDeleted,"No")
                gainR = vertcat(gainR,preGain);
            end
        end
    end
    actualLine = actualLine + 1;
end
end






