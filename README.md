# GrapheneExp
Code for MATLAB instrument control for resistive characterization of graphene field effect transistors for Sekhar Ramanathan's lab at Dartmouth College.

First, 'Main.m' is run. It prompts user to write name of Procedure script ('eTransport_GateSmu1', 'HallMeasure', 'SpinRes', etc.)

Then, the 'InputSettings' script is called. First, input settings calls 'GenerateDataPathandFileName.m' where one could designate the name of the save file. See note in the bottom about naming files. This calls the input settings of the desired procedure (ex. 'Input_eTransport_GateSmu1.m', 'Input_HallMeasure.m', 'Input_SpinRes.m', etc.). In this script values such as gate voltage as well as source drain voltage. It also turns on and connects to the insturments. After this, each respective 'SystemSettings' script is called by 'InputSettings.' In 'SystemSettings, the COM ports of each instrument are defined. Then, 'InputSettings' designates the GPIB connections for each instrument.

After this the experiment script is run ('eTransport_GateSmu1.m', 'HallMeasure.m', etc.). Each script has its own unique procedure with expected outcomes, all of which are commented out on the top of each script.

That ends the 'Main' script.

-------
After data is collected they are stored in a 'Data' folder with each procedure having its own unique folder. Within each of these folders is a script to plot the results. For 'eTransport_GateSmu1.m' the script for plotting is 'PlotDat.m', for 'HallMeasure.m' the script for plotting is 'PlotDatVH.m', and for 'SpinRes.m' the script for plotting is 'PlotDatSpin.m'. In this script it promts the user to enter the test number. For all procedures, the test number must be between 1 and 99. If it is above this threshold, data must allocated to a different part of the computer so that one could start agian at 1. For all eTransport_GateSmu1, the file name must terminate with 'GFETtest##' so that the proper file is called in the plotting data. For 'HallMeasure', it must terminate with 'GFETHMtest##'. For 'SpinRes', it must terminate with 'GFETSRtest##'. Note that when running 'HallMeasure.m' you must also run a 'eTransport_GateSmu1.m' prior to this with identical gate voltages. This is because in order to calculate mobility one needs a resistance characterization also. So, 'PlotDat.m' will also output a file titled 'test##Hall' which includes values for the resistance that will get called by 'PlotDatVH.m' There are sample values in the 'Data' folder.
