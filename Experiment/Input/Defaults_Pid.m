% PID controls
% B0 tolerable magnitude of field error in Tesla
InputSet.Pid.B0Tolerance = 0.002e-3;
% Time for system to dwell on correct field before recording data
InputSet.Pid.DwellTime = 2;
% PI settings
InputSet.Pid.BiasV = 5.535;
InputSet.Pid.UpperApplyVLimit = 10;
InputSet.Pid.LowerApplyVLimit = 0;
InputSet.Pid.Kc = -140;
InputSet.Pid.Ti = 1.1;
InputSet.Pid.AdjPause = 0.2;
InputSet.Pid.MaxVJump = 1;

InputSet.Pid.LivePlot = 0;
InputSet.Pid.UpdateBiasV = 1;

InputSet.Pid.PlotLookBack = 10;