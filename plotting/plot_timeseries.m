function plot_timeseries(csv_file, scenario_id)
% PLOT_TIMESERIES  Plot key time-series signals from a scenario log
%
%   plot_timeseries(csv_file, scenario_id)
%
% Example:
%   plot_timeseries('logging/Demo_S1_final.csv', 'S1');

    % Load CSV
    data = readtable(csv_file);
    
    % Create figure
    fig = figure('Name', sprintf('Time Series - %s', scenario_id), ...
                 'Position', [100, 100, 1400, 900]);
    
    %% Subplot 1: Lateral Error
    subplot(3, 2, 1);
    plot(data.t, data.e_line, 'b-', 'LineWidth', 1.5);
    ylabel('e_{line} (m)', 'FontSize', 11);
    title('Lateral Error', 'FontWeight', 'bold');
    grid on;
    hold on;
    yline(0.5, 'r--', 'LineWidth', 1, 'Label', 'Line loss threshold');
    yline(-0.5, 'r--', 'LineWidth', 1);
    hold off;
    xlim([0, data.t(end)]);
    
    %% Subplot 2: Control Commands
    subplot(3, 2, 2);
    plot(data.t, data.u_L, 'r-', 'LineWidth', 1.5); hold on;
    plot(data.t, data.u_R, 'b-', 'LineWidth', 1.5);
    ylabel('Command (normalized)', 'FontSize', 11);
    title('Control Commands', 'FontWeight', 'bold');
    legend('u_L', 'u_R', 'Location', 'best');
    grid on;
    ylim([-1.1, 1.1]);
    xlim([0, data.t(end)]);
    
    %% Subplot 3: Velocity
    subplot(3, 2, 3);
    plot(data.t, data.v, 'g-', 'LineWidth', 1.5);
    ylabel('v (m/s)', 'FontSize', 11);
    title('Forward Velocity', 'FontWeight', 'bold');
    grid on;
    
    % Add speed cap line for S3
    if strcmp(scenario_id, 'S3')
        hold on;
        yline(0.45, 'r--', 'LineWidth', 2, 'Label', 'Speed cap (R-CAP-01)');
        
        % Highlight fault window
        fault_idx = find(data.fault_flag == 1);
        if ~isempty(fault_idx)
            t_start = data.t(fault_idx(1));
            t_end = data.t(fault_idx(end));
            xregion(t_start, t_end, 'FaceColor', 'r', 'FaceAlpha', 0.1);
        end
        hold off;
    end
    xlim([0, data.t(end)]);
    
    %% Subplot 4: Sensor Readings
    subplot(3, 2, 4);
    plot(data.t, data.sensor_1, 'LineWidth', 1); hold on;
    plot(data.t, data.sensor_2, 'LineWidth', 1);
    plot(data.t, data.sensor_3, 'LineWidth', 1.5);
    plot(data.t, data.sensor_4, 'LineWidth', 1);
    plot(data.t, data.sensor_5, 'LineWidth', 1);
    ylabel('Sensor Value', 'FontSize', 11);
    title('Sensor Array Readings', 'FontWeight', 'bold');
    legend({'S1 (-40mm)', 'S2 (-20mm)', 'S3 (0mm)', 'S4 (+20mm)', 'S5 (+40mm)'}, ...
           'Location', 'best', 'FontSize', 8);
    grid on;
    xlim([0, data.t(end)]);
    ylim([0, 1.1]);
    
    %% Subplot 5: Trajectory (X-Y plot)
    subplot(3, 2, 5);
    plot(data.x, data.y, 'b-', 'LineWidth', 1.5); hold on;
    plot(data.x, zeros(size(data.x)), 'k--', 'LineWidth', 1, 'DisplayName', 'Target line');
    xlabel('X Position (m)', 'FontSize', 11);
    ylabel('Y Position (m)', 'FontSize', 11);
    title('Robot Trajectory', 'FontWeight', 'bold');
    legend('Actual path', 'Target line', 'Location', 'best');
    grid on;
    axis equal;
    
    %% Subplot 6: Flags and Events
    subplot(3, 2, 6);
    plot(data.t, data.line_loss_flag, 'r-', 'LineWidth', 2); hold on;
    plot(data.t, data.obstacle_flag, 'k-', 'LineWidth', 2);
    plot(data.t, data.fault_flag, 'm-', 'LineWidth', 2);
    xlabel('Time (s)', 'FontSize', 11);
    ylabel('Flag State', 'FontSize', 11);
    title('Event Flags', 'FontWeight', 'bold');
    legend('Line Loss', 'Obstacle', 'Fault', 'Location', 'best');
    grid on;
    ylim([-0.1, 1.2]);
    xlim([0, data.t(end)]);
    
    %% Overall title
    sgtitle(sprintf('Time-Series Analysis - %s (%s)', ...
            data.run_id{1}, scenario_id), 'FontSize', 14, 'FontWeight', 'bold');
    
    %% Save
    [~, name, ~] = fileparts(csv_file);
    saveas(fig, sprintf('plots/timeseries_%s.png', name));
    fprintf('✓ Saved: plots/timeseries_%s.png\n', name);
end
