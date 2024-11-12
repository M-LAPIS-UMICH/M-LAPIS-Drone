% Replace 'filename.csv' with the path to your CSV file
data = readtable('Log_2024-11-08_185205.csv');

% Extract the throttle and thrust data from the table
throttle = (data.ESCSignal__s_ - 1000) ./ 10;  % Adjust if the column name differs
thrust = -1 .* data.Thrust_kgf_;      % Adjust if the column name differs
pwr = data.ElectricalPower_W_;

% Find the index of the first NaN in throttle
nanIndex = find(isnan(throttle), 1);

% If there's a NaN, truncate throttle and thrust at the first NaN
if ~isempty(nanIndex)
    throttle = throttle(1:nanIndex-1);
    thrust = thrust(1:nanIndex-1);
    pwr = pwr(1:nanIndex-1);
end

threshold = 100;
indeces = throttle <= threshold;

throttle = throttle(indeces);
pwr = pwr(indeces);
thrust = thrust(indeces);
    
% Define custom model, e.g., exponential model: thrust = a * exp(b * throttle)
[throttle_thrust, gof_tht] = fit(throttle, thrust, 'poly3');
[throttle_power, gof_thp] = fit(throttle, pwr, 'poly3');
[thrust_power, gof_tp] = fit(thrust, pwr, 'poly2');
gof_thp
% gof_tp
% gof_tht
% Plot data and fit
figure;
plot(throttle_power, throttle, pwr);
xlabel('Throttle (%)');
ylabel('Thrust (N)');
title('Throttle vs. Thrust with Fit');
grid on;

save('throttle-thrust_fun', "throttle_thrust", "throttle_power", "thrust_power")

% % Plotting throttle vs thrust
% figure;
% plot(throttle, thrust, '-o', 'LineWidth', 1.5);
% xlabel('Throttle (%)');
% ylabel('Thrust (kgf)');
% title('Throttle vs. Thrust');
% grid on; 

