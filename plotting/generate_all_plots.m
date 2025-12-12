function generate_all_plots()
% GENERATE_ALL_PLOTS  Generate all visualization plots for demo
%
%   Run this after completing all scenario simulations

    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  MC3113 Plot Generation Suite\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    % Ensure plots directory exists
    if ~exist('plots', 'dir')
        mkdir('plots');
        fprintf('✓ Created plots/ directory\n');
    end
    
    %% 1. Metrics Comparison (All Fidelity Levels)
    fprintf('\n[1/4] Generating metrics comparison plot...\n');
    try
        plot_metrics_comparison();
        fprintf('      ✓ Complete\n');
    catch ME
        fprintf('      ✗ Error: %s\n', ME.message);
    end
    
    %% 2. Time-Series Plots (Realistic fidelity)
    fprintf('\n[2/4] Generating time-series plots...\n');
    csv_files = {
        'logging/Demo_S1_final.csv'
        'logging/Demo_S2_final.csv'
        'logging/Demo_S3_final.csv'
    };
    
    for i = 1:length(csv_files)
        if exist(csv_files{i}, 'file')
            try
                scenario = sprintf('S%d', i);
                plot_timeseries(csv_files{i}, scenario);
                fprintf('      ✓ %s complete\n', scenario);
            catch ME
                fprintf('      ✗ Error in %s: %s\n', scenario, ME.message);
            end
        else
            fprintf('      ⚠ File not found: %s\n', csv_files{i});
        end
    end
    
    %% 3. Requirements Dashboard
    fprintf('\n[3/4] Generating requirements dashboard...\n');
    try
        plot_requirements_dashboard('metrics/Demo_metrics_final.json', csv_files);
        fprintf('      ✓ Complete\n');
    catch ME
        fprintf('      ✗ Error: %s\n', ME.message);
    end
    
    %% 4. Comparison across fidelity (if all exist)
    fprintf('\n[4/4] Checking for fidelity comparison data...\n');
    all_metrics = {
        'metrics/Demo_metrics_simple.json'
        'metrics/Demo_metrics_final.json'
        'metrics/Demo_metrics_hifi.json'
    };
    
    if all(cellfun(@(f) exist(f,'file'), all_metrics))
        fprintf('      ✓ All fidelity levels available\n');
        fprintf('      Already generated in step 1\n');
    else
        fprintf('      ⚠ Not all fidelity levels found\n');
    end
    
    %% Summary
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('  Plot Generation Complete\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('\nGenerated plots saved to: plots/\n');
    fprintf('  • metrics_comparison.png\n');
    fprintf('  • timeseries_Demo_S1_final.png\n');
    fprintf('  • timeseries_Demo_S2_final.png\n');
    fprintf('  • timeseries_Demo_S3_final.png\n');
    fprintf('  • dashboard_Demo_metrics_final.png\n\n');
end
