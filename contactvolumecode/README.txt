Once you have run the simulation and used "analyzesimdata.nb" to process, you can use the code here to apply the voxel method to find contact volumes.

The code "voxel.jl" uses the voxel method to calculate the compressed volume for a series of simulations. This Julia code was written for Julia version 1.8.5.

This code outputs a CSV file. The CSV records the length of yarn per stitch; the x, y, and z cell dimensions; the compressed volume; the stitch cell volume; and the packing fraction.

The Mathematica notebook "visualizecontactvolumes.nb" also conducts the same analysis as "voxel.jl", but is only used for visualizing the contact volumes due to it's slower speed and the more dynamic plotting methods available in Mathematica.
