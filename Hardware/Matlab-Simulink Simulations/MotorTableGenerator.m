
% Specify the folder containing the files
folderPath = 'C:\Users\gabri\Desktop\M-LAPIS\M-LAPIS\Hardware\Matlab-Simulink Simulations\COMPLETE DATA!!';

% Get a list of all .txt files in the folder
fileList = dir(fullfile(folderPath, '*.csv'));
data = readtable('C:\Users\gabri\Desktop\M-LAPIS\M-LAPIS\Hardware\Matlab-Simulink Simulations\COMPLETE DATA!!\Light Drone.csv');

for k = 1:length(fileList)
    % Get the file name
    filePath = strcat(fileList(k).folder, '\', fileList(k).name);
    display(filePath)
    filename = regexp(fileList(k).name, '^[^.]+', 'match', 'once'); % Extract part before first '.'
    FlightFun(filePath, filename)

    mat = load(fullfile(filename, strcat(filename, ".mat")));
    final_table = [50 65 75 85 100];
    current = [];
    power = [];
    mthrust = [];
    %mRPM = [];
    mefficiency = [];
    mvoltage = [];
    for v = 1:5
        current = [current mat.throttle_current(final_table(v))];
        power = [power mat.throttle_power(final_table(v))];
        mthrust = [mthrust mat.throttle_thrust(final_table(v))];
        %mRPM = [mRPM mat.throttle_RPM(final_table(v))];
        mefficiency = [mefficiency mat.throttle_efficiency(final_table(v))];
        mvoltage = [mvoltage mat.throttle_voltage(final_table(v))];
    end
    final_table = [final_table; mvoltage; current; power; mthrust; mefficiency;];
    final_table = final_table'

    columnNames = {'Throttle (%)','Voltage (V)', 'Current (A)', 'Power (W)', 'Thrust (kgf)', 'efficiency'}; % Example column headers
    final_table = array2table(final_table, 'VariableNames',columnNames)
    fig = uifigure('Visible','off');
    %create a uitable
    uit = uitable(fig, "Data",final_table);
uit.Position(3) = fig.Position(3) - 80;
uit.Position(4) = fig.Position(4) - 80;
    % Capture the table window as an image
frame = getframe(fig); % Get the current figure window
imageData = frame2im(frame); % Convert the frame to an image
% Save the image as a PNG file
imwrite(imageData, fullfile(filename, strcat(filename, '.png')));
end
