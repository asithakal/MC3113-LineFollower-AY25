function run_all_scenarios_demo(fidelity_level, controller_version)
% RUN_ALL_SCENARIOS_DEMO  Batch run all scenarios with fidelity and controller selection
%
%   run_all_scenarios_demo()                        - Default: 'realistic', 'tuned'
%   run_all_scenarios_demo('simple')                - Basic dynamics, tuned controller
%   run_all_scenarios_demo('realistic', 'untuned')  - Show poor performance for teaching
%   run_all_scenarios_demo('hifi', 'tuned')         - High fidelity, optimized controller
%
% Inputs:
%   fidelity_level - Simulation physics complexity
%       'simple'    - Minimal disturbances, fast execution
%       'realistic' - Medium fidelity (noise, slip, disturbances) [default]
%       'hifi'      - High fidelity (motor lag, battery, temperature)
%
%   controller_version - Which controller to use
%       'tuned'     - Optimized PID controller (Kp=-3, Ki=-0.5, Kd=-0.8) [default]
%       'untuned'   - Simple P controller (Kp=-1) - for teaching demos
%
% Teaching Notes:
%   Use 'untuned' version in Week 3 to demonstrate:
%     - Poor tracking performance (large IAE)
%     - Excessive energy consumption
%     - Line loss events
%   Then show 'tuned' version to illustrate proper design
%
% Examples:
%   run_all_scenarios_demo();                    % Default: realistic + tuned
%   run_all_scenarios_demo('simple', 'tuned');   % Fast test
%   run_all_scenarios_demo('realistic', 'untuned'); % Teaching demo

    %% Parse inputs
    if nargin < 1
        fidelity_level = 'realistic';  % Default fidelity
    end
    
    if nargin < 2
        controller_version = 'tuned';  % Default controller
    end
    
    %% Validate fidelity level
    valid_levels = {'simple', 'realistic', 'hifi'};
    if ~ismember(fidelity_level, valid_levels)
        error('Invalid fidelity level. Use: simple, realistic, or hifi');
    end
    
    %% Validate controller version
    valid_controllers = {'tuned', 'untuned'};
    if ~ismember(controller_version, valid_controllers)
        error('Invalid controller version. Use: tuned or untuned');
    end
    
    %% Select controller function
    if strcmp(controller_version, 'untuned')
        controller_func = @instructor_controller_untuned;
        controller_name = 'Simple P (Untuned)';
        controller_suffix = '_untuned';
    else
        controller_func = @instructor_controller;
        controller_name = 'PID (Tuned)';
        controller_suffix = '';
    end
    
    %% Display header
    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  MC3113 Line-Follower Complete Demo\n');
    fprintf('  Fidelity Level: %s\n', upper(fidelity_level));
    fprintf('  Controller:     %s\n', controller_name);
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    %% Select runner function based on fidelity
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
    
    % Append controller suffix to run_id
    suffix = [suffix controller_suffix];
    
    %% Run scenarios
    scenarios = {'S1', 'S2', 'S3'};
    metrics_all = struct();
    
    for i = 1:length(scenarios)
        scenario = scenarios{i};
        run_id = sprintf('Demo_%s_%s', scenario, suffix);
        
        fprintf('─────────────────────────────────────────────────────────\n');
        fprintf('Running %s (%s, %s controller)...\n', ...
            scenario, fidelity_level, controller_version);
        fprintf('─────────────────────────────────────────────────────────\n');
        
        % Run scenario with selected controller
        tic;
        runner(scenario, controller_func, run_id);
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
    fprintf('  Performance Summary (%s, %s)\n', upper(fidelity_level), controller_name);
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    fprintf('%-8s | %8s | %10s | %10s | %8s\n', ...
        'Scenario', 'Time(s)', 'IAE(m·s)', 'Energy', 'Status');
    fprintf('─────────┼──────────┼────────────┼────────────┼────────────\n');
    
    for i = 1:length(scenarios)
        scenario = scenarios{i};
        m = metrics_all.(scenario);
        
        % Status check against requirements
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
    
    %% Save metrics with controller version in filename
    metrics_filename = sprintf('metrics/Demo_metrics_%s.json', suffix);
    
    % Add metadata to metrics structure
    metrics_all.metadata = struct(...
        'fidelity_level', fidelity_level, ...
        'controller_version', controller_version, ...
        'controller_name', controller_name, ...
        'timestamp', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    
    json_str = jsonencode(metrics_all, 'PrettyPrint', true);
    fid = fopen(metrics_filename, 'w');
    fprintf(fid, '%s', json_str);
    fclose(fid);
    
    fprintf('💾 Metrics saved to: %s\n', metrics_filename);
    
    %% Requirements verification
    fprintf('\n📋 Requirements Verification:\n');
    fprintf('   R-TIME-01:   '); check_req(metrics_all.S1.t_final <= 75, 'S1 time ≤ 75s', metrics_all.S1.t_final);
    fprintf('   R-IAE-01:    '); check_req(metrics_all.S1.IAE <= 0.025, 'S1 IAE ≤ 0.025', metrics_all.S1.IAE);
    fprintf('   R-ENERGY-01: '); check_req(metrics_all.S1.energy_proxy <= 60, 'S1 energy ≤ 60', metrics_all.S1.energy_proxy);
    fprintf('   R-OBS-01:    '); check_req(metrics_all.S2.obstacle_contacts == 0, 'S2 zero contacts', metrics_all.S2.obstacle_contacts);
    fprintf('   R-CAP-01:    '); check_req(metrics_all.S3.speed_cap_ok, 'S3 speed cap OK', metrics_all.S3.max_v_fault);
    fprintf('   R-FAULT-01:  '); check_req(metrics_all.S3.line_loss_events == 0, 'S3 no line loss', metrics_all.S3.line_loss_events);
    
    %% Teaching recommendation
    if strcmp(controller_version, 'untuned')
        fprintf('\n💡 Teaching Tip:\n');
        fprintf('   This untuned controller demonstrates poor performance.\n');
        fprintf('   Now run: run_all_scenarios_demo(''%s'', ''tuned'')\n', fidelity_level);
        fprintf('   to show students the improvement with proper tuning.\n');
    end
    
    fprintf('\n✓ Demo complete!\n\n');
end

function check_req(passed, description, value)
% Helper function to display requirement check with actual value
    if passed
        fprintf('✓ PASS - %s\n', description);
    else
        if isnumeric(value)
            fprintf('✗ FAIL - %s (actual: %.3g)\n', description, value);
        else
            fprintf('✗ FAIL - %s\n', description);
        end
    end
end
