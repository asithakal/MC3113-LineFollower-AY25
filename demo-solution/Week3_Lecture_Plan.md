\# Week 3 Lecture: Line-Follower Demo



\## Timing: 50 minutes



\### Part 1: Project Overview (10 min)

\- Show project brief highlights

\- Explain scenarios S1/S2/S3

\- Discuss requirements and RTM



\### Part 2: Live Demo (20 min)

\- Show repo structure on main branch

\- Walk through ICD

\- Live run of instructor controller on S1

\- Show metrics computation

\- Display plots



\### Part 3: Student Guidance (15 min)

\- How to clone repo

\- How to implement my\_controller\_step.m

\- Show simple P controller example

\- Explain iterative tuning process



\### Part 4: Q\&A (5 min)



\## Demo Scripts to Run Live



```

% Setup

cd 'D:\\...\\LineFollowerDemo'

addpath('demo-solution', 'scripts', 'metrics', 'plotting');



% Quick S1 demo (use simple fidelity for speed)

run\_scenario\_simple('S1', @instructor\_controller, 'Live\_Demo\_S1');



% Compute metrics

m = compute\_metrics('logging/Live\_Demo\_S1.csv', 'S1')



% Show plot

plot\_timeseries('logging/Live\_Demo\_S1.csv', 'S1');

```



\## Backup Plan

\- Have pre-generated outputs ready

\- Screenshots in demo-materials/

\- Recorded video if live demo fails



