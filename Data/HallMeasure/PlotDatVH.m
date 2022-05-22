%Purpose: Interpret the results collected for the
%To interpret Data gathered in HallMeasure. This will plot IV curves,
%calculate Hall Coeff, 
%
%
%Author: Christopher Candelora
%To do list for this code:
% - Make the rescaling of the access a separate function to call to clean
% things up
% - Save plots separately into different folders depending on B field. 
% - Copy notes structure from other plot dat.
% - See if there is some way to automatically switch to correct directory
% - Fix i_Rec + 1 everywhere
%% Clear the workspace

clear
close all
clc

%% Check directory (thanks Ethan)

Dir = pwd;
if ~(strcmp(Dir(end-32:end),'\experiments1516\Data\HallMeasure') || ...
        strcmp(Dir(end-32:end),'\experiments1516\Data\HallMeasure'))
    error('You are in the wrong directory. Navigate to ''...\experiments1516\Data\HallMeasure''')
end
clear Dir

%% Prompt to open a file

addpath(genpath('d2021A_FetTest'))

finput = input('Type the name of the file you would like to open (HMtest1, HMtest2,etc.)> ', 's');

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
%% Notes
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
        num2str(max(Tbl1_DataMetrics.GateV))];
    fprintf(fid, Notes);
    
    fprintf(fid, '\n');
        
    Notes = input('Add miscellaneous notes here: ', 's');
    fprintf(fid, Notes);
    fclose(fid);
end
%% Initialize variables

%Number of Gate Voltages
num_GateV = max(Tbl1_DataMetrics.m_GateV);
i_GateV = 0;

%Number of B Fields
num_BFields = max(Tbl1_DataMetrics.m_BField); 

% %Find number of points taken for each gate
% samples_GateV = max(Tbl1_DataMetrics.m_SourceDrainV);

%Find number of samples per field
% samples_BField = samples_GateV * num_GateV;

%Total num measurements
num_measure = max(Tbl1_DataMetrics.m_Measure);

%Total num samples
num_samples = max(Tbl1_DataMetrics.m_Rec)/num_measure;

%Subplot inputs
sp_m = 4;
sp_n = 6;
i_sp = 1;
i_plot = 1;
num_p_sp = 7;

%Hall coefficients. For now this is a voltage, but going forward we are
%going to make it a fixed current once we put a large resister in series
%first.

%S10 GFET dimensions

W = 50 * 1^(-6);
L = 30 * 1^(-6);

%% Process and Plot Data (the usual IV curves)

%% First, need to find dV_H/dB relationship for each gate voltage. Be good to
%have those in a subplot

for i_GateRec = 1:num_GateV
    
    i_RHRec = 1;
    
    %Sweep through all data until find V_G that we want.
    for i_Rec = 1:num_samples
        
        %For this Gate voltage in the sweep
        if Tbl1_DataMetrics.GateV(i_Rec*num_measure - (num_measure - 1)) == Tbl1_DataMetrics.GateV(i_GateRec*num_measure - (num_measure - 1))
            %Take measurements taken and average out.
            for i_measure = 1:num_measure
                RH.avx(i_measure) = Tbl1_DataMetrics.ApproximatedBField(i_Rec*num_measure - (num_measure - 1)+i_measure-1);
                RH.avy(i_measure) = Tbl1_DataMetrics.VS1(i_Rec*num_measure - (num_measure - 1)+i_measure-1);
                RH.avI(i_measure) = Tbl1_DataMetrics.Smu1I(i_Rec*num_measure - (num_measure - 1)+i_measure-1);
            end
            RH.x(i_RHRec) = mean(RH.avx);
            RH.y(i_RHRec) = mean(RH.avy);
            RH.I(i_RHRec) = mean(RH.avI);
            RH.SDx(i_RHRec) = std(RH.avx);
            RH.SDy(i_RHRec) = std(RH.avy);
            RH.SDI(i_RHRec) = std(RH.avI);
            
            i_RHRec = i_RHRec + 1;

        end
    end
    
    %Plot Hall voltage as fct of B
    figure (1)
    hold on
%     subplot(sp_m, sp_n, i_plot);
    plot(RH.x, RH.y);
    hold off
    
    %Calculate Hall Coeff values
    j = polyfit(RH.x, RH.y, 1);
   
    RH.GateV(i_GateRec) = Tbl1_DataMetrics.GateV(i_GateRec*num_measure - (num_measure - 1));
    RH.slope(i_GateRec) = j(1);
    RH.ISD (i_GateRec) = mean(RH.I);
    
    %Average standard deviation from all calculations
    RH.STDI(i_GateRec) = mean(RH.SDI);
    
    RH.RH(i_GateRec) = RH.slope(i_GateRec) * (1 / RH.ISD(i_GateRec));
    
end

