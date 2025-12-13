function startup_demo()
    % Startup script for demo-instructor-complete branch
    
    % Set working directory
    cd 'D:\Documents\Work\Asitha\KDU\Mechatronics\2025_Nov\Demo\LineFollowerDemo';
    
    % Add paths
    addpath('demo-solution', 'src', 'scripts', 'metrics', 'logging', 'config', 'interfaces');
    
    % Verify branch
    [status, branch] = system('git rev-parse --abbrev-ref HEAD');
    branch = strtrim(branch);
    
    fprintf('\n=== MC3113 Line-Follower Demo ===\n');
    fprintf('Git branch: %s\n', branch);
    
    if strcmp(branch, 'demo-instructor-complete')
        fprintf('✓ Demo solution loaded\n');
    else
        warning('Not on demo-instructor-complete branch!');
    end
    
    fprintf('Ready to run demos.\n\n');
end
