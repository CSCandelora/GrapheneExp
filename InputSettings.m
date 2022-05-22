 % =========================================================================
% InputSettings.m
%
% Author: 	Ethan Williams
%
% About:
% Choose input values, parameters, etc.
% =========================================================================

%% Debug mode
% Enter 0 for actual experiment with instruments
% Enter 1 to use debug mode, bypasses instrument commands in supporting
% scripts.
% Enter 2 to test only microwave setup. Bypasses magnetic field control and
% detection steps and instruments.
InputSet.DebugMode = 0;

% =========================================================================
%% Procedure Script
% Give the string that is the name of the procedure script you wish to run.
% This has been changed to an input for redundancy and instrument safety.
InputSet.ProcedureScript = input('Enter name of procedure script to run: ','s');
disp(['Procedure script: ' InputSet.ProcedureScript])

% Execute the input script corresponding to the selected procedure script.
% IMPORTANT: This should result in creation of a InputSet.InstInUse struct
eval(['Input_' InputSet.ProcedureScript]);

% Load system settings designated in ProcedureScript.
if isfield(InputSet,'System')
    eval(['SystemSettings_' InputSet.System]);
end

% =========================================================================
%% Designate GPIB Addresses
% Organize which GPIB addresses will be used for which instruments.
% Generally no one will need to alter this.
% Even if an instrument is not in use, it can be left in the index.
InputSet.GpibAddresses = cell(24,1);
% Assign instrument names to addresses.
InputSet.GpibAddresses(1) = {'TekAwg7052'};
InputSet.GpibAddresses(3) = {'TekAwg520'};
InputSet.GpibAddresses(10) = {'Keithley236'};
InputSet.GpibAddresses(12) = {'Lakeshore475'}; % Note: address 12 hardcoded in Initialize_Lakeshore475 with IEEE command...? Fix?
InputSet.GpibAddresses(14) = {'Egg7260'};
InputSet.GpibAddresses(17) = {'Agilent8648c'};
InputSet.GpibAddresses(22) = {'Keithley2400Lv'};
InputSet.GpibAddresses(23) = {'Keithley2400'};

% =========================================================================
%% Load PID defaults
if any(strcmp('Keithley236',InputSet.InstInUse)) && ...
        strcmp('Pid',InputSet.Keithley236.Mode)
    Defaults_Pid
end

%% Load default settings for instruments
% These scripts contain the programmed default settings for the instruments
% in the lab. Change the defaults programmatically so that they
% will depend on the ProcedureScript to be executed. Find them in
% InstrumentSettings/
for m_Inst = 1:length(InputSet.InstInUse)
    eval(['PrgDefault_' InputSet.InstInUse{m_Inst}])
end
clear m_Inst


% =========================================================================
disp('Input settings loaded.')