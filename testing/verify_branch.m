function results = verify_branch()
% VERIFY_BRANCH  Automated verification of current Git branch setup
%
%   results = verify_branch()
%
% Checks:
%   - Git branch identity
%   - Required files/folders exist
%   - MATLAB path setup
%   - Basic functionality tests
%   - Demo/student material separation

    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  MC3113 Branch Verification Tool\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    results = struct();
    results.branch = '';
    results.tests_passed = 0;
    results.tests_failed = 0;
    results.errors = {};
    
    %% 1. Git Branch Detection
    fprintf('[1/10] Checking Git branch...\n');
    try
        [status, branch_name] = system('git rev-parse --abbrev-ref HEAD');
        if status == 0
            branch_name = strtrim(branch_name);
            results.branch = branch_name;
            fprintf('        ✓ Current branch: %s\n', branch_name);
            results.tests_passed = results.tests_passed + 1;
        else
            error('Unable to detect Git branch');
        end
    catch ME
        fprintf('        ✗ Error: %s\n', ME.message);
        results.tests_failed = results.tests_failed + 1;
        results.errors{end+1} = 'Git detection failed';
        return;
    end
    
    %% 2. Determine expected configuration
    is_demo_branch = strcmp(branch_name, 'demo-instructor-complete');
    is_main_branch = strcmp(branch_name, 'main');
    
    if ~is_demo_branch && ~is_main_branch
        fprintf('        ⚠ Warning: Unknown branch "%s"\n', branch_name);
    end
    
    %% 3. Check required directories
    fprintf('\n[2/10] Checking directory structure...\n');
    
    common_dirs = {'src', 'scripts', 'config', 'interfaces', 'logging', 'metrics', 'docs'};
    demo_only_dirs = {'demo-solution', 'plotting'};
    
    % Check common directories
    for i = 1:length(common_dirs)
        if exist(common_dirs{i}, 'dir')
            fprintf('        ✓ %s/ exists\n', common_dirs{i});
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ %s/ missing\n', common_dirs{i});
            results.tests_failed = results.tests_failed + 1;
            results.errors{end+1} = sprintf('%s/ directory missing', common_dirs{i});
        end
    end
    
    % Check demo-only directories
    if is_demo_branch
        for i = 1:length(demo_only_dirs)
            if exist(demo_only_dirs{i}, 'dir')
                fprintf('        ✓ %s/ exists (demo branch)\n', demo_only_dirs{i});
                results.tests_passed = results.tests_passed + 1;
            else
                fprintf('        ✗ %s/ missing (required for demo)\n', demo_only_dirs{i});
                results.tests_failed = results.tests_failed + 1;
                results.errors{end+1} = sprintf('%s/ missing on demo branch', demo_only_dirs{i});
            end
        end
    else
        % Main branch should NOT have demo-solution
        if exist('demo-solution', 'dir')
            fprintf('        ✗ demo-solution/ exists (should only be on demo branch!)\n');
            results.tests_failed = results.tests_failed + 1;
            results.errors{end+1} = 'demo-solution/ found on main branch - SECURITY ISSUE';
        else
            fprintf('        ✓ demo-solution/ correctly absent (main branch)\n');
            results.tests_passed = results.tests_passed + 1;
        end
    end
    
    %% 4. Check key files
    fprintf('\n[3/10] Checking key files...\n');
    
    common_files = {
        'scripts/run_scenario.m'
        'metrics/compute_metrics.m'
        'docs/Line-Follower-Project-Brief.md'
        'README.md'
    };
    
    for i = 1:length(common_files)
        if exist(common_files{i}, 'file')
            fprintf('        ✓ %s\n', common_files{i});
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ %s missing\n', common_files{i});
            results.tests_failed = results.tests_failed + 1;
            results.errors{end+1} = sprintf('%s missing', common_files{i});
        end
    end
    
    % Demo branch specific files
    if is_demo_branch
        demo_files = {
            'demo-solution/InstructorGuide.md'
            'demo-solution/instructor_controller.m'
            'demo-solution/run_all_scenarios_demo.m'
            'plotting/plot_metrics_comparison.m'
        };
        
        for i = 1:length(demo_files)
            if exist(demo_files{i}, 'file')
                fprintf('        ✓ %s (demo)\n', demo_files{i});
                results.tests_passed = results.tests_passed + 1;
            else
                fprintf('        ✗ %s missing (demo)\n', demo_files{i});
                results.tests_failed = results.tests_failed + 1;
                results.errors{end+1} = sprintf('%s missing on demo branch', demo_files{i});
            end
        end
    end
    
    %% 5. Check controller files
    fprintf('\n[4/10] Checking controller files...\n');
    
    if is_demo_branch
        if exist('demo-solution/instructor_controller.m', 'file')
            fprintf('        ✓ instructor_controller.m exists\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ instructor_controller.m missing\n');
            results.tests_failed = results.tests_failed + 1;
        end
    else
        % Main branch: check student template
        if exist('src/my_controller_step.m', 'file')
            fprintf('        ✓ my_controller_step.m exists (student template)\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ my_controller_step.m missing\n');
            results.tests_failed = results.tests_failed + 1;
        end
        
        % Should NOT have instructor controller
        if exist('demo-solution/instructor_controller.m', 'file')
            fprintf('        ✗ SECURITY ISSUE: instructor_controller.m on main branch!\n');
            results.tests_failed = results.tests_failed + 1;
            results.errors{end+1} = 'SECURITY: Instructor solution on main branch';
        end
    end
    
    %% 6. Test MATLAB function loading
    fprintf('\n[5/10] Testing MATLAB function availability...\n');
    
    try
        if exist('run_scenario', 'file') == 2
            fprintf('        ✓ run_scenario() found\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ run_scenario() not found\n');
            results.tests_failed = results.tests_failed + 1;
        end
        
        if exist('compute_metrics', 'file') == 2
            fprintf('        ✓ compute_metrics() found\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ compute_metrics() not found\n');
            results.tests_failed = results.tests_failed + 1;
        end
        
        if is_demo_branch
            if exist('instructor_controller', 'file') == 2
                fprintf('        ✓ instructor_controller() found\n');
                results.tests_passed = results.tests_passed + 1;
            else
                fprintf('        ✗ instructor_controller() not found\n');
                results.tests_failed = results.tests_failed + 1;
            end
        end
    catch ME
        fprintf('        ✗ Error checking functions: %s\n', ME.message);
        results.tests_failed = results.tests_failed + 1;
    end
    
    %% 7. Test basic scenario run (short test)
    fprintf('\n[6/10] Running quick functionality test...\n');
    
    try
        if is_demo_branch
            % Test instructor controller with simple plant
            test_passed = test_demo_controller_quick();
        else
            % Test student template structure
            test_passed = test_student_template_quick();
        end
        
        if test_passed
            fprintf('        ✓ Basic functionality test passed\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ✗ Functionality test failed\n');
            results.tests_failed = results.tests_failed + 1;
        end
    catch ME
        fprintf('        ✗ Error during test: %s\n', ME.message);
        results.tests_failed = results.tests_failed + 1;
        results.errors{end+1} = sprintf('Functionality test error: %s', ME.message);
    end
    
    %% 8. Check .gitignore configuration
    fprintf('\n[7/10] Checking .gitignore configuration...\n');
    
    if exist('.gitignore', 'file')
        gitignore_content = fileread('.gitignore');
        
        if is_main_branch
            if contains(gitignore_content, 'demo-solution')
                fprintf('        ✓ .gitignore blocks demo-solution/ (correct for main)\n');
                results.tests_passed = results.tests_passed + 1;
            else
                fprintf('        ⚠ .gitignore does not block demo-solution/\n');
            end
        else
            fprintf('        ℹ .gitignore present (demo branch)\n');
        end
    else
        fprintf('        ⚠ .gitignore not found\n');
    end
    
    %% 9. Check documentation
    fprintf('\n[8/10] Checking documentation completeness...\n');
    
    docs_to_check = {
        'README.md'
        'docs/Line-Follower-Project-Brief.md'
    };
    
    if is_demo_branch
        docs_to_check{end+1} = 'demo-solution/InstructorGuide.md';
        docs_to_check{end+1} = 'demo-solution/README.md';
    end
    
    for i = 1:length(docs_to_check)
        if exist(docs_to_check{i}, 'file')
            fsize = dir(docs_to_check{i});
            if fsize.bytes > 100
                fprintf('        ✓ %s (%.1f KB)\n', docs_to_check{i}, fsize.bytes/1024);
                results.tests_passed = results.tests_passed + 1;
            else
                fprintf('        ⚠ %s exists but very small\n', docs_to_check{i});
            end
        else
            fprintf('        ✗ %s missing\n', docs_to_check{i});
            results.tests_failed = results.tests_failed + 1;
        end
    end
    
    %% 10. Check for common issues
    fprintf('\n[9/10] Checking for common issues...\n');
    
    % Check for leftover test files
    test_files = dir('logging/test_*.csv');
    if length(test_files) > 10
        fprintf('        ⚠ Many test files in logging/ (%d files)\n', length(test_files));
    else
        fprintf('        ✓ logging/ directory clean\n');
        results.tests_passed = results.tests_passed + 1;
    end
    
    % Check MATLAB path
    current_path = path();
    required_in_path = {'scripts', 'metrics', 'src'};
    
    for i = 1:length(required_in_path)
        if contains(current_path, required_in_path{i})
            fprintf('        ✓ %s/ in MATLAB path\n', required_in_path{i});
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('        ⚠ %s/ not in MATLAB path (may need addpath)\n', required_in_path{i});
        end
    end
    
    %% 11. Git remote check
    fprintf('\n[10/10] Checking Git remotes...\n');
    
    [status, remotes] = system('git remote -v');
    if status == 0 && ~isempty(remotes)
        fprintf('        ✓ Git remotes configured:\n');
        remote_lines = strsplit(remotes, '\n');
        for i = 1:min(4, length(remote_lines))
            if ~isempty(strtrim(remote_lines{i}))
                fprintf('          %s\n', strtrim(remote_lines{i}));
            end
        end
        results.tests_passed = results.tests_passed + 1;
    else
        fprintf('        ⚠ No Git remotes configured\n');
    end
    
    %% Summary Report
    fprintf('\n═══════════════════════════════════════════════════════════\n');
    fprintf('  Verification Summary\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    fprintf('Branch: %s\n', branch_name);
    fprintf('Tests Passed: %d\n', results.tests_passed);
    fprintf('Tests Failed: %d\n', results.tests_failed);
    
    if results.tests_failed == 0
        fprintf('\n✓ All tests PASSED - Branch is ready!\n');
    else
        fprintf('\n✗ Some tests FAILED - Review errors below:\n');
        for i = 1:length(results.errors)
            fprintf('  %d. %s\n', i, results.errors{i});
        end
    end
    
    fprintf('\n═══════════════════════════════════════════════════════════\n\n');
end

function pass = test_demo_controller_quick()
    % Quick test of instructor controller
    try
        % Create dummy inputs
        inputs.sensor = [0.2; 0.5; 1.0; 0.5; 0.2];
        inputs.e_line = 0.05;
        inputs.v = 0.3;
        inputs.omega = 0.1;
        inputs.obstacle_flag = 0;
        inputs.fault_flag = 0;
        
        % Call controller
        [u_L, u_R] = instructor_controller(inputs);
        
        % Basic validation
        pass = (u_L >= -1 && u_L <= 1) && (u_R >= -1 && u_R <= 1);
        
        if pass
            fprintf('          Controller output: u_L=%.3f, u_R=%.3f\n', u_L, u_R);
        end
    catch
        pass = false;
    end
end

function pass = test_student_template_quick()
    % Quick test that student template exists and has correct signature
    try
        if exist('my_controller_step', 'file') == 2
            % Check function signature
            help_text = help('my_controller_step');
            pass = ~isempty(help_text);
        else
            pass = false;
        end
    catch
        pass = false;
    end
end
