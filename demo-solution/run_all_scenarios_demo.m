function run_all_scenarios_demo(fidelity_level)
% RUN_ALL_SCENARIOS_DEMO  Batch run all scenarios with fidelity selection
%
%   run_all_scenarios_demo()          - Default: 'realistic'
%   run_all_scenarios_demo('simple')  - Basic dynamics
%   run_all_scenarios_demo('realistic') - Medium fidelity (default)
%   run_all_scenarios_demo('hifi')    - High fidelity physics
%
% Fidelity Levels:
%   'simple'    - Minimal disturbances, fast execution
%   'realistic' - Typical engineering demo (noise, slip, disturbances)
%   'hifi'      - Research-grade (motor lag, battery, temperature, etc.)

    if nargin < 1
        fidelity_level = 'realistic';  % Default
    end
    
    % Validate input
    valid_levels = {'simple', 'realistic', 'hifi'};
    if ~ismember(fidelity_level, valid_levels)
        error('Invalid fidelity level. Use: simple, realistic, or hifi');
    end
    
    %% Display header
    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  MC3113 Line-Follower Complete Demo\n');
    fprintf('  Fidelity Level: %s\n', upper(fidelity_level));
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    %% Select runner function
    switch fidelity_level
        case 'simple'
            runner = @run_scenario_simple;
            suffix = 'simple';
        case 'realistic'
            runner = @run_scenario;  % Medium fidelity (from scripts/)
            suffix = 'final';
        case 'hifi'
            runner = @run_scenario_hifi;
            suffix = 'hifi';
    end
    
    %% Run scenarios
    scenarios = {'S1', 'S2', 'S3'};
    metrics_all = struct();
    
    for i = 1:length(scenarios)
        scenario = scenarios{i};
        run_id = sprintf('Demo_%s_%s', scenario, suffix);
        
        fprintf('─────────────────────────────────────────────────────────\n');
        fprintf('Running %s (%s)...\n', scenario, fidelity_level);
        fprintf('─────────────────────────────────────────────────────────\n');
        
        % Run scenario
        tic;
        runner(scenario, @instructor_controller, run_id);
        elapsed = toc;
        
        % Compute metrics
        log_file = sprintf('logging/%s.csv', run_id);
        m = compute_metrics(log_file, scenario);
        metrics_all.(scenario) = m;
        
        % Display results
        fprintf('\n📊 Results:\n');
        fprintf('   Time: %.1f s | IAE: %.4f m·s | Energy: %.1f units\n', ...
            m.t_final, m.IAE, m.energy_proxy);
        
        if strcmp(scenario, 'S2')
            fprintf('   Obstacle contacts: %d\n', m.obstacle_contacts);
        end
        
        if strcmp(scenario, 'S3')
            fprintf('   Max v (fault): %.3f m/s | Speed cap OK: %d\n', ...
                m.max_v_fault, m.speed_cap_ok);
            fprintf('   Line loss events: %d\n', m.line_loss_events);
        end
        
        fprintf('   Simulation time: %.2f s\n', elapsed);
        fprintf('\n');
    end
    
    %% Summary table
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  Performance Summary (%s fidelity)\n', upper(fidelity_level));
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    fprintf('%-8s | %8s | %10s | %10s | %8s\n', ...
        'Scenario', 'Time(s)', 'IAE(m·s)', 'Energy', 'Status');
    fprintf('─────────┼──────────┼────────────┼────────────┼────────────\n');
    
    for i = 1:length(scenarios)
        scenario = scenarios{i};
        m = metrics_all.(scenario);
        
        % Status check
        status = '✓ PASS';
        if strcmp(scenario, 'S1')
            if m.t_final > 75 || m.IAE > 0.025 || m.energy_proxy > 60
                status = '✗ FAIL';
            end
        elseif strcmp(scenario, 'S2')
            if m.obstacle_contacts > 0
                status = '✗ FAIL';
            end
        elseif strcmp(scenario, 'S3')
            if ~m.speed_cap_ok || m.line_loss_events > 0
                status = '✗ FAIL';
            end
        end
        
        fprintf('%-8s | %8.1f | %10.4f | %10.1f | %s\n', ...
            scenario, m.t_final, m.IAE, m.energy_proxy, status);
    end
    
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    %% Save metrics
    metrics_filename = sprintf('metrics/Demo_metrics_%s.json', suffix);
    json_str = jsonencode(metrics_all, 'PrettyPrint', true);
    fid = fopen(metrics_filename, 'w');
    fprintf(fid, '%s', json_str);
    fclose(fid);
    
    fprintf('💾 Metrics saved to: %s\n', metrics_filename);
    
    %% Requirements check
    fprintf('\n📋 Requirements Verification:\n');
    fprintf('   R-TIME-01:   '); check_req(metrics_all.S1.t_final <= 75, 'S1 time ≤ 75s');
    fprintf('   R-IAE-01:    '); check_req(metrics_all.S1.IAE <= 0.025, 'S1 IAE ≤ 0.025');
    fprintf('   R-ENERGY-01: '); check_req(metrics_all.S1.energy_proxy <= 60, 'S1 energy ≤ 60');
    fprintf('   R-OBS-01:    '); check_req(metrics_all.S2.obstacle_contacts == 0, 'S2 zero contacts');
    fprintf('   R-CAP-01:    '); check_req(metrics_all.S3.speed_cap_ok, 'S3 speed cap OK');
    fprintf('   R-FAULT-01:  '); check_req(metrics_all.S3.line_loss_events == 0, 'S3 no line loss');
    
    fprintf('\n✓ Demo complete!\n\n');
end

function check_req(passed, description)
    if passed
        fprintf('✓ PASS - %s\n', description);
    else
        fprintf('✗ FAIL - %s\n', description);
    end
end
