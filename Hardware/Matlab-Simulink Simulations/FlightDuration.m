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

upper_threshold = 100;
upper_indeces = throttle <= upper_threshold;

throttle = throttle(upper_indeces);
pwr = pwr(upper_indeces);
thrust = thrust(upper_indeces);

lower_threshold = 20;
lower_indeces = throttle > lower_threshold;

throttle = throttle(lower_indeces);
pwr = pwr(lower_indeces);
thrust = thrust(lower_indeces);
    
% Define custom model, e.g., exponential model: thrust = a * exp(b * throttle)
[throttle_thrust, gof_tht] = fit(throttle, thrust, 'poly3');
[throttle_power, gof_thp] = fit(throttle, pwr, 'poly3');
[thrust_power, gof_tp] = fit(thrust, pwr, 'poly2');
% gof_thp
% gof_tp
% gof_tht
% Plot data and fit

usable_battery_watthr = 100; % placeholder
flight_duration_data = usable_battery_watthr ./ pwr;
% Define the custom fit type as 1 / (a*x + b)
fitType = fittype('1 / (a * x + b)', 'independent', 'x', 'coefficients', {'a', 'b'});

% Fit the data
[flight_duration, gof_fd] = fit(throttle, flight_duration_data, fitType);
gof_fd

figure;
plot(flight_duration, throttle, flight_duration_data);
% plot(throttle_power, throttle, pwr);
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

