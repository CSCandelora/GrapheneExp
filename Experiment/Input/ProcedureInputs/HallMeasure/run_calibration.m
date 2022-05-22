%% Purpose: To run a calibration test dependent on user input for Varian 
%  V2900 power supply and corresponding magnet

%% Initialize variables

runCal.knob_space = 0.5;

runCal.knob = 0;

runCal.knob_max = 10;

runCal.Curr = 0;

runCal.PoleSite = 0;

runCal.TestSite = 0;

runCal.Difference = 0;

runCal.max_Rec = (runCal.knob_max * (1/runCal.knob_space)) + 1;

Cal.coeff = 0;

Cal.StartTime = datetime('now');

runCal.FileName = datestr(Cal.StartTime, 'yyyymmddHHMMSS');

% List of things to save
runCal.SaveFileNames = {'Tbl1_Calibrate'...
                        'Cal'...
                        };

%% Initialize table

TblVarsList = {...
    'm_Rec' ...
    'KnobValue' ...
    'Current' ...
    'PoleSite' ...
    'TestSite' ...
    'Difference'...
    };

Tbl1_Calibrate = DataTableInit(TblVarsList, runCal.max_Rec);

for i_Rec = 1:2
    if i_Rec == 1
        fprintf('Running calibration at pole site.');
        input('Ensure the probe is at pole site, then press enter');
        
            for m_Rec = 1:runCal.max_Rec

            %Calibrate at pole
            input(['Ensure the knob is turned to ' num2str(runCal.knob) ...
                ' and that the probe is on the pole site'... 
                ' then press enter']);
            
            %Measure output from Gauss Meter
            fprintf(OssilaX200.Comm, ['vsense2 measure']);
            runCal.PoleSite = str2num(fgetl(OssilaX200.Comm));
            
            %Convert from mV to T. For Range 3, 1mT = 1mV
%             runCal.PoleSite = PS / 10;
            
            %Enter to table
            Tbl1_Calibrate.m_Rec(m_Rec) = m_Rec;
            Tbl1_Calibrate.KnobValue(m_Rec) = runCal.knob;
            Tbl1_Calibrate.PoleSite(m_Rec) = runCal.PoleSite;
            
            %Move to next knob
            runCal.knob = runCal.knob + runCal.knob_space;
            
            %Save table
            save('Input\ProcedureInputs\HallMeasure\Recent_Cal.mat', runCal.SaveFileNames{:});
            save(['C:\Users\EDMR\Documents\GitLabProjects\experiments1516\Data\HallMeasure\MagnetCal\Calibration_d' runCal.FileName '.mat'],...
              runCal.SaveFileNames{:});

            end
    end
    if i_Rec == 2
        fprintf('Running calibration at test site.');
        input('Ensure the probe is at test site, then press enter');
        %Reset knob
        runCal.knob = 0;
        
            for m_Rec = 1:runCal.max_Rec

            %Calibrate at pole
            input(['Ensure the knob is turned to ' num2str(runCal.knob) ...
                ' and that the probe is on the pole site'... 
                ' then press enter']);
           
            %Measure output from Gauss meter
            fprintf(OssilaX200.Comm, ['vsense2 measure']);
            runCal.TestSite = str2num(fgetl(OssilaX200.Comm));
            
            %Convert from mV to T. For Range 3, 1mT = 1mV
%             runCal.TestSite = TS / 10
            
            %Enter to table 
            Tbl1_Calibrate.TestSite(m_Rec) = runCal.TestSite;
            
            %Move to next knob
            runCal.knob = runCal.knob + runCal.knob_space;
                    
            %Save table
            save('Input\ProcedureInputs\HallMeasure\Recent_Cal.mat', runCal.SaveFileNames{:});
            save('Input\ProcedureInputs\SpinRes\Recent_Cal.mat', runCal.SaveFileNames{:});
            save(['C:\Users\EDMR\Documents\GitLabProjects\experiments1516\Data\HallMeasure\MagnetCal\Calibration_d' runCal.FileName '.mat'],...
                  runCal.SaveFileNames{:});
        
            end
    end

end

%Find difference between the two places
        for m_Rec = 1:runCal.max_Rec
            runCal.Difference = Tbl1_Calibrate.PoleSite(m_Rec) - Tbl1_Calibrate.TestSite(m_Rec);
            
            %Enter to table
            Tbl1_Calibrate.Difference(m_Rec) = runCal.Difference;
            
        end

%Find proportionality difference from pole to test
x = Tbl1_Calibrate.PoleSite(1:runCal.max_Rec);
y = Tbl1_Calibrate.TestSite(1:runCal.max_Rec);
Cal.Blinefit = polyfit(x, y, 1);
Cal.EndTime = datetime('now');

%One last save
save('Input\ProcedureInputs\HallMeasure\Recent_Cal.mat', runCal.SaveFileNames{:});
save('Input\ProcedureInputs\SpinRes\Recent_Cal.mat', runCal.SaveFileNames{:});
save(['C:\Users\EDMR\Documents\GitLabProjects\experiments1516\Data\HallMeasure\MagnetCal\Calibration_d' runCal.FileName '.mat'],...
      runCal.SaveFileNames{:});

clear runCal
clear m_Rec
clear Tbl1_Calibrate

