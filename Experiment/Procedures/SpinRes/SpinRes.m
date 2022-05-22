%% Purpose
% Procedure script for running spin resonance experiment on GFETs
%
%Author: Chris Candelora
%% Calibrate Magnet

%Prompt if calibration is necessary

Cal.respo = 'x';

while Cal.respo ~= 'y' || 'n' 
    Cal.respo = input('Is a calibration necessary? (y/n) > ', 's');

    if Cal.respo == 'y'
        disp('Calibrating...')
        run_calibration
        disp('Calibration completed successfully');
        break
        
    elseif Cal.respo == 'n'
        disp('Bypassing calibration. Opening previous calibration...');
        %Find a way to just save the difference run in the run_calibration to
        %prevent having to redo this calculation. See above with "Saving"
        %Maybe also consider splitting up Cal.coeff by different regimes since
        %it seemed that at higher currents the difference is greater b/w pole
        %and test where at lower currents it's smaller.
        load('SpinRes\Recent_Cal.mat');
        disp('Previous calibration loaded successfully');
        break
        
    else
        disp('Invalid response. Please try again');
    end
end

%% Initialize variables

Proc = InputSet.Proc;

Proc.NumRecs = Proc.NumBFields*Proc.NumFreq*Proc.NumSourceDrainV; %*length(Proc.SourceDrainV);
%Proc.NumSourceDrainV = length(Proc.SourceDrainV);
Proc.NumGateV = length(Proc.GateV);

m_Rec = 1;

% Initialize parameter index table
TblVarsList = {...
    'm_Rec' ...
    'm_GateV' ...
    'm_BField'...
    'm_SourceDrainV' ...
    'GateV' ...
    'SourceDrainV' ...
    'GateMeasureV' ...
    'GateMeasureI' ...
    'Smu1V' ...
    'Smu1I' ...
    'VS1'...
    'MeasuredBField'...
    'ApproximatedBField'...
    'Frequency'...
    };

Tbl1_DataMetrics = DataTableInit(TblVarsList, Proc.NumRecs);

%% Record experiment notes

Proc.Notes = input('Enter experiment notes: ', 's');

%% Turn on instruments 

fprintf(Keithley2400, 'OUTPUT:STATE ON');
% OssilaX200 turned on in "SetUpOssilaX200"

%% Experiment loop

%Start Loop for B Field
for m_Freq = 1:Proc.NumFreq
    
    beep
    Freq = input('Set the desired Frequency on WindFreak. Type Frequency (in GHz)> ', 's');
    
    for m_BField = 1:Proc.NumBFields

        fprintf(Keithley2400, 'SOURCE:VOLTAGE 0');
        fprintf(OssilaX200.Comm,'smu1 set voltage 0' );

        beep

        input('Set the desired B-Field. Press enter to continue.');

        %Start gate sweep
        for m_GateV = 1:Proc.NumGateV

            fprintf(Keithley2400, ['SOURCE:VOLTAGE '...
                                   num2str(Proc.GateV(m_GateV))]);
            disp(['-----Starting Gate Voltage '... 
                 num2str(Proc.GateV(m_GateV)) 'V'...
                 '-----']); 

            %Start SD Sweep
            for m_SourceDrainV = 1:Proc.NumSourceDrainV
                
                disp(['m_SourceDrainV = ' num2str(m_SourceDrainV) ' of '...
                    num2str(Proc.NumSourceDrainV) '; m_BField = ' num2str(m_BField)...
                    ' of ' num2str(Proc.NumBFields)])

                %Set SD voltage
                fprintf(OssilaX200.Comm,['smu1 set voltage '...
                        num2str(Proc.SourceDrainV)]);

                %Read Gate V and Current
                fprintf(Keithley2400,':READ?');
                fprintf(Keithley2400,'++read eoi');

                Measurements = fgetl(Keithley2400);
                GateMeasureV = str2num(Measurements(1:13));
                GateMeasureI = str2num(Measurements(15:27));

                %Measure SD Current
                fprintf(OssilaX200.Comm, ['smu1 measurei']);
                Smu1I = str2num(fgetl(OssilaX200.Comm));

                %Measure SD Voltage
                fprintf(OssilaX200.Comm, ['smu1 measurev']);
                Smu1V = str2num(fgetl(OssilaX200.Comm));

                %Measure Hall Voltage
                fprintf(OssilaX200.Comm, ['vsense1 measure']);
                VS1 = str2num(fgetl(OssilaX200.Comm));

                %Measure B Field
                fprintf(OssilaX200.Comm, ['vsense2 measure']);
                BField = str2num(fgetl(OssilaX200.Comm))*Proc.VtoTesla;

                %Calculate Approximate B Field
                ApproxBField = BField * Cal.Blinefit(1) + Cal.Blinefit(2);

                %Plot in table
                Tbl1_DataMetrics.m_Rec(m_Rec) = m_Rec;
                Tbl1_DataMetrics.m_GateV(m_Rec) = m_GateV;
                Tbl1_DataMetrics.m_BField(m_Rec) = m_BField;
                Tbl1_DataMetrics.m_SourceDrainV(m_Rec) = m_SourceDrainV;
                Tbl1_DataMetrics.GateV(m_Rec) = Proc.GateV(m_GateV);
                Tbl1_DataMetrics.SourceDrainV(m_Rec) = Proc.SourceDrainV;
                Tbl1_DataMetrics.GateMeasureV(m_Rec) = GateMeasureV;
                Tbl1_DataMetrics.GateMeasureI(m_Rec) = GateMeasureI;
                Tbl1_DataMetrics.Smu1V(m_Rec) = Smu1V;
                Tbl1_DataMetrics.Smu1I(m_Rec) = Smu1I;
                Tbl1_DataMetrics.VS1(m_Rec) = VS1;  
                Tbl1_DataMetrics.MeasuredBField(m_Rec) = BField;
                Tbl1_DataMetrics.ApproximatedBField(m_Rec) = ApproxBField;
                Tbl1_DataMetrics.Frequency(m_Rec) = str2num(Freq);

                %Increase counter
                m_Rec = m_Rec + 1;

                %Save Data Table and Variables
                disp('Saving data file')
                disp('---')
                if ~exist(Proc.SavePath, 'dir')
                   mkdir(Proc.SavePath)
                end
                save(Proc.SaveFileName, Proc.SaveList{:});
            end
        end
    end
end

%% Close Instruments

%Reminder to turn off magnet
% input('Be sure to turn off magnet power supply and water cooling.'...
%       'Press enter to proceed');

%Close the Ossila
fprintf(OssilaX200.Comm,'smu1 set voltage 0' );
fprintf(OssilaX200.Comm, ['smu1 set enabled 0']);
fprintf(OssilaX200.Comm, ['smu2 set enabled 0']);
fprintf(OssilaX200.Comm, ['vsense2 set enabled 0']);
fclose(OssilaX200.Comm); 
delete(OssilaX200.Comm);
clear OssilaX200;
disp('OssilaX200 SMU1 and VS2 now closed');

%Close Keithley2400
fprintf(Keithley2400, 'SOURCE:VOLTAGE 0');
fclose(Keithley2400);
