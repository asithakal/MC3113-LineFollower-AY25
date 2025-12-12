function hFig = plot_metrics(inputCSV, varargin)
% PLOT_METRICS  Plot key signals from a line-follower log.
%
%   hFig = PLOT_METRICS('logging/Team01_S1_run001.csv')
%
%   Optional name-value pairs:
%     'TitlePrefix' : string prepended to the main title
%     'ShowLegend'  : true/false (default true)
%
%   Returns:
%     hFig : handle to the created figure

    %% Parse inputs
    p = inputParser;
    addRequired(p, 'inputCSV', @(s)ischar(s) || isstring(s));
    addParameter(p, 'TitlePrefix', "", @(s)ischar(s) || isstring(s));
    addParameter(p, 'ShowLegend', true, @(x)islogical(x) && isscalar(x));
    parse(p, inputCSV, varargin{:});

    inputCSV    = string(p.Results.inputCSV);
    titlePrefix = string(p.Results.TitlePrefix);
    showLegend  = p.Results.ShowLegend;

    if ~isfile(inputCSV)
        error('plot_metrics:FileNotFound', 'File not found: %s', inputCSV);
    end

    %% Load data
    T = readtable(inputCSV);

    if ~ismember('t', T.Properties.VariableNames)
        error('plot_metrics:MissingColumn', 'Column "t" not found in %s.', inputCSV);
    end

    t = T.t;

    % Scenario (if present)
    scenarioStr = "";
    if ismember('scenario_id', T.Properties.VariableNames)
        scenarioStr = string(T.scenario_id(1));
    end

    % Build an overall title
    mainTitle = "Line-Follower Signals";
    if titlePrefix ~= ""
        mainTitle = titlePrefix + " – " + mainTitle;
    end
    if scenarioStr ~= ""
        mainTitle = mainTitle + " (" + scenarioStr + ")";
    end

    %% Create figure and subplots
    hFig = figure('Name', 'Line-Follower Metrics', 'NumberTitle', 'off');

    % ---- 1) Lateral error ----
    subplot(3,1,1);
    if ismember('e_line', T.Properties.VariableNames)
        plot(t, T.e_line, 'LineWidth', 1.2);
        ylabel('e\_line [m]');
        title(mainTitle, 'Interpreter', 'none');
    else
        text(0.5, 0.5, 'e\_line not available', 'HorizontalAlignment', 'center');
    end
    grid on;

    % ---- 2) Commands u_L, u_R ----
    subplot(3,1,2);
    hold on;
    has_uL = ismember('u_L', T.Properties.VariableNames);
    has_uR = ismember('u_R', T.Properties.VariableNames);
    if has_uL
        plot(t, T.u_L, 'b-', 'LineWidth', 1.2);
    end
    if has_uR
        plot(t, T.u_R, 'r-', 'LineWidth', 1.2);
    end
    hold off;
    ylabel('u\_L, u\_R');
    if showLegend && (has_uL || has_uR)
        legEntries = {};
        if has_uL, legEntries{end+1} = 'u_L'; end
        if has_uR, legEntries{end+1} = 'u_R'; end
        legend(legEntries, 'Location', 'best');
    end
    grid on;

    % ---- 3) Speed v ----
    subplot(3,1,3);
    if ismember('v', T.Properties.VariableNames)
        plot(t, T.v, 'LineWidth', 1.2);
        ylabel('v [m/s]');
    else
        text(0.5, 0.5, 'v not available', 'HorizontalAlignment', 'center');
    end
    xlabel('Time [s]');
    grid on;

end