figure(1)
title('dV_H / dB relationships')
xlabel('Tesla')
ylabel('Hall voltage')
savefig(['d2021A_FetTest\' b '\Hall_Voltage_' finput '.fig']);
disp(['Saved Hall_Voltage' finput '.fig']);

%Plot Hall Coefficients
figure(2)
hold on
scatter(RH.GateV, RH.RH);
title('Hall Coefficients as function of Gate Voltage');
xlabel('Gate Voltage (V)');
ylabel('Hall coefficient R_H (m^2 C^{-1}');
hold off
savefig(['d2021A_FetTest\' b '\Hall_Coeff_' finput '.fig']);
disp(['Saved Hall_Coeff_' finput '.fig']);

%% Second, calculate the Hall mobility for each gate voltage
    %Preallocate memory for nH
    nH = zeros(1, num_GateV);

for i_GateRec = 1:num_GateV
        nH(i_GateRec) = (RH.RH(i_GateRec) * 1.60217663 * 10^(-19))^(-1);
end

%Plot Hall mobility (Without absolute value)
figure(3)
hold on
scatter(RH.GateV, nH);
errorbar(RH.GateV, nH, (1 ./ RH.STDI));
title('Charge density as function of gate voltage')
xlabel('Gate voltage (V)')
ylabel('Charge density n_H (m^{-2})')
hold off
savefig(['d2021A_FetTest\' b '\Charge_Density_' finput '.fig']);
disp(['Saved Charge_Density_' finput '.fig']);

%Plot Hall mobility (absolute value)
figure(4)
hold on
scatter(RH.GateV, abs(nH));
title('Abs Charge density as function of gate voltage')
xlabel('Gate voltage (V)')
ylabel('Charge density n_H (m^{-2})')
hold off
savefig(['d2021A_FetTest\' b '\Abs_Charge_Density_' finput '.fig']);
disp(['Saved Abs_Charge_Density_' finput '.fig']);

%% Third, calculate the sheet resistance (which needs to be imported from
%another file.

%First, prompt user to choose corresponding eTransport file
addpath(genpath('C:\Users\EDMR\Documents\GitLabProjects\experiments1516\Data\eTransport'))

finputt = input('Type the name of the corresponding eTransport file (test1, test2,etc.)> ', 's');

finfo = dir('C:\Users\EDMR\Documents\GitLabProjects\experiments1516\Data\eTransport\d2021A_FetTest');
fnames = {finfo.name};
numfiles = length(fnames);
i_file = 1;
finputlength = strlength(finputt);

while i_file <= numfiles
    c = fnames(i_file);
    d = char(c);
    if d(1) == 'd'
        flength = strlength(fnames(i_file));
        if flength == 34 && finputlength == 5
            if d(flength-4:flength) == finputt
                load(['eTransport\d2021A_FetTest\' d '\' finputt 'Hall.mat']);
                disp(['Loaded file ' d]);
                i_file = numfiles+1;
            end
        elseif flength == 35 && finputlength == 6
            if d(flength-5:flength) == finputt
                load(['eTransport\d2021A_FetTest\' d '\' finputt 'Hall.mat']);
                disp(['Loaded file ' d]);
                i_file = numfiles+1;
            end
        end
            
    end
    i_file = i_file+1;
end



%Calculate sheet resistance and then mobility
    %Preallocate memory for RS
    RS = zeros(1, num_GateV);
    mob = zeros(1, num_GateV);

for i_GateRec = 1:num_GateV
    RS(i_GateRec) = Hall.R(i_GateRec) * (W/ L);
    mob(i_GateRec) = (nH(i_GateRec) * 1.60217663 * 10^(-19) * RS(i_GateRec))^(-1) * 10^4;
    %10^4 is to go from m^2 to cm^2
end

%Now plot mobilities
figure(5)
hold on
scatter(RH.GateV, mob)
title('Mobility of charge carriers');
xlabel('Gate Voltage (V)');
ylabel('Mobility (cm^2 V^{-1} s^{-1})');
hold off

savefig(['d2021A_FetTest\' b '\Mobility_' finput '.fig']);
disp(['Saved Mobility_' finput '.fig']);

%Now plot mobilities
figure(6)
hold on
scatter(RH.GateV, abs(mob))
title('Abs Mobility of charge carriers');
xlabel('Gate Voltage (V)');
ylabel('Mobility (cm^2 V^{-1} s^{-1})');
hold off

savefig(['d2021A_FetTest\' b '\Abs_Mobility_' finput '.fig']);
disp(['Saved Abs_Mobility_' finput '.fig']);


%% Allow to type results after conclusions

ninput = input('Care to add conclusions? (y/n) > ', 's');

if ninput == 'y'
   fid = fopen(['d2021A_FetTest\' b '\' finput 'Notes.txt'], 'a+');
   fprintf(fid, '\n');
   Notes = input('Add conclusions here: ','s');
   fprintf(fid, Notes);
   fclose(fid);
end