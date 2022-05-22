%% Purpose
%
%The purpose of this code is to supply all the input information necessary
%to run the HallMeasure Procedure, including instrument values, source drain
%values, and gate voltage values. It also prompts the user to calibrate the
%magnet so as to approximate the magnetic field at the test site a bit
%better.
%
%Author: Chris Candelora

%% Instrumentation settings

% Indicate experimental system settings file handle string
InputSet.System = 'HallMeasure';

% Specify the instruments used in this experiment
InputSet.InstInUse = {...
    'OssilaX200' ...
    'Keithley2400'};

% Input parameters for Keithly
InputSet.Keithley2400.Mode = 'GateV';
InputSet.Keithley2400.LimitI = 0.1;
InputSet.Keithley2400.SrcDelayInS = 1;
InputSet.Keithley2400.OnboardAvgNumPts = 10;

% Decide what ports to activate on the Ossila
InputSet.OssilaX200.Smu1.Active = 1;
InputSet.OssilaX200.Smu2.Active = 0;
InputSet.OssilaX200.VS1.Active = 1;
InputSet.OssilaX200.VS2.Active = 1;

% Specify current range
% Range 	Max Current 	Accuracy
% 1      100 mA          10 µA
% 2      10 mA           1 µA
% 3      1 mA            100 nA
% 4      100 µA          10 nA
% 5      10 µA           1 nA
% IMPORTANT NOTE:
% The range on the Xtralien needs to be set in hardware as well as software
% by using the small switches (see website or user manual).
InputSet.OssilaX200.Smu1.Range = 3;
InputSet.OssilaX200.Smu2.Range = 0;

% Set OSR
% For SMU options 0-9. Higher means more ADC samples, slower measurement.
InputSet.OssilaX200.Smu1.OSR = 4;

% For VS options 0-19. Higher means more ADC samples, slower measurement.
InputSet.OssilaX200.VS2.OSR = 9;
InputSet.OssilaX200.VS1.OSR = 19;

%% Experiment variables

% For back gate voltage 
InputSet.Proc.GateV = 10:1:35;

% For IV curve over top contacts
InputSet.Proc.SourceDrainV = 3;

% Number of B fields plan on running
InputSet.Proc.NumBFields = 5;

% Number of measurements per data point
InputSet.Proc.NumMeasure = 5;

%% Saving
InputSet.Proc.RecsPerRecFile = 2;
InputSet.Proc.RecMatFileNumberLimit = 200;
[InputSet.Proc.SavePath, InputSet.Proc.SaveFileName] = GenerateDataPathAndFileName('../Data/HallMeasure/d2021A_FetTest','_GateSmu1');
InputSet.Proc.SaveList = {...
    'ExperimentStartTime' ...
    'InputSet' ...
    'Proc' ...
    'StartTime' ...
    'SystemSet' ...
    'Tbl1_DataMetrics'};






