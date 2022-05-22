%% Purpose
%
%The purpose of this code is to supply all the input information necessary
%to run the eTransport Procedure, including instrument values, source drain
%values, and gate voltage values.
%
%Author: Ethan Williams and Chris Candelora

%% Instrumentation settings
% Indicate experimental system settings file handle string
InputSet.System = 'eTransport';
%
% Specify the instruments used in this experiment
InputSet.InstInUse = {...
    'OssilaX200' ...
    'Keithley2400'};

InputSet.Keithley2400.Mode = 'GateV';
InputSet.Keithley2400.LimitI = 0.1;
InputSet.Keithley2400.SrcDelayInS = 1;
InputSet.Keithley2400.OnboardAvgNumPts = 10;

InputSet.OssilaX200.Smu1.Active = 1;
InputSet.OssilaX200.Smu2.Active = 0;
InputSet.OssilaX200.VS1.Active = 0;
InputSet.OssilaX200.VS2.Active = 0;
%first of all let specify what measurement range we're using.
%Range 	Max Current 	Accuracy
%1      100 mA          10 µA
%2      10 mA           1 µA
%3      1 mA            100 nA
%4      100 µA          10 nA
%5      10 µA           1 nA
%IMPORTANT NOTE:
%The range on the Xtralien needs to be set in hardware as well as software
%by using the small switches (see website or user manual).
InputSet.OssilaX200.Smu1.Range = 3;
InputSet.OssilaX200.Smu1.OSR = 4; % options 0-9. Higher means more ADC samples, slower measurement.

InputSet.OssilaX200.VS2.OSR = 9;   %options 0-19. Higher means more samples, slower measurement

%% Experiment variables
% For back gate voltage 
InputSet.Proc.GateV = 15:0.5:30;
% For IV curve over top contacts
InputSet.Proc.SourceDrainV = -0.2:0.02:0.2;

%% Saving
InputSet.Proc.RecsPerRecFile = 2;
InputSet.Proc.RecMatFileNumberLimit = 200;
[InputSet.Proc.SavePath, InputSet.Proc.SaveFileName] = GenerateDataPathAndFileName('../Data/eTransport/d2021A_FetTest','_GateSmu1');
InputSet.Proc.SaveList = {...
    'ExperimentStartTime' ...
    'InputSet' ...
    'Proc' ...
    'StartTime' ...
    'SystemSet' ...
    'Tbl1_DataMetrics'};
