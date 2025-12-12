# MC3113 Plotting Suite

Visualization tools for line-follower demo data.

## Quick Start

```
% Add to path
addpath('plotting');

% Generate all plots
generate_all_plots();
```

## Individual Plot Functions

### 1. Metrics Comparison
```
% Compare across fidelity levels
plot_metrics_comparison();

% Or custom comparison
files = {'metrics/before_tuning.json', 'metrics/after_tuning.json'};
labels = {'Before', 'After'};
plot_metrics_comparison(files, labels);
```

### 2. Time-Series Analysis
```
% Single scenario
plot_timeseries('logging/Demo_S1_final.csv', 'S1');

% All scenarios
for s = {'S1', 'S2', 'S3'}
    csv = sprintf('logging/Demo_%s_final.csv', s{1});
    plot_timeseries(csv, s{1});
end
```

### 3. Requirements Dashboard
```
metrics = 'metrics/Demo_metrics_final.json';
logs = {'logging/Demo_S1_final.csv', ...
        'logging/Demo_S2_final.csv', ...
        'logging/Demo_S3_final.csv'};
plot_requirements_dashboard(metrics, logs);
```

## Output

All plots saved to `plots/` directory as PNG files.

## Teaching Use

- **Week 3-4**: Show metrics_comparison (untuned baseline)
- **Week 6**: Show timeseries plots to explain signals/ICD
- **Week 9**: Show requirements dashboard before PDR
- **Week 11**: Show comparison (before vs after tuning)

## Customization

Edit plot functions to:
- Change colors/styles
- Add/remove subplots
- Adjust requirement thresholds
- Add annotations

---

For questions: asitha@uom.lk
