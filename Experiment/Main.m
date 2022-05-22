% =========================================================================
% Main.m
%
% Author: 	Ethan Williams
%
% About:
% This is the Main file for Experiments1516.
% Run this script to perform an experiment. This script calls out to other
% scripts to carry out the complete experiment.
% =========================================================================

%% Clear everything.
% clear command line
clc;
% clear all objects
clearvars;
clear global
clear mex
% close all figures
close all;
% disconnect and delete all instrument objects
instrreset;

%% Start program
% Time at start of experiment
ExperimentStartTime = datetime('now');
% start timer
tic
% Check current working directory
Dir = pwd;
if ~(strcmp(Dir(end-26:end),'\experiments1516\Experiment') || ...
        strcmp(Dir(end-26:end),'/experiments1516/Experiment'))
    error('You are in the wrong directory. Navigate to ''...\experiments1516\Experiment''')
end
clear Dir
% Add subdirectories to path.
addpath(...
    genpath('Input'),...
    genpath('InstrumentControl'),...
    genpath('Procedures'),...
    genpath('Utilities')...
    );
UpdateMainStatus('Program Start')
% Record start time
StartTime = datetime('now');
disp([' Current time: ' datestr(StartTime)])

%% Get input settings.
UpdateMainStatus('InputSettings')
InputSettings

%% Set up or initialize necessary instrumentation.
% if InputSet.DebugMode == 0
    UpdateMainStatus('InstrumentationSetup')
    InstrumentationSetup
% elseif InputSet.DebugMode == 1
%     UpdateMainStatus('Debug mode: Skip InstrumentationSetup')
%     for i_Adrs=1:length(InputSet.GpibAddresses)
%         % Transfer input instrument struct to new instrument struct.
%         eval(['InstTemp = InputSet.' ...
%             InputSet.GpibAddresses{i_Adrs} ';']);
%     end

%% Run experiment script.
UpdateMainStatus(InputSet.ProcedureScript)
try
    eval(InputSet.ProcedureScript)
catch ME
    warning(['Problem running experiment script. Report: ' ...
        getReport(ME) ' ----- Proceeding anyway.'])
end

%% Disconnect and delete all instrument objects.
% DEPRECATED. This was a messy way of shutting down. Of course, programs
% often run until the operator manually shuts down the program. All
% shutdown procedures should be included in the last section of the
% procedure script.
% UpdateMainStatus('InstrumentationShutdown')
% InstrumentationShutdown
% instrreset;

%% End program.
% Clear variables
clear MainStatus ME

% =========================================================================
toc
UpdateMainStatus('Program complete.')
% =========================================================================