function compare_branches()
% COMPARE_BRANCHES  Compare main and demo branches for consistency
%
%   Run this from either branch to see differences

    fprintf('\n');
    fprintf('═══════════════════════════════════════════════════════════\n');
    fprintf('  Branch Comparison Tool\n');
    fprintf('═══════════════════════════════════════════════════════════\n\n');
    
    %% Get current branch
    [~, current_branch] = system('git rev-parse --abbrev-ref HEAD');
    current_branch = strtrim(current_branch);
    fprintf('Current branch: %s\n\n', current_branch);
    
    %% File comparison
    fprintf('Comparing file structure between branches...\n\n');
    
    % Files that should be identical
    common_files = {
        'scripts/run_scenario.m'
        'metrics/compute_metrics.m'
        'src/my_controller_step.m'
        'README.md'
    };
    
    fprintf('Common files (should exist on both branches):\n');
    for i = 1:length(common_files)
        main_exists = check_file_on_branch('main', common_files{i});
        demo_exists = check_file_on_branch('demo-instructor-complete', common_files{i});
        
        if main_exists && demo_exists
            fprintf('  ✓ %s (both branches)\n', common_files{i});
        elseif main_exists
            fprintf('  ⚠ %s (only on main)\n', common_files{i});
        elseif demo_exists
            fprintf('  ⚠ %s (only on demo)\n', common_files{i});
        else
            fprintf('  ✗ %s (missing on both!)\n', common_files{i});
        end
    end
    
    %% Demo-only files
    fprintf('\nDemo-only files (should ONLY be on demo branch):\n');
    
    demo_only = {
        'demo-solution/instructor_controller.m'
        'demo-solution/InstructorGuide.md'
        'plotting/plot_metrics_comparison.m'
    };
    
    for i = 1:length(demo_only)
        main_exists = check_file_on_branch('main', demo_only{i});
        demo_exists = check_file_on_branch('demo-instructor-complete', demo_only{i});
        
        if demo_exists && ~main_exists
            fprintf('  ✓ %s (correctly on demo only)\n', demo_only{i});
        elseif demo_exists && main_exists
            fprintf('  ✗ SECURITY ISSUE: %s (on both branches!)\n', demo_only{i});
        elseif ~demo_exists
            fprintf('  ✗ %s (missing from demo branch!)\n', demo_only{i});
        end
    end
    
    fprintf('\n═══════════════════════════════════════════════════════════\n\n');
end

function exists = check_file_on_branch(branch_name, file_path)
    % Check if file exists on a specific branch
    cmd = sprintf('git cat-file -e %s:%s 2>nul', branch_name, file_path);
    [status, ~] = system(cmd);
    exists = (status == 0);
end
