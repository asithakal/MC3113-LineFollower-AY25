function plot_controller_comparison(fidelity_level)
% PLOT_CONTROLLER_COMPARISON  Compare tuned vs untuned controller performance
%
%   plot_controller_comparison('realistic')
%
% Requires: Must run both versions first
%   run_all_scenarios_demo('realistic', 'untuned');
%   run_all_scenarios_demo('realistic', 'tuned');

    if nargin < 1
        fidelity_level = 'realistic';
    end
    
    suffix_map = struct('simple', 'simple', 'realistic', 'final', 'hifi', 'hifi');
    suffix = suffix_map.(fidelity_level);
    
    % Load metrics
    metrics_tuned = jsondecode(fileread(sprintf('metrics/Demo_metrics_%s.json', suffix)));
    metrics_untuned = jsondecode(fileread(sprintf('metrics/Demo_metrics_%s_untuned.json', suffix)));
    
    % Create comparison figure
    figure('Position', [100 100 1400 800], 'Color', 'w');
    
    scenarios = {'S1', 'S2', 'S3'};
    metrics_names = {'IAE', 'energy_proxy', 'line_loss_events'};
    titles = {'Integrated Absolute Error', 'Energy Consumption', 'Line Loss Events'};
    
    for i = 1:3
        subplot(2, 3, i);
        
        tuned_vals = zeros(3, 1);
        untuned_vals = zeros(3, 1);
        
        for j = 1:3
            tuned_vals(j) = metrics_tuned.(scenarios{j}).(metrics_names{i});
            untuned_vals(j) = metrics_untuned.(scenarios{j}).(metrics_names{i});
        end
        
        bar([tuned_vals, untuned_vals]);
        set(gca, 'XTickLabel', scenarios);
        legend('Tuned', 'Untuned', 'Location', 'best');
        title(titles{i});
        ylabel(metrics_names{i});
        grid on;
    end
    
    % Add overall comparison
    subplot(2, 3, [4 5 6]);
    
    pass_tuned = sum([...
        metrics_tuned.S1.t_final <= 75, ...
        metrics_tuned.S1.IAE <= 0.025, ...
        metrics_tuned.S1.energy_proxy <= 60, ...
        metrics_tuned.S2.obstacle_contacts == 0, ...
        metrics_tuned.S3.speed_cap_ok, ...
        metrics_tuned.S3.line_loss_events == 0]);
    
    pass_untuned = sum([...
        metrics_untuned.S1.t_final <= 75, ...
        metrics_untuned.S1.IAE <= 0.025, ...
        metrics_untuned.S1.energy_proxy <= 60, ...
        metrics_untuned.S2.obstacle_contacts == 0, ...
        metrics_untuned.S3.speed_cap_ok, ...
        metrics_untuned.S3.line_loss_events == 0]);
    
    bar([pass_tuned, pass_untuned; 6-pass_tuned, 6-pass_untuned]', 'stacked');
    set(gca, 'XTickLabel', {'Tuned', 'Untuned'});
    legend('Passed', 'Failed', 'Location', 'best');
    title('Requirements Verification (6 total)');
    ylabel('Number of Requirements');
    ylim([0 7]);
    grid on;
    
    sgtitle(sprintf('Controller Comparison - %s Fidelity', upper(fidelity_level)), ...
        'FontSize', 16, 'FontWeight', 'bold');
    
    % Save
    saveas(gcf, sprintf('plots/controller_comparison_%s.png', fidelity_level));
    fprintf('✓ Comparison plot saved to plots/controller_comparison_%s.png\n', fidelity_level);
end
