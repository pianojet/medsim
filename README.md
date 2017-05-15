# Medical Simulation Analysis

**Author: Justin Taylor**

**Institution: University of Louisville, 2017**

**Extension for experimenting with new classifiers for speaker & emotion detection, based on Shuangshuang Jiang's Doctoral Thesis entitled _Speech Data Analysis for Semantic Indexing of Video of Simulated Medical Crises_**

http://ir.library.louisville.edu/etd/2070/


## Background:
The Simulation for Pediatric Assessment, Resuscitation, and Communication (SPARC) Program is a multidisciplinary, simulation-based educational program based at Norton Children’s Hospital. Among the goals of SPARC is the strengthening of clinician-patient interactions, an objective specifically addressed by the Program for the Approach to Complex Encounters (PACE). During this program, participants engage in simulated patient/family encounters using standardized patients that are video-recorded for future review and debriefing. At the present time this review is performed manually by course instructors, a time consuming process that often limits the amount of material that can be taught.  The development of software tools capable of automatically analyzing video data offers a potential way to make this process more efficient by freeing faculty for more focused interaction with the learners.  Several years ago development was initiated on such a tool by the Speed School of Engineering, but further work is needed to refine and train the software.

## Objective: 
The goal of this study is to further develop existing machine learning algorithms capable of recognizing and analyzing the nuances of clinician-patient interactions using pre-recorded communications skills focused simulations.  Enhancement of the speaker recognition and emotion detection features of the original software are the primary foci of the project.  

## Software
This repository contains the necessary MATLAB research software for two distinct uses:

1. an application comprised of 3 GUI's that facilitate the setup and execution of speaker & emotion detection
    1. GUI #1 allows the user to identify and select audio samples of speakers in given audio clips, and organize into distinct classes per speaker.
    2. GUI #2 allows the user to define models, choose signal features, and train & test classifiers based on the speaker classes organized in GUI #1.
    3. GUI #3 allows the user to select and apply classifiers from GUI #2 to new audio clips and applies the speaker and emotion classification process to return useful statistics pertinent to the objective.

2. experimental tools that facilitate research and testing of various feature and classifier configuration performance


## Entry Points

### GUI Applications:
1. GUI #1: `gui_medsim_model/medsim_gui.m`
2. GUI #2: `gui_medsim_train/medsim_train.m`
3. GUI #3: `gui_medsim_app/medsim.m`

### Experimentation:
1. `quicktrain/quicktrainassess.m`
    * experimental analysis tool (performs training & testing to assess a given configuration while output plots and statistics per `trial`):
2. `quicktrain/quicktrain_ga.m`
    * evolutionary (genetic) algorithm that searches for optimal classifier configurations among an evolving population

## Configuration
1. Application (emotion & speaker): `config/`
2. Experimentation: `quicktrain/config/`
