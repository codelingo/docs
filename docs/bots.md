# Bots


### Overview

Bots listen for events in the SDLC, look for patterns and perform some action based on the pattern found. This automated end-to-end workflow we call a “BotFlow”. Below is an example of a BotFlow, created with our BotFlow Composer, which automates code reviews of pull requests to a git repository:
 
[image of botflow composer]
 

CLAIR (CodeLingo AI Reviewer) commenting on a pull-request.
 
Other examples of BotFlows include:
 
- A forensic Bot analyses logs and finds event B happened before A, which violates a Tenet
- A project overview Bot graphs Tech Debt burndown chart and delegates based on ownership
- A Copilot Bot gives real time feedback to a developer in their IDE as they’re coding
- A profiling Bot detects high memory usage correlated to similar code
- A crash report Bot monitors a running system and reports on unexpected runtime information