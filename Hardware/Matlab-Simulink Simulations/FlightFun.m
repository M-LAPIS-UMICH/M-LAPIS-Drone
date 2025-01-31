function [outputArg1] = FlightFun(inputArg1, filename)
% Replace 'filename.csv' with the path to your CSV file
%data = readtable('Heavy Drone.csv'); 
data = readtable(inputArg1);
% Extract the throttle and thrust data from the table
%display(data.ESCSignal__s_ - max(data.ESCSignal__s_))
throttle = (data.ESCSignal__s_ - min(data.ESCSignal__s_)) ./ 10;  % Adjust if the column name differs
throttle_norm = @(x) (100/max(throttle))*x;
throttle = throttle_norm(throttle);
%display(data.Thrust_kgf_)
thrust = data.Thrust_kgf_(:);      % Adjust if the column name differs

%display(thrust)
pwr = data.ElectricalPower_W_;
efficiency = data.MotorEfficiency___;
current_draw = data.Current_A_;
RPM = data.MotorElectricalSpeed_RPM_;
voltage = data.Voltage_V_;

% Find the index of the first NaN in throttle
nanIndex = find(isnan(throttle), 1);
%dsplay(throttle)
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
efficiency = efficiency(upper_indeces);
current_draw = current_draw(upper_indeces);
RPM = RPM(upper_indeces);
voltage = voltage(upper_indeces);

lower_threshold = 20;
lower_indeces = throttle > lower_threshold;

throttle = throttle(lower_indeces);
pwr = pwr(lower_indeces);
thrust = thrust(lower_indeces);
efficiency = efficiency(lower_indeces);
current_draw = current_draw(lower_indeces);
RPM = RPM(lower_indeces);
voltage = voltage(lower_indeces);
    
% Define custom model, e.g., exponential model: thrust = a * exp(b * throttle)
%display(thrust)

[throttle_thrust, gof_tht] = fit(throttle, thrust, 'poly3');
[throttle_power, gof_thp] = fit(throttle, pwr, 'poly3');
[throttle_current, gof_thc] = fit(throttle, current_draw, 'poly3');
[throttle_RPM, gof_thrpm] = fit(throttle, RPM, 'poly3');
[throttle_efficiency, gof_the] = fit(throttle, efficiency, 'poly3');
[throttle_voltage, gof_thv] = fit(throttle, voltage, 'poly1');

[thrust_current, gof_tc] = fit(thrust, current_draw, 'poly3');
[thrust_RPM, gof_trpm] = fit(thrust, RPM, 'poly3');
[thrust_power, gof_tp] = fit(thrust, pwr, 'poly2');
[thrust_efficiency, gof_te] = fit(thrust, efficiency, 'poly3');
%gof_tc
%gof_trpm
%gof_tp
%gof_te
% gof_thp
% gof_tp
% gof_tht
% Plot data and fit

% usable_battery_watthr = 202; % placeholder
% flight_duration_data = 60 .* (usable_battery_watthr ./ pwr);
% % Define the custom fit type as 1 / (a*x + b)
% fitType = fittype('1 / (a * x + b)', 'independent', 'x', 'coefficients', {'a', 'b'});
% 
% % Fit the data
% [flight_duration, gof_fd] = fit(throttle, flight_duration_data, fitType);
% gof_thc

%figure;
% plot(flight_duration, throttle, flight_duration_data);
% plot(thrust_power, thrust, pwr);
%plot(throttle_thrust, throttle, thrust);
% plot(thrust_efficiency, thrust, efficiency);
%plot(throttle_current, throttle, current_draw);

%xlabel('Throttle (%)');
%ylabel('Flight Duration (min)');
%title('Throttle vs. Flight Duration with Fit');
%grid on;

duration_thrust = @(battery_capacity, no_motors, drone_weight) battery_capacity / (no_motors*thrust_power(drone_weight/no_motors));

slv = @(battery_capacity, no_motors, duration, x) duration_thrust(battery_capacity, no_motors, x) - duration;

inv_duration_thrust = @(battery_capacity, no_motors, duration) fzero(@(x) (duration_thrust(battery_capacity, no_motors, x) - duration), 0)

save(strcat(filename, '.mat'), "throttle_thrust", "throttle_power", ...
    "thrust_power", "throttle_current", "throttle_efficiency", "throttle_RPM", ...
    "thrust_current", "thrust_efficiency", "thrust_RPM", "throttle_voltage", "duration_thrust", "inv_duration_thrust")

% % Plotting throttle vs thrust
% figure;
% plot(throttle, thrust, '-o', 'LineWidth', 1.5);
% xlabel('Throttle (%)');
% ylabel('Thrust (kgf)');
% title('Throttle vs. Thrust');
% grid on;

end

