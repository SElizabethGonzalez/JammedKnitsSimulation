Code to generate contact force data.

To get contact force analysis out of the simulation, you can either run the stockinettecontactforces.py code on the ResultsOut.dat file of an already existing simulation, or copy the floofforce() and contactenergy() functions into the simulation.py file, replacing the existing contactenergy() function, and running new parameters.

To run the stockinettecontactforces.py code, you need a config file with the parameters from your simulation and the ResultsOut.dat file. Duplicate the ResultsOut.dat file and rename it as an "Init_X.dat" file and use this file as the initialization in your config file. This code replicates the output of your previous simulation, calculates the contact forces between each segment of yarn, and then rewrites the existing ContactMapOut.dat file to include the contact force data. The simulation outputs in this folder have had the stockinettecontactforces.py code run on them.

To analyze the contact force data from the simulation, run the "analyzesimdata.nb" notebook and copy the minEnergy list generated into the "analyzecontactforcesinoutx.nb" (or the y version depending on the extension direction). This code will group the yarn segment contacts into self-contacts, same row contacts, etc. The sign indicates if the force is pushing the stitch in (positive, compression) or out (negative, extension).
