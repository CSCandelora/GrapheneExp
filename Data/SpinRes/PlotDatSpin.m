%Purpose: Interpret the results collected for the
%GFET experiments in a general way.
%
%
%Author: Christopher Candelora
%% Clear the workspace

clear
close all
clc

%% Check directory (thanks Ethan)

% Dir = pwd;
% if ~(strcmp(Dir(end-31:end),'\experiments1516\Data\SpinRes') || ...
%         strcmp(Dir(end-31:end),'\experiments1516\Data\SpinRes'))
%     error('You are in the wrong directory. Navigate to ''...\experiments1516\Data\SpinRes''')
% end
% clear Dir

%% What file want to open?

addpath(genpath('d2021A_FetTest'))

finput = input('Type the name of the file you would like to open (SRtest1, SRtest2,etc.)> ', 's');

finfo = dir('d2021A_FetTest');
fnames = {finfo.name};
numfiles = length(fnames);
i_file = 1;
finputlength = strlength(finput);

while i_file <= numfiles
    a = fnames(i_file);
    b = char(a);
    if b(1) == 'd'
        flength = strlength(fnames(i_file));
        if flength == 36 && finputlength == 7
            if b(flength-6:flength) == finput
                load([b '\' b '.mat']);
                disp(['Loaded file ' b]);
                i_file = numfiles+1;
            end
        elseif flength == 37 && finputlength == 8
            if b(flength-7:flength) == finput
                load([b '\' b '.mat']);
                disp(['Loaded file ' b]);
                i_file = numfiles+1;
            end
        end
            
    end
    i_file = i_file+1;
end

ninput = input('Care to add notes? (y/n) > ', 's');

if ninput == 'y'
    fid = fopen(['d2021A_FetTest\' b '\' finput 'Notes.txt'], 'wt');
    Notes = ['Start time: ' datestr(ExperimentStartTime)];
    fprintf(fid, Notes);
    fprintf(fid, '\n');
    Notes = input('What Graphene device did you use? (i.e. S10 #1, S11 #2, etc.) > ' , 's');
    fprintf(fid, Notes);
    fprintf(fid, '\n');
    Notes = input('Which transistor did you use? (4 probe #2, 2 probe #1, etc.) > ' , 's');
    fprintf(fid, Notes);
    fprintf(fid, '\n');
    disp('Writing experimental parameters...');
    Notes = ['\nV_SD = ' num2str(min(Tbl1_DataMetrics.SourceDrainV))...
        ':'...
        num2str((max(Tbl1_DataMetrics.SourceDrainV)-min(Tbl1_DataMetrics.SourceDrainV))/(max(Tbl1_DataMetrics.m_SourceDrainV)-1))...
        ':'...
        num2str(max(Tbl1_DataMetrics.SourceDrainV))...
        '\nV_G = '...
        num2str(min(Tbl1_DataMetrics.GateV))...
        ':'...
        num2str((max(Tbl1_DataMetrics.GateV)-min(Tbl1_DataMetrics.GateV))/(max(Tbl1_DataMetrics.m_GateV)-1))...
        ':'...
        num2str(max(Tbl1_DataMetrics.GateV))...
        ];
    fprintf(fid, Notes);
    
    fprintf(fid, '\n');
        
    Notes = input('Add miscellaneous notes here: ', 's');
    fprintf(fid, Notes);
    fclose(fid);
end

%% Initialize variables
% Allocate space 
R = zeros(1, Proc.NumBFields);
B = zeros(1, Proc.NumBFields);
NumPerFreq = max(Tbl1_DataMetrics.m_Rec)/Proc.NumFreq;

% Relevant standard deviations
Vstd = std(Tbl1_DataMetrics.Smu1V);
Istd = std(Tbl1_DataMetrics.Smu1I);

%% Process and Plot Data

for i_Freq = 1:1:Proc.NumFreq
    
    for i_BField = 1:1:(Proc.NumBFields)
        
        %Take averages
        Vx = Tbl1_DataMetrics.Smu1V((Proc.NumSourceDrainV*i_BField - (Proc.NumSourceDrainV - 1) + NumPerFreq*(i_Freq-1)):...
            ((i_BField)*Proc.NumSourceDrainV)+ NumPerFreq*(i_Freq-1));
        Ix = Tbl1_DataMetrics.Smu1I((Proc.NumSourceDrainV*i_BField - (Proc.NumSourceDrainV - 1)+ NumPerFreq*(i_Freq-1)):...
                ((i_BField)*Proc.NumSourceDrainV)+ NumPerFreq*(i_Freq-1));
        
        %Find Resistance
        R(i_BField) = mean(Vx)/mean(Ix);
        Rstd(i_BField) = R(i_BField) * std(Ix)/(2*mean(Ix));
%         p = polyfit(x, y, 1);
%         R(i_BField) = 1/p(1);
%         err(i_BField) = R(i_BField)(
        
        %Save B Field value for this resistance
        B(i_BField) = mean(Tbl1_DataMetrics.ApproximatedBField(...
            (Proc.NumSourceDrainV*i_BField - (Proc.NumSourceDrainV - 1)+ NumPerFreq*(i_Freq-1)):...
            ((i_BField)*Proc.NumSourceDrainV)+ NumPerFreq*(i_Freq-1)));
        
    end
    
    figure(1)
    hold on
    name = [num2str(Tbl1_DataMetrics.Frequency(i_Freq*Proc.NumSourceDrainV...
        *Proc.NumBFields)) ' GHz' ];
    errorbar(B, R, Rstd,'.-', 'DisplayName',name, 'LineWidth', 1)
    title(['Resistance vs Magnetic Field at V_G = '...
        num2str(Tbl1_DataMetrics.GateMeasureV(1)) ' for Different Frequency'])
    ylabel('R_{XX} (\Omega)')
    xlabel('B (Tesla)')
    
    Delta.Res(:, :, i_Freq) = R;
    Delta.BField(:, :, i_Freq) = B;
    Delta.Freq(:, :, i_Freq) = Tbl1_DataMetrics.Frequency(i_Freq*Proc.NumSourceDrainV...
        *Proc.NumBFields);
    Delta.Rstd(:, :, i_Freq) = Rstd;

end

hold off
legend show

%Save file
savefig(['d2021A_FetTest\' b '\Resistance_BField_' finput '.fig']);
disp(['Saved Reisistance_BField_' finput '.fig']);
%% Plot the Delta R_XX

%Find Dark Condition
for i_Freq = 1:1:Proc.NumFreq
    if Delta.Freq(:, :, i_Freq) == 0
        R_Dark = Delta.Res(:, :, i_Freq);
        Dark_Freq = i_Freq;
    end
end

%Calculate Difference
for i_Freq = 1:1:Proc.NumFreq
    if Delta. Freq(:, :, i_Freq) ~= 0
        ResDiff = Delta.Res(:, :, i_Freq) - R_Dark;
        errorDiff = ((Delta.Rstd(:, :, i_Freq)).^2+(Delta.Rstd(:, :, Dark_Freq)).^2 ...
                    - 2*Delta.Rstd(:, :, i_Freq).*Delta.Rstd(:, :, Dark_Freq)).^(1/2);

        figure(2)
        hold on
        name = [num2str(Delta.Freq(:, :, i_Freq)), ' GHz'];
        errorbar(Delta.BField(:, :, i_Freq), ResDiff, errorDiff, '.-', 'DisplayName', name, 'LineWidth', 1);
        title('Resistance Difference Between Frequencies')
        xlabel('B (Tesla)')
        ylabel('\Delta R_{XX} (\Omega)')
    end
end

hold off
legend show
%Save file
savefig(['d2021A_FetTest\' b '\DeltaResistance_' finput '.fig']);
disp(['Saved DeltaResistance_' finput '.fig']);

        
%% Allow to type results after conclusions

beep

ninput = input('Care to add conclusions? (y/n) > ', 's');

if ninput == 'y'
   fid = fopen(['d2021A_FetTest\' b '\' finput 'Notes.txt'], 'a+');
   fprintf(fid, '\n');
   Notes = input('Add conclusions here: ','s');
   fprintf(fid, Notes);
   fclose(fid);
end
