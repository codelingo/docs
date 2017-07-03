# Bots
#### Agents Guiding Code Quaity at Scale

<br/>

### Overview

Bots listen for events in the SDLC, look for patterns and perform some action based on the pattern found. Our flagship bot is CLAIR (CodeLingo AI Reviewer). CLAIR automates code reviews of pull requests to a git repository:

<!--

This automated end-to-end workflow we call a “BotFlow”. Below is an example of a BotFlow, created with our BotFlow Composer, which automates code reviews of pull requests to a git repository:
 
todo: image of botflow composer 

 -->

<img src="/docs/img/clair_review_simple.png" alt="CLAIR (CodeLingo AI Reviewer) commenting on a pull-request" style="width: 80%;"/>

Other possible Bots include:
 
- A forensic Bot that analyses logs and finds event B happened before A, which violates a Tenet
- A project overview Bot that graphs Tech Debt burndown chart and delegates based on ownership
- A Copilot Bot that gives real time feedback to a developer in their IDE as they’re coding
- A profiling Bot that detects high memory usage correlated to similar code
- A crash report Bot that monitors a running system and reports on unexpected runtime information