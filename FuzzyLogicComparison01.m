close all; clear all; clc;
% Fuzzy System:
tskFuzzy = struct;
tskFuzzy.name = 'tskFuzzy';
tskFuzzy.type = 'sugeno';
tskFuzzy.andMethod = 'min';
tskFuzzy.orMethod = 'max';
tskFuzzy.defuzzMethod = 'wtaver';
tskFuzzy.impMethod = 'prod';
tskFuzzy.aggMethod = 'sum';
tskFuzzy.input = struct;
tskFuzzy.input(1).name = 'Velocity(m/s)';
tskFuzzy.input(1).range = [0 10];
tskFuzzy.input(1).mf = struct;
tskFuzzy.input(1).mf(1).name = 'Slow';
tskFuzzy.input(1).mf(1).type = 'gaussmf';
tskFuzzy.input(1).mf(1).params = ...
  [2.8 0];
tskFuzzy.input(1).mf(2).name = 'Med';
tskFuzzy.input(1).mf(2).type = 'gaussmf';
tskFuzzy.input(1).mf(2).params = ...
  [2.8 5];
tskFuzzy.input(1).mf(3).name = 'Fast';
tskFuzzy.input(1).mf(3).type = 'gaussmf';
tskFuzzy.input(1).mf(3).params = ...
  [2.8 10];
tskFuzzy.input(2).name = 'Distance(m)';
tskFuzzy.input(2).range = [0 40];
tskFuzzy.input(2).mf = struct;
tskFuzzy.input(2).mf(1).name = 'Close';
tskFuzzy.input(2).mf(1).type = 'gaussmf';
tskFuzzy.input(2).mf(1).params = ...
  [8.5 0];
tskFuzzy.input(2).mf(2).name = 'Med';
tskFuzzy.input(2).mf(2).type = 'gaussmf';
tskFuzzy.input(2).mf(2).params = ...
  [8.5 20];
tskFuzzy.input(2).mf(3).name = 'Far';
tskFuzzy.input(2).mf(3).type = 'gaussmf';
tskFuzzy.input(2).mf(3).params = ...
  [8.5 40];
tskFuzzy.output = struct;
tskFuzzy.output.name = 'PWM(%)';
tskFuzzy.output.range = [0 1];
tskFuzzy.output.mf = struct;
tskFuzzy.output.mf(1).name = 'Low';
tskFuzzy.output.mf(1).type = 'linear';
tskFuzzy.output.mf(1).params = ...
  [0 0 0];
tskFuzzy.output.mf(2).name = 'Med';
tskFuzzy.output.mf(2).type = 'linear';
tskFuzzy.output.mf(2).params = ...
  [0 0 0.5];
tskFuzzy.output.mf(3).name = 'High';
tskFuzzy.output.mf(3).type = 'linear';
tskFuzzy.output.mf(3).params = ...
  [0 0 1];
tskFuzzy.rule = struct;
tskFuzzy.rule(1).antecedent = ...
  [1 1];
tskFuzzy.rule(1).consequent = 2;
tskFuzzy.rule(1).weight = 1;
tskFuzzy.rule(1).connection = 1;
tskFuzzy.rule(2).antecedent = ...
  [1 2];
tskFuzzy.rule(2).consequent = 1;
tskFuzzy.rule(2).weight = 1;
tskFuzzy.rule(2).connection = 1;
tskFuzzy.rule(3).antecedent = ...
  [1 3];
tskFuzzy.rule(3).consequent = 1;
tskFuzzy.rule(3).weight = 1;
tskFuzzy.rule(3).connection = 1;
tskFuzzy.rule(4).antecedent = ...
  [2 1];
tskFuzzy.rule(4).consequent = 3;
tskFuzzy.rule(4).weight = 1;
tskFuzzy.rule(4).connection = 1;
tskFuzzy.rule(5).antecedent = ...
  [2 2];
tskFuzzy.rule(5).consequent = 2;
tskFuzzy.rule(5).weight = 1;
tskFuzzy.rule(5).connection = 1;
tskFuzzy.rule(6).antecedent = ...
  [2 3];
tskFuzzy.rule(6).consequent = 1;
tskFuzzy.rule(6).weight = 1;
tskFuzzy.rule(6).connection = 1;
tskFuzzy.rule(7).antecedent = ...
  [3 1];
tskFuzzy.rule(7).consequent = 3;
tskFuzzy.rule(7).weight = 1;
tskFuzzy.rule(7).connection = 1;
tskFuzzy.rule(8).antecedent = ...
  [3 2];
tskFuzzy.rule(8).consequent = 3;
tskFuzzy.rule(8).weight = 1;
tskFuzzy.rule(8).connection = 1;
tskFuzzy.rule(9).antecedent = ...
  [3 3];
tskFuzzy.rule(9).consequent = 2;
tskFuzzy.rule(9).weight = 1;
tskFuzzy.rule(9).connection = 1;
% End Fuzzy System

d = 0:0.1:40;
v = 0:0.1:10;
[I1,I2] = meshgrid(d,v);
[r,c] = size(I1);
L = r*c;
fxnOut = zeros(r,c);
fuzzOut = zeros(r,c);

for i = 1:L
    i1 = I1(i);
    i2 = I2(i);
    % Sin approximation normalized & multiplied by 255 (PWM):
    f = (((- sin(i1/80*pi)) + (sin(i2/20*pi))) + 1)/2;
    fxnOut(i) = f;
    % Fuzzy logic:
    fuzzOut(i) = evalfis([i2,i1], tskFuzzy);
end
figure;
surfc(I2,I1,fxnOut);
figure;
surfc(I2,I1,fuzzOut);

% Root-Mean-Squared Deviation:
diff = (fxnOut - fuzzOut);
sqrd = diff.^2;
total = sum(sqrd(:));
rmsd = sqrt(total/L);
fprintf('+/- %f %% \n', rmsd/1);


% Plot differences (error):
figure;
surfc(I2,I1,diff);