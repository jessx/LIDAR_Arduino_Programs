% -------------------------------------------------------------------
%  Generated by MATLAB on 27-Aug-2015 14:19:13
%  MATLAB version: 8.3.0.532 (R2014a)
% -------------------------------------------------------------------
                                             

fuzzyBikeSug01 = struct;
fuzzyBikeSug01.name = 'fuzzyBikeSug01';
fuzzyBikeSug01.type = 'sugeno';
fuzzyBikeSug01.andMethod = 'min';
fuzzyBikeSug01.orMethod = 'max';
fuzzyBikeSug01.defuzzMethod = 'wtaver';
fuzzyBikeSug01.impMethod = 'min';
fuzzyBikeSug01.aggMethod = 'max';
fuzzyBikeSug01.input = struct;
fuzzyBikeSug01.input(1).name = 'Velocity(m/s)';
fuzzyBikeSug01.input(1).range = [0 12];
fuzzyBikeSug01.input(1).mf = struct;
fuzzyBikeSug01.input(1).mf(1).name = 'Slow';
fuzzyBikeSug01.input(1).mf(1).type = 'gaussmf';
fuzzyBikeSug01.input(1).mf(1).params = ...
  [2.5 0];
fuzzyBikeSug01.input(1).mf(2).name = 'Med';
fuzzyBikeSug01.input(1).mf(2).type = 'gaussmf';
fuzzyBikeSug01.input(1).mf(2).params = ...
  [2.5 6];
fuzzyBikeSug01.input(1).mf(3).name = 'Fast';
fuzzyBikeSug01.input(1).mf(3).type = 'gaussmf';
fuzzyBikeSug01.input(1).mf(3).params = ...
  [2.5 12];
fuzzyBikeSug01.input(2).name = 'Distance(m)';
fuzzyBikeSug01.input(2).range = [0 40];
fuzzyBikeSug01.input(2).mf = struct;
fuzzyBikeSug01.input(2).mf(1).name = 'Close';
fuzzyBikeSug01.input(2).mf(1).type = 'gaussmf';
fuzzyBikeSug01.input(2).mf(1).params = ...
  [8.5 0];
fuzzyBikeSug01.input(2).mf(2).name = 'Med';
fuzzyBikeSug01.input(2).mf(2).type = 'gaussmf';
fuzzyBikeSug01.input(2).mf(2).params = ...
  [8.5 20];
fuzzyBikeSug01.input(2).mf(3).name = 'Far';
fuzzyBikeSug01.input(2).mf(3).type = 'gaussmf';
fuzzyBikeSug01.input(2).mf(3).params = ...
  [8.5 40];
fuzzyBikeSug01.output = struct;
fuzzyBikeSug01.output.name = 'PWM(%)';
fuzzyBikeSug01.output.range = [0 1];
fuzzyBikeSug01.output.mf = struct;
fuzzyBikeSug01.output.mf(1).name = 'Low';
fuzzyBikeSug01.output.mf(1).type = 'linear';
fuzzyBikeSug01.output.mf(1).params = ...
  [0 0 0];
fuzzyBikeSug01.output.mf(2).name = 'Med';
fuzzyBikeSug01.output.mf(2).type = 'linear';
fuzzyBikeSug01.output.mf(2).params = ...
  [0 0 0.49999999999999983];
fuzzyBikeSug01.output.mf(3).name = 'High';
fuzzyBikeSug01.output.mf(3).type = 'linear';
fuzzyBikeSug01.output.mf(3).params = ...
  [0 0 1];
fuzzyBikeSug01.rule = struct;
fuzzyBikeSug01.rule(1).antecedent = ...
  [1 1];
fuzzyBikeSug01.rule(1).consequent = 2;
fuzzyBikeSug01.rule(1).weight = 1;
fuzzyBikeSug01.rule(1).connection = 1;
fuzzyBikeSug01.rule(2).antecedent = ...
  [1 2];
fuzzyBikeSug01.rule(2).consequent = 1;
fuzzyBikeSug01.rule(2).weight = 1;
fuzzyBikeSug01.rule(2).connection = 1;
fuzzyBikeSug01.rule(3).antecedent = ...
  [1 3];
fuzzyBikeSug01.rule(3).consequent = 1;
fuzzyBikeSug01.rule(3).weight = 1;
fuzzyBikeSug01.rule(3).connection = 1;
fuzzyBikeSug01.rule(4).antecedent = ...
  [2 1];
fuzzyBikeSug01.rule(4).consequent = 3;
fuzzyBikeSug01.rule(4).weight = 1;
fuzzyBikeSug01.rule(4).connection = 1;
fuzzyBikeSug01.rule(5).antecedent = ...
  [2 2];
fuzzyBikeSug01.rule(5).consequent = 2;
fuzzyBikeSug01.rule(5).weight = 1;
fuzzyBikeSug01.rule(5).connection = 1;
fuzzyBikeSug01.rule(6).antecedent = ...
  [2 3];
fuzzyBikeSug01.rule(6).consequent = 1;
fuzzyBikeSug01.rule(6).weight = 1;
fuzzyBikeSug01.rule(6).connection = 1;
fuzzyBikeSug01.rule(7).antecedent = ...
  [3 1];
fuzzyBikeSug01.rule(7).consequent = 3;
fuzzyBikeSug01.rule(7).weight = 1;
fuzzyBikeSug01.rule(7).connection = 1;
fuzzyBikeSug01.rule(8).antecedent = ...
  [3 2];
fuzzyBikeSug01.rule(8).consequent = 3;
fuzzyBikeSug01.rule(8).weight = 1;
fuzzyBikeSug01.rule(8).connection = 1;
fuzzyBikeSug01.rule(9).antecedent = ...
  [3 3];
fuzzyBikeSug01.rule(9).consequent = 2;
fuzzyBikeSug01.rule(9).weight = 1;
fuzzyBikeSug01.rule(9).connection = 1;

