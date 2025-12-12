function plot_metrics_comparison(metrics_files, labels)
% PLOT_METRICS_COMPARISON  Compare metrics across fidelity levels or iterations
%
%   plot_metrics_comparison(metrics_files, labels)
%
% Example:
%   files = {'Demo_metrics_simple.json', 'Demo_metrics_final.json', 'Demo_metrics_hifi.json'};
%   labels = {'Simple', 'Realistic', 'Hi-Fi'};
%   plot_metrics_comparison(files, labels);

    if nargin < 1
        % Default: compare all three fidelity levels
        metrics_files = {
            'metrics/Demo_metrics_simple.json'
            'metrics/Demo_metrics_final.json'
            'metrics/Demo_metrics_hifi.json'
        };
        labels = {'Simple', 'Realistic', 'Hi-Fi'};
    end
    
    n_files = length(metrics_files);
    scenarios = {'S1', 'S2', 'S3'};
    
    % Load all metrics
    data = cell(n_files, 1);
    for i = 1:n_files
        data{i} = jsondecode(fileread(metrics_files{i}));
    end
    
    %% Create figure
    fig = figure('Name', 'MC3113 Metrics Comparison', ...
                 'Position', [100, 100, 1400, 900]);
    
    %% Subplot 1: IAE Comparison
    subplot(2, 3, 1);
    iae_data = zeros(n_files, 3);
    for i = 1:n_files
        for j = 1:3
            iae_data(i, j) = data{i}.(scenarios{j}).IAE;
        end
    end
    
    bar(iae_data);
    set(gca, 'XTickLabel', labels, 'FontSize', 10);
    ylabel('IAE (m·s)', 'FontSize', 11);
    title('Integrated Absolute Error', 'FontSize', 12, 'FontWeight', 'bold');
    legend(scenarios, 'Location', 'northwest');
    grid on;
    
    % Add requirement line (target)
    hold on;
    yline(0.025, 'r--', 'LineWidth', 2, 'Label', 'Target (R-IAE-01)');
    hold off;
    
    %% Subplot 2: Energy Proxy Comparison
    subplot(2, 3, 2);
    energy_data = zeros(n_files, 3);
    for i = 1:n_files
        for j = 1:3
            energy_data(i, j) = data{i}.(scenarios{j}).energy_proxy;
        end
    end
    
    bar(energy_data);
    set(gca, 'XTickLabel', labels, 'FontSize', 10);
    ylabel('Energy Proxy (units)', 'FontSize', 11);
    title('Energy Consumption', 'FontSize', 12, 'FontWeight', 'bold');
    legend(scenarios, 'Location', 'northwest');
    grid on;
    
    hold on;
    yline(60, 'r--', 'LineWidth', 2, 'Label', 'Target (R-ENERGY-01)');
    hold off;
    
    %% Subplot 3: Line Loss Events
    subplot(2, 3, 3);
    lineloss_data = zeros(n_files, 3);
    for i = 1:n_files
        for j = 1:3
            lineloss_data(i, j) = data{i}.(scenarios{j}).line_loss_events;
        end
    end
    
    bar(lineloss_data);
    set(gca, 'XTickLabel', labels, 'FontSize', 10);
    ylabel('Line Loss Events', 'FontSize', 11);
    title('Line Loss Count', 'FontSize', 12, 'FontWeight', 'bold');
    legend(scenarios, 'Location', 'northwest');
    grid on;
    
    hold on;
    yline(0, 'r--', 'LineWidth', 2, 'Label', 'Target (R-FAULT-01)');
    hold off;
    
    %% Subplot 4: Completion Time
    subplot(2, 3, 4);
    time_data = zeros(n_files, 3);
    for i = 1:n_files
        for j = 1:3
            time_data(i, j) = data{i}.(scenarios{j}).t_final;
        end
    end
    
    bar(time_data);
    set(gca, 'XTickLabel', labels, 'FontSize', 10);
    ylabel('Time (s)', 'FontSize', 11);
    title('Completion Time', 'FontSize', 12, 'FontWeight', 'bold');
    legend(scenarios, 'Location', 'northwest');
    grid on;
    
    hold on;
    yline(75, 'r--', 'LineWidth', 2, 'Label', 'Target S1 (R-TIME-01)');
    hold off;
    
    %% Subplot 5: Speed Cap Compliance (S3 only)
    subplot(2, 3, 5);
    speed_cap_data = zeros(n_files, 1);
    for i = 1:n_files
        if ~isempty(data{i}.S3.max_v_fault)
            speed_cap_data(i) = data{i}.S3.max_v_fault;
        end
    end
    
    bar(speed_cap_data);
    set(gca, 'XTickLabel', labels, 'FontSize', 10);
    ylabel('Max v during fault (m/s)', 'FontSize', 11);
    title('S3 Speed Cap Compliance', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 0.5]);
    grid on;
    
    hold on;
    yline(0.45, 'r--', 'LineWidth', 2, 'Label', 'Limit (R-CAP-01)');
    hold off;
    
    %% Subplot 6: Requirements Pass/Fail Summary
    subplot(2, 3, 6);
    
    % Define requirements and check
    req_names = {'R-TIME', 'R-IAE', 'R-ENERGY', 'R-OBS', 'R-CAP', 'R-LL'};
    pass_fail = zeros(n_files, 6);
    
    for i = 1:n_files
        m = data{i};
        pass_fail(i, 1) = m.S1.t_final <= 75;
        pass_fail(i, 2) = m.S1.IAE <= 0.025;
        pass_fail(i, 3) = m.S1.energy_proxy <= 60;
        pass_fail(i, 4) = m.S2.obstacle_contacts == 0;
        pass_fail(i, 5) = m.S3.speed_cap_ok;
        pass_fail(i, 6) = m.S3.line_loss_events == 0;
    end
    
    % Color map: green = pass, red = fail
    imagesc(pass_fail');
    colormap([1 0 0; 0 0.8 0]);  % Red, Green
    set(gca, 'XTick', 1:n_files, 'XTickLabel', labels);
    set(gca, 'YTick', 1:6, 'YTickLabel', req_names);
    title('Requirements Verification', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Fidelity Level', 'FontSize', 11);
    ylabel('Requirement', 'FontSize', 11);
    
    % Add text annotations
    for i = 1:n_files
        for j = 1:6
            if pass_fail(i, j)
                text(i, j, '✓', 'HorizontalAlignment', 'center', ...
                     'FontSize', 16, 'Color', 'w', 'FontWeight', 'bold');
            else
                text(i, j, '✗', 'HorizontalAlignment', 'center', ...
                     'FontSize', 16, 'Color', 'w', 'FontWeight', 'bold');
            end
        end
    end
    
    %% Overall title
    sgtitle('MC3113 Line-Follower Performance Comparison', ...
            'FontSize', 14, 'FontWeight', 'bold');
    
    %% Save figure
    saveas(fig, 'plots/metrics_comparison.png');
    fprintf('✓ Saved: plots/metrics_comparison.png\n');
end
