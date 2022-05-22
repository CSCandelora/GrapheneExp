%Purpose: Interpret the results collected for the
%GFET experiments in a general way.
%
%
%Author: Christopher Candelora
% To Do for this code:
% - Look at PlotDatVH and reorganize in that way to clean things up. Hard
% to follow this mess, though it works.
%% Clear the workspace

clear
close all
clc

%% Check directory (thanks Ethan)

Dir = pwd;
if ~(strcmp(Dir(end-31:end),'\experiments1516\Data\eTransport') || ...
        strcmp(Dir(end-31:end),'\experiments1516\Data\eTransport'))
    error('You are in the wrong directory. Navigate to ''...\experiments1516\Data\eTransport''')
end
clear Dir

%% What file want to open?

addpath(genpath('d2021A_FetTest'))

finput = input('Type the name of the file you would like to open (test1, test2,etc.)> ', 's');

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
        if flength == 34 && finputlength == 5
            if b(flength-4:flength) == finput
                load([b '\' b '.mat']);
                disp(['Loaded file ' b]);
                i_file = numfiles+1;
            end
        elseif flength == 35 && finputlength == 6
            if b(flength-5:flength) == finput
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
        num2str(max(Tbl1_DataMetrics.GateV))];
    fprintf(fid, Notes);
    
    fprintf(fid, '\n');
        
    Notes = input('Add miscellaneous notes here: ', 's');
    fprintf(fid, Notes);
    fclose(fid);
end

%% Initialize variables
max_GateV = max(Tbl1_DataMetrics.GateV);
num_GateV = max(Tbl1_DataMetrics.m_GateV);
i_GateV = 0;

%Find number of points taken for each gate
samples_GateV = max(Tbl1_DataMetrics.m_SourceDrainV);

%Subplot inputs
    spinput = input('Would you like to make subplots? (y/n)(More computational heavy. Takes longer) > ', 's');
    
    while ~(strcmp(spinput, 'y') || strcmp(spinput, 'n'))
        spinput = input('Invalid entry. Please try again > ', 's');
    end
    
    if spinput == 'y'
        spinput = 1;
    end
    if spinput == 'n'
        spinput = 0;
    end


sp_m = 5;
sp_n = 8;
i_sp = 1;
i_plot = 1;
num_p_sp = 6;
%Num Subplots
%  num_p_sp = 7;
%  num_sp = ceil(num_GateV/num_p_sp);
%  i_sp = 1;
%  i_plot = 1;
%  num_sp_vec = 1:num_sp;
 
 %Figure out grid plot
%  D = num_sp_vec(rem(num_sp, num_sp_vec)==0);
%  dlength = length(D);
%  sp_m = 2; %D(ceil(dlength/2));
%  sp_n = 11; %D(ceil((dlength/2)) + 1);

%% Process and Plot Data
for i_Rec= 0:1:num_GateV
    
    if i_Rec == num_GateV
        figure(2)
        scatter(V, R);
        xlabel('V_G (V)');
        ylabel('R (Ohms)');
        title([finput ' Resistance for Different Gate Voltages']);
        savefig(['d2021A_FetTest\' b '\Resistance_Plot_' finput '.fig']);
        disp(['Saved Resistance_Plot ' finput '.fig']);
        
        figure(3);
        scatter(V, AG);
        xlabel('V_G (V)');
        ylabel('Average I_{G} (A)');
        title([finput ' Average Gate Current for Different Gate Voltages']);
        savefig(['d2021A_FetTest\' b '\Average_Gate_Current_' finput '.fig']);
        disp(['Saved Average IG VG ' finput '.fig']);
        
        break
    
    else
        
        x = Tbl1_DataMetrics.SourceDrainV((i_Rec*samples_GateV+1):((i_Rec+1)*samples_GateV));
        y = Tbl1_DataMetrics.Smu1I((i_Rec*samples_GateV+1):((i_Rec+1)*samples_GateV));
        G = Tbl1_DataMetrics.GateMeasureI((i_Rec*samples_GateV+1):((i_Rec+1)*samples_GateV));
        if spinput == 1
            if i_sp < num_p_sp
                figure(4)
                hold on
                subplot(sp_m, sp_n, i_plot)
                plot(x,y);
                hold off
             
                 vsplegend(i_sp) = Tbl1_DataMetrics.GateV(i_Rec*samples_GateV+1);
                 figure(5)
                 hold on
                 subplot(sp_m, sp_n, i_plot)
                 plot(x, G)
                 hold off
                 i_sp = i_sp+1;
            else
                 figure(4)
                 legend(string(vsplegend));
                 Ax4_Handles.axes(i_plot) = gca;
                 figure(5)
                 legend(string(vsplegend));
                 Ax5_Handles.axes(i_plot) = gca;
                 clear vsplegend
                 i_sp = 1;
                 i_plot = i_plot + 1;
            end
        end
      
    figure(1);
    hold on
    xlabel('V_{SD} (V)');
    ylabel('I_{SD} (A)');
    title([finput ' I_{SD} V_{SD} Plot']);
    plot(x,y);
    hold off
  
    p = polyfit(x, y, 1);
    R(i_Rec+1) = 1/p(1);
    V(i_Rec+1) = Tbl1_DataMetrics.GateV((i_Rec+1)*samples_GateV);
    AG(i_Rec+1) = mean(G);
    end
    
end

%Save Var that are useful for Hall calculations
Hall.R = R;
Hall.Gate = V;
save(['d2021A_FetTest\' b '\' finput 'Hall'], 'Hall');

        %Put legend on last subplot and title subplot
        figure(1)
        savefig(['d2021A_FetTest\' b '\Source_Drain_Plot_' finput '.fig']);
        disp(['Saved Source_Drain_Plot_' finput '.fig']);
        if spinput == 1
            figure(4)
            legend(string(vsplegend));
            sgtitle([finput ' V_{SD} vs I_{SD} for various V_G'])
             Ax4_Handles.axes(i_plot) = gca;
             allYLim = get(Ax4_Handles.axes, {'YLim'});
             allYLim = cat(2, allYLim{:});
             set(Ax4_Handles.axes, 'YLim', [min(allYLim), max(allYLim)]);
             savefig(['d2021A_FetTest\' b '\Source_Drain_SP_' finput '.fig']);
             disp(['Saved Source_Drain_SP_' finput '.fig']);

            figure(5)
            legend(string(vsplegend));
            sgtitle([finput ' V_{SD} vs I_{G} for various V_G'])
             Ax5_Handles.axes(i_plot) = gca;
             allYLim = get(Ax5_Handles.axes, {'YLim'});
             allYLim = cat(2, allYLim{:});
             set(Ax5_Handles.axes, 'YLim', [min(allYLim), max(allYLim)]);
             savefig(['d2021A_FetTest\' b '\Gate_Current_SP_' finput '.fig']);
             disp(['Saved Gate_Current_SP' finput '.fig']);
            clear vsplegend
        end
        
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
