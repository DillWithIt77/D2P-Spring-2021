# D2P-Spring-2021
This project was done as part of the Integer Programming course for the University of Colorado Denver for Spring 2021. This project was also presented at the Data to Policy Symposium on April 30th, 2021. Below are some notes about running the code for this project.

1) The jupyternotebook was used to import the data and remove rows and columns that were not need for the project. The notebook itself contains comments on which rows and columns are removed and how they are reconstructed in order to be read into AMPL as acceptable inputs for the integer program. Note that the files output from this notebook are .csv files and they must be converted to .xls files in order to be read into AMPL. 

2) The D2P_spring.run file is what contains the information necessary to read in the .xls files which contain the positive and negative cases that are output from the jupyternotebook. There are a few steps that are done in order to prepare the .csv files to be converted to .xls files which are then read into AMPL. 
    1. First, column headings are added that correspond to the feature names and as well as a column that contains the number of samples. Currently, the final column (which is the indicator of whether or not the sample is a positive or negative case) is still output from the jupyternotebook, but work can be done to remove this so as not to create extra work for the .csv to .xls conversion. 
    2. Next, the final column (the case indicator column) must be removed. 
    3. Next, the table must be defined in Excel. (See https://trumpexcel.com/named-ranges-in-excel/ on how to do this.)
    4. Finally, save the file as a .xls file instead of a .csv file.
    5. You are now ready to have this be read into the AMPL program. 

3) Open AMPL and in the D2P_spring.run file, make sure the names of the tables match what you have called them in Excel. Also adjust the solver conditions if you would like to use a specific branch and bound method or simply let the solve do its thing. 
4) In the D2P_spring.dat file, define any groups you have for the features you have for the dataset you are sending in as well as a set of feature names that you used as your column headers in excel (excluding the column that has the number of samples in it). Notice there are already some tree structures defined, but feel free to add your own if you would like. 
5) Finally save any changes you made.
6) In the console in AMPL, type "include D2P_spring.run" which will run the.run file. You may or may not get compiler errors depending if you violated any of AMPL's conditions or missed any name/structure changes based on your dataset you are sending in. 
7) Boom, it runs and should give you an output. Notice in the .run file that it outputs the tables of the cases, group indicators, and feature indicators that are the solution to the program. You should be able to open these in Excel and view them.
8) Congrats you have successfully run this program for this project!
