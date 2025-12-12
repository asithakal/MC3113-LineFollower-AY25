function run_all_scenarios_demo()
% RUN_ALL_SCENARIOS_DEMO  Batch run all three scenarios for demo project
%
% Generates:
%   - Demo_S1_final.csv
%   - Demo_S2_final.csv
%   - Demo_S3_final.csv
%   - Demo_metrics_summary.json

    fprintf('=== Running Complete Demo Solution ===\n\n');
    
    % Run S1 (Nominal)
    fprintf('Running S1 (Nominal)...\n');
    run_scenario('S1', @instructor_controller, 'Demo_S1_final');
    m1 = compute_metrics('logging/Demo_S1_final.csv', 'S1');
    fprintf('  t_final: %.1f s | IAE: %.4f | Energy: %.1f\n', ...
            m1.t_final, m1.IAE, m1.energy_proxy);
    
    % Run S2 (Obstacle)
    fprintf('\nRunning S2 (Obstacle)...\n');
    run_scenario('S2', @instructor_controller, 'Demo_S2_final');
    m2 = compute_metrics('logging/Demo_S2_final.csv', 'S2');
    fprintf('  t_final: %.1f s | IAE: %.4f | Contacts: %d\n', ...
            m2.t_final, m2.IAE, m2.obstacle_contacts);
    
    % Run S3 (Fault)
    fprintf('\nRunning S3 (Fault + Speed Cap)...\n');
    run_scenario('S3', @instructor_controller, 'Demo_S3_final');
    m3 = compute_metrics('logging/Demo_S3_final.csv', 'S3');
    fprintf('  t_final: %.1f s | Max v (fault): %.3f | Line loss: %d\n', ...
            m3.t_final, m3.max_v_fault, m3.line_loss_events);
    
    % Save summary
    metrics_all = struct('S1', m1, 'S2', m2, 'S3', m3);
    json_str = jsonencode(metrics_all, 'PrettyPrint', true);
    fid = fopen('metrics/Demo_metrics_summary.json', 'w');
    fprintf(fid, '%s', json_str);
    fclose(fid);
    
    fprintf('\n=== Demo Complete ===\n');
    fprintf('Metrics saved to: metrics/Demo_metrics_summary.json\n');
end
