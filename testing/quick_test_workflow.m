function quick_test_workflow()
% QUICK_TEST_WORKFLOW  Run a quick end-to-end test of the workflow
%
%   Tests the complete pipeline from controller → simulation → metrics → plots

    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  Quick Workflow Test\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    % Detect branch
    [~, branch] = system('git rev-parse --abbrev-ref HEAD');
    branch = strtrim(branch);
    
    if strcmp(branch, 'demo-instructor-complete')
        test_demo_workflow();
    elseif strcmp(branch, 'main')
        test_student_workflow();
    else
        fprintf('Unknown branch: %s\n', branch);
        return;
    end
end

function test_demo_workflow()
    fprintf('[DEMO BRANCH TEST]\n\n');
    
    %% Test 1: Run single scenario
    fprintf('Test 1: Running S1 with simple fidelity...\n');
    try
        run_scenario_simple('S1', @instructor_controller, 'QuickTest_S1');
        fprintf('  ✓ Scenario execution successful\n');
    catch ME
        fprintf('  ✗ Error: %s\n', ME.message);
        return;
    end
    
    %% Test 2: Compute metrics
    fprintf('\nTest 2: Computing metrics...\n');
    try
        m = compute_metrics('logging/QuickTest_S1.csv', 'S1');
        fprintf('  ✓ Metrics computed\n');
        fprintf('    IAE: %.4f m·s\n', m.IAE);
        fprintf('    Time: %.1f s\n', m.t_final);
        fprintf('    Energy: %.1f units\n', m.energy_proxy);
    catch ME
        fprintf('  ✗ Error: %s\n', ME.message);
        return;
    end
    
    %% Test 3: Plotting (if available)
    fprintf('\nTest 3: Testing plotting functions...\n');
    try
        if exist('plot_timeseries', 'file')
            plot_timeseries('logging/QuickTest_S1.csv', 'S1');
            fprintf('  ✓ Plotting successful\n');
        else
            fprintf('  ⚠ Plotting functions not found (may need addpath)\n');
        end
    catch ME
        fprintf('  ✗ Plot error: %s\n', ME.message);
    end
    
    fprintf('\n✓ Demo workflow test complete!\n\n');
end

function test_student_workflow()
    fprintf('[MAIN BRANCH TEST]\n\n');
    
    fprintf('Checking student template structure...\n');
    
    if exist('src/my_controller_step.m', 'file')
        fprintf('  ✓ Student controller template exists\n');
    else
        fprintf('  ✗ Student template missing\n');
        return;
    end
    
    if exist('demo-solution', 'dir')
        fprintf('  ✗ SECURITY ISSUE: demo-solution/ exists on main branch!\n');
    else
        fprintf('  ✓ Demo solution correctly absent\n');
    end
    
    fprintf('\n✓ Main branch structure correct!\n\n');
end
