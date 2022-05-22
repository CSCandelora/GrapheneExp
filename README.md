# GrapheneExp
Code for MATLAB instrument control for resistive characterization of graphene field effect transistors for Sekhar Ramanathan's lab at Dartmouth College.

First, 'Main.m' is run. It prompts user to write name of Procedure script ('eTransport_GateSmu1', 'HallMeasure', 'SpinRes', etc.)

Then, the 'InputSettings' script is called. This calls the input settings of the desired procedure (ex. 'Input_eTransport_GateSmu1.m', 'Input_HallMeasure.m', 'Input_SpinRes.m', etc.). In this script values such as gate voltage as well as source drain voltage. It also sets up the 
