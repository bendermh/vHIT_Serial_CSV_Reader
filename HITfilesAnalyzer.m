% Jorge Rey-Martinez (C) 2020 
% An automatic CSV exported ICS IMPULSE vHIT (TM) software
% ONLY FOR SPANISH EXPORTED FILES, where field separator is ";" and decimal
% separator is ",". The script should be modified for english scv files
% computation on the readCSV.m script
%
% Exported CSV files should be included together in the same folder.
path = uigetdir;
if path == 0
    disp('Folder not selected')
    return
end
files = dir(path);
[s,~] = size(files);
filePosition = 1;
bar = waitbar(0,'Analyzing files from folder...');
HITtoAnalyze = 1;
errorFiles = [];
Resultados = [];
Nombres = [];
GananciasR = [];
GananciasL = [];
Numeros = [];
Tipos = [];
Fechas = [];
while filePosition <= s
    waitbar((filePosition/s),bar)
    files(filePosition).name;
    files(filePosition).folder;
    nowFile = fullfile(files(filePosition).folder,files(filePosition).name);
    if ~files(filePosition).isdir
        esError = 0;
        try
            [resultadoF,nombreF,gananciaRF,gananciaLF,numeroF,tipoF,fechaF] = readCSV(nowFile,1);
        catch
            esError = 1;
            errorFiles = vertcat(errorFiles,string(files(filePosition).name));
        end
        if esError == 0
            if isempty(gananciaRF)
                gananciaRF = NaN;
            end
            if isempty(gananciaLF)
                gananciaLF = NaN;
            end
            Resultados = vertcat(Resultados,string(resultadoF));
            Nombres = vertcat(Nombres,string(nombreF));
            GananciasR = vertcat(GananciasR,gananciaRF);
            GananciasL = vertcat(GananciasL,gananciaLF);
            Numeros = vertcat(Numeros,str2num(string(numeroF)));
            Tipos = vertcat(Tipos,string(tipoF));
            Fechas = vertcat(Fechas,string(fechaF));
        end
    end
    filePosition = filePosition + 1;
end
close(bar)
if ~isempty(errorFiles)
    disp('Error was found on files:')
    disp(errorFiles)
end
export = table(Resultados,Nombres,GananciasR,GananciasL,Numeros,Tipos,Fechas);
disp('Data will be exported to your app folder as -exportedHITs.csv- file')
writetable(export,'exportedHITs.csv')
