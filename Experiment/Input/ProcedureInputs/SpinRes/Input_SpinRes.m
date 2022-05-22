%% Purpose
%
%The purpose of this code is to supply all the input information necessary
%to run the SpinRes Procedure, including instrument values, source drain
%values, and gate voltage values. It also prompts the user to calibrate the
%magnet so as to approximate the magnetic field at the test site a bit
%better.
%
%Author: Chris Candelora

%% Instrumentation settings

% Indicate experimental system settings file handle string
InputSet.System = 'SpinRes';

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
InputSet.OssilaX200.VS1.OSR = 9;

% For Gauss Meter, conversion factor from V to mT
InputSet.Proc.VtoTesla = 1/10;

%% Experiment variables

% For back gate voltage (should be fixed value)
InputSet.Proc.GateV = 23.75;

% For IV curve over top contacts (should be sweeping)
InputSet.Proc.SourceDrainV = 0.2;

% For number of SD measurements
InputSet.Proc.NumSourceDrainV = 30;

% Number of B fields plan on running
InputSet.Proc.NumBFields = 61;

% Number of frequencies
InputSet.Proc.NumFreq = 2;

%% Saving
InputSet.Proc.RecsPerRecFile = 2;
InputSet.Proc.RecMatFileNumberLimit = 200;
[InputSet.Proc.SavePath, InputSet.Proc.SaveFileName] = GenerateDataPathAndFileName('../Data/SpinRes/d2021A_FetTest','_GateSmu1');
InputSet.Proc.SaveList = {...
    'ExperimentStartTime' ...
    'InputSet' ...
    'Proc' ...
    'StartTime' ...
    'SystemSet' ...
    'Tbl1_DataMetrics'};






