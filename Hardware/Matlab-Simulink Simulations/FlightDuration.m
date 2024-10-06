function overall_voltage = batt_voltage(voltage_per_cell, no_cells)
overall_voltage = voltage_per_cell * no_cells;
end

function flight_duration_50 = flighttime(voltage, amphours, power_consumed_50, ...
    no_motors, battery_max_usage, motor_allocation)
watthr = voltage * amphours;
usable_watthr = (battery_max_usage * watthr);
watthr_alloc_motor = usable_watthr * motor_allocation;
tot_pwr_consumed = no_motors * power_consumed_50;

flight_duration_50 = watthr_alloc_motor / tot_pwr_consumed;
end