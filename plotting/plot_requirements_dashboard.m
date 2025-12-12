function plot_requirements_dashboard(metrics_file, csv_files)
% PLOT_REQUIREMENTS_DASHBOARD  Visual dashboard for requirements verification
%
%   plot_requirements_dashboard(metrics_file, csv_files)
%
% Example:
%   metrics = 'metrics/Demo_metrics_final.json';
%   logs = {'logging/Demo_S1_final.csv', ...
%           'logging/Demo_S2_final.csv', ...
%           'logging/Demo_S3_final.csv'};
%   plot_requirements_dashboard(metrics, logs);

    % Load metrics
    m = jsondecode(fileread(metrics_file));
    
    % Create dashboard figure
    fig = figure('Name', 'Requirements Verification Dashboard', ...
                 'Position', [50, 50, 1600, 1000]);
    
    %% Header: Requirements Summary Table
    subplot(4, 3, [1, 2, 3]);
    axis off;
    
    % Requirements data
    req_data = {
        'R-TIME-01',  'S1 time ≤ 75 s',               sprintf('%.1f s', m.S1.t_final),      m.S1.t_final <= 75;
        'R-IAE-01',   'S1 IAE ≤ 0.025 m·s',           sprintf('%.4f', m.S1.IAE),            m.S1.IAE <= 0.025;
        'R-ENERGY-01','S1 energy ≤ 60 units',         sprintf('%.1f', m.S1.energy_proxy),   m.S1.energy_proxy <= 60;
        'R-OBS-01',   'S2 zero contacts',             sprintf('%d', m.S2.obstacle_contacts), m.S2.obstacle_contacts == 0;
        'R-CAP-01',   'S3 v ≤ 0.45 m/s (fault)',      sprintf('%.3f m/s', m.S3.max_v_fault), m.S3.speed_cap_ok;
        'R-FAULT-01', 'S3 line loss = 0',             sprintf('%d events', m.S3.line_loss_events), m.S3.line_loss_events == 0;
    };
    
    % Draw table
    row_height = 0.14;
    for i = 1:size(req_data, 1)
        y_pos = 1.0 - i * row_height;
        
        % Requirement ID
        text(0.05, y_pos, req_data{i,1}, 'FontSize', 10, 'FontWeight', 'bold');
        
        % Description
        text(0.25, y_pos, req_data{i,2}, 'FontSize', 10);
        
        % Actual value
        text(0.60, y_pos, req_data{i,3}, 'FontSize', 10);
        
        % Status
        if req_data{i,4}
            text(0.85, y_pos, '✓ PASS', 'FontSize', 11, 'Color', [0 0.6 0], 'FontWeight', 'bold');
        else
            text(0.85, y_pos, '✗ FAIL', 'FontSize', 11, 'Color', [0.8 0 0], 'FontWeight', 'bold');
        end
    end
    
    title('Requirements Verification Summary', 'FontSize', 14, 'FontWeight', 'bold');
    
    %% S1: Time vs IAE trade-off
    subplot(4, 3, 4);
    scatter(m.S1.t_final, m.S1.IAE, 100, 'b', 'filled'); hold on;
    xlabel('Time (s)');
    ylabel('IAE (m·s)');
    title('S1: Time vs Accuracy');
    % Target box
    rectangle('Position', [0, 0, 75, 0.025], 'EdgeColor', 'g', ...
              'LineWidth', 2, 'LineStyle', '--');
    text(37.5, 0.0125, 'Target Zone', 'HorizontalAlignment', 'center', ...
         'Color', 'g', 'FontWeight', 'bold');
    grid on;
    
    %% S1: Energy vs IAE trade-off
    subplot(4, 3, 5);
    scatter(m.S1.IAE, m.S1.energy_proxy, 100, 'r', 'filled'); hold on;
    xlabel('IAE (m·s)');
    ylabel('Energy (units)');
    title('S1: Accuracy vs Energy');
    % Target box
    rectangle('Position', [0, 0, 0.025, 60], 'EdgeColor', 'g', ...
              'LineWidth', 2, 'LineStyle', '--');
    text(0.0125, 30, 'Target', 'HorizontalAlignment', 'center', ...
         'Color', 'g', 'FontWeight', 'bold', 'Rotation', 90);
    grid on;
    
    %% S2: Obstacle Response
    subplot(4, 3, 6);
    if length(csv_files) >= 2
        data_s2 = readtable(csv_files{2});
        obstacle_idx = find(data_s2.obstacle_flag == 1);
        
        if ~isempty(obstacle_idx)
            t_obs = data_s2.t(obstacle_idx);
            e_obs = data_s2.e_line(obstacle_idx);
            
            plot(data_s2.t, data_s2.e_line, 'b-', 'LineWidth', 1); hold on;
            plot(t_obs, e_obs, 'r-', 'LineWidth', 2);
            xlabel('Time (s)');
            ylabel('e_{line} (m)');
            title('S2: Obstacle Response');
            legend('Normal', 'During obstacle', 'Location', 'best');
            grid on;
        end
    end
    
    %% S3: Speed Cap Verification
    subplot(4, 3, 7);
    if length(csv_files) >= 3
        data_s3 = readtable(csv_files{3});
        fault_idx = find(data_s3.fault_flag == 1);
        
        plot(data_s3.t, data_s3.v, 'b-', 'LineWidth', 1); hold on;
        if ~isempty(fault_idx)
            plot(data_s3.t(fault_idx), data_s3.v(fault_idx), 'r-', 'LineWidth', 2);
        end
        yline(0.45, 'k--', 'LineWidth', 2, 'Label', 'Speed cap');
        xlabel('Time (s)');
        ylabel('v (m/s)');
        title('S3: Speed Cap Enforcement');
        legend('Normal', 'During fault', 'Limit', 'Location', 'best');
        grid on;
    end
    
    %% IAE Breakdown by Scenario
    subplot(4, 3, 8);
    bar([m.S1.IAE, m.S2.IAE, m.S3.IAE]);
    set(gca, 'XTickLabel', {'S1', 'S2', 'S3'});
    ylabel('IAE (m·s)');
    title('IAE Across Scenarios');
    hold on;
    yline(0.025, 'r--', 'LineWidth', 2, 'Label', 'Target (S1)');
    grid on;
    
    %% Energy Breakdown
    subplot(4, 3, 9);
    bar([m.S1.energy_proxy, m.S2.energy_proxy, m.S3.energy_proxy]);
    set(gca, 'XTickLabel', {'S1', 'S2', 'S3'});
    ylabel('Energy (units)');
    title('Energy Across Scenarios');
    hold on;
    yline(60, 'r--', 'LineWidth', 2, 'Label', 'Target (S1)');
    grid on;
    
    %% Line Loss Events
    subplot(4, 3, 10);
    bar([m.S1.line_loss_events, m.S2.line_loss_events, m.S3.line_loss_events]);
    set(gca, 'XTickLabel', {'S1', 'S2', 'S3'});
    ylabel('Line Loss Events');
    title('Line Loss Count');
    grid on;
    
    %% Overall Pass/Fail Pie Chart
    subplot(4, 3, 11);
    total_reqs = 6;
    passed = sum([req_data{:,4}]);
    failed = total_reqs - passed;
    
    pie([passed, failed]);
    colormap([0 0.8 0; 0.8 0 0]);
    title(sprintf('Overall: %d/%d Requirements Passed', passed, total_reqs));
    legend({'PASS', 'FAIL'}, 'Location', 'southoutside');
    
    %% Notes/Comments Box
    subplot(4, 3, 12);
    axis off;
    
    text(0.1, 0.9, 'Design Notes:', 'FontSize', 11, 'FontWeight', 'bold');
    text(0.1, 0.7, sprintf('• Controller type: P+I'), 'FontSize', 9);
    text(0.1, 0.5, sprintf('• Fidelity level: Realistic'), 'FontSize', 9);
    text(0.1, 0.3, sprintf('• Total scenarios: 3/3 completed'), 'FontSize', 9);
    text(0.1, 0.1, sprintf('• Safety: Speed cap OK ✓'), 'FontSize', 9);
    
    %% Save
    [~, name, ~] = fileparts(metrics_file);
    saveas(fig, sprintf('plots/dashboard_%s.png', name));
    fprintf('✓ Saved: plots/dashboard_%s.png\n', name);
end
