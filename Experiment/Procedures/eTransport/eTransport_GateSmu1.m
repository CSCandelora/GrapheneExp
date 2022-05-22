%% Purpose
% Procedure script for eTransport sweeps SD voltages specified in
% Input_eTransport_GateSmu1.m for various gate voltages defined in the same
% file. 
%
% Author: Ethan Williams and Chris Candelora

%% Initialize variables
Proc = InputSet.Proc;

Proc.NumRecs = length(Proc.GateV)*length(Proc.SourceDrainV);
Proc.NumSourceDrainV = length(Proc.SourceDrainV);
Proc.NumGateV = length(Proc.GateV);

m_Rec = 1;

% Initialize parameter index table
TblVarsList = {...
    'm_Rec' ...
    'm_GateV' ...
    'm_SourceDrainV' ...
    'GateV' ...
    'SourceDrainV' ...
    'GateMeasureV' ...
    'GateMeasureI' ...
    'Smu1V' ...
    'Smu1I' ...
    'VS2'...
    };

Tbl1_DataMetrics = DataTableInit(TblVarsList, Proc.NumRecs);

%% Record experiment notes
Proc.Notes = input('Enter experiment notes: ', 's');

%% Turn Instruments on
fprintf(Keithley2400, 'OUTPUT:STATE ON');
%Ossila turned on in "SetUpOssilaX200.m"

%% Experiment loop

%Start Gate V Sweep
for m_GateV = 1:Proc.NumGateV
    
    fprintf(Keithley2400, ['SOURCE:VOLTAGE ' num2str(Proc.GateV(m_GateV))]);
    disp(['-----Starting Gate Voltage ' num2str(Proc.GateV(m_GateV)) 'V'...
        '-----']); 
    
    %Start SD Sweep
    for m_SourceDrainV = 1:Proc.NumSourceDrainV
        disp(['m_SourceDrainV = ' num2str(m_SourceDrainV) ' of '... 
            num2str(Proc.NumSourceDrainV) '; m_GateV = ' num2str(m_GateV)...
            ' of ' num2str(Proc.NumGateV)])

      
        fprintf(OssilaX200.Comm,['smu1 set voltage '...
            num2str(Proc.SourceDrainV(m_SourceDrainV))]);

        fprintf(Keithley2400,':READ?');
        fprintf(Keithley2400,'++read eoi');
        
        Measurements = fgetl(Keithley2400);

        GateMeasureV = str2num(Measurements(1:13));
        GateMeasureI = str2num(Measurements(15:27));
        
        fprintf(OssilaX200.Comm, ['smu1 measurei']);
        Smu1I = str2num(fgetl(OssilaX200.Comm));
        fprintf(OssilaX200.Comm, ['smu1 measurev']);
        Smu1V = str2num(fgetl(OssilaX200.Comm));
        
    if InputSet.OssilaX200.VS2.Active == 1
        fprintf(OssilaX200.Comm, ['vsense2 measure']);
        VS2 = str2num(fgetl(OssilaX200.Comm));
    end
        
        Tbl1_DataMetrics.m_Rec(m_Rec) = m_Rec;
        Tbl1_DataMetrics.m_GateV(m_Rec) = m_GateV;
        Tbl1_DataMetrics.m_SourceDrainV(m_Rec) = m_SourceDrainV;
        Tbl1_DataMetrics.GateV(m_Rec) = Proc.GateV(m_GateV);
        Tbl1_DataMetrics.SourceDrainV(m_Rec) = Proc.SourceDrainV(m_SourceDrainV);
        Tbl1_DataMetrics.GateMeasureV(m_Rec) = GateMeasureV;
        Tbl1_DataMetrics.GateMeasureI(m_Rec) = GateMeasureI;
        Tbl1_DataMetrics.Smu1V(m_Rec) = Smu1V;
        Tbl1_DataMetrics.Smu1I(m_Rec) = Smu1I;
        
    if InputSet.OssilaX200.VS2.Active == 1
        Tbl1_DataMetrics.VS2(m_Rec) = VS2;       
    else
        Tbl1_DataMetrics.VS2(m_Rec) = 0;
    end
        m_Rec = m_Rec + 1;
        
        %% Save
        disp('Saving data file')
        disp('---')
        if ~exist(Proc.SavePath, 'dir')
           mkdir(Proc.SavePath)
        end
        save(Proc.SaveFileName, Proc.SaveList{:});
    end
end

%% Turn off instruments
beep
%Close the Ossila
fprintf(OssilaX200.Comm,'smu1 set voltage 0' );
fprintf(OssilaX200.Comm, ['smu1 set enabled 0']);
fprintf(OssilaX200.Comm, ['vsense2 set enabled 0']);
fclose(OssilaX200.Comm); 
delete(OssilaX200.Comm);
clear OssilaX200;
disp('OssilaX200 SMU1 and VS2 now closed');

%Close Keithley2400
fprintf(Keithley2400, 'SOURCE:VOLTAGE 0');
fclose(Keithley2400);
