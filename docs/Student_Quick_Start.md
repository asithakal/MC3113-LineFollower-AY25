\# MC3113 Line-Follower Quick Start



\## Setup (First Time)



1\. Clone the repository:

&nbsp;  ```

&nbsp;  git clone <student-repo-url>

&nbsp;  cd LineFollowerDemo

&nbsp;  ```



2\. Open MATLAB and navigate to the folder



3\. Add required paths:

&nbsp;  ```

&nbsp;  addpath('src', 'scripts', 'metrics', 'plotting');

&nbsp;  ```



\## Your First Test Run



1\. Open `src/my\_controller\_step.m` - this is your controller template



2\. Implement a simple P controller:

&nbsp;  ```

&nbsp;  function \[u\_L, u\_R] = my\_controller\_step(inputs)

&nbsp;      % Simple proportional controller

&nbsp;      Kp = -1.0;

&nbsp;      base\_speed = 0.4;

&nbsp;      

&nbsp;      steering = Kp \* inputs.e\_line;

&nbsp;      

&nbsp;      u\_L = base\_speed - steering;

&nbsp;      u\_R = base\_speed + steering;

&nbsp;      

&nbsp;      % Saturate commands

&nbsp;      u\_L = max(min(u\_L, 1.0), -1.0);

&nbsp;      u\_R = max(min(u\_R, 1.0), -1.0);

&nbsp;  end

&nbsp;  ```



3\. Run Scenario S1:

&nbsp;  ```

&nbsp;  run\_scenario('S1', @my\_controller\_step, 'Team##\_S1\_test001');

&nbsp;  ```



4\. Compute metrics:

&nbsp;  ```

&nbsp;  metrics = compute\_metrics('logging/Team##\_S1\_test001.csv', 'S1')

&nbsp;  ```



5\. Plot results:

&nbsp;  ```

&nbsp;  plot\_timeseries('logging/Team##\_S1\_test001.csv', 'S1');

&nbsp;  ```



\## Next Steps



\- Read `docs/Line-Follower-Project-Brief.md` for full requirements

\- Tune your controller to meet S1 requirements

\- Move on to S2 and S3 scenarios

\- Use `plotting/` functions to create report figures



\## Getting Help



\- Check TESTING\_CHECKLIST.md for troubleshooting

\- Email: asitha@uom.lk



