<div id="top"></div>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/gcharvin/DetecDiv">
    <img src="Tutorial/detecDiv_logo-01.png" alt="Logo">
  </a>
  <p align="center" style="font-size:30px">
    <i> Processing microscopy image sequences using Matlab, a graphical user-interface and deep learning classifiers </i>
    <br />
    <br />
  </p> 
</div>


<!-- ABOUT THE PROJECT -->
<div id="about"></div>

## About The Project ##


DetecDiv provides a comprehensive set of tools to analyze time microscopy images using deep learning methods. The software structure is such that data can be processed either at the command line or using a graphical user-interface. Detecdiv classification models include : image classification and regression, semantic segmentation, LSTM networks to analyze data and image timeseries. Please refer to our pre-print for further details about the software and its applications for yeast cell division counting and replicative lifespan analysis: 
    
<a href="https://elifesciences.org/articles/79519">
   DetecDiv, a deep-learning platform for automated cell division tracking and replicative lifespan analysis
  </a>
    
   Théo Aspert, Didier Hentsch, Gilles Charvin
    
   <a href="https://elifesciences.org/articles/79519"> https://doi.org/10.7554/eLife.79519  </a>
  
  
  
    
<p align="right">(<a href="#top">back to top</a>)</p>


<div id="installation"></div>

## Table of contents

<!-- TABLE OF CONTENTS -->

 <!-- <summary>Table of Contents</summary> -->
  <ol>
    <li><a href="#about">About the project</a></li>
    <li><a href="#installation">Installation procedure</a></li>
    <li><a href="#gui">User guide</a></li>
    <li><a href="#data">Available data and models</a></li>
    <li><a href="#demo">Demo project</a></li>
    <li><a href="#thanks">Acknowledgments</a></li>
  </ol>


## Installation procedure

We recommend using Matlab >= R2021a to ensure the compatibility of the software. DetecDiv requires the following toolboxes: 

-MATLAB                                                Version 9.10        (R2021a)

-Computer Vision Toolbox                               Version 10.0        (R2021a)

-Deep Learning Toolbox                                 Version 14.2        (R2021a)

-Image Processing Toolbox                              Version 11.3        (R2021a)

-Statistics and Machine Learning Toolbox               Version 12.1        (R2021a)

-Parallel Computing Toolbox                            Version 7.4         (R2021a)  (optional)

In addition, you will need to install specific Matlab addons by clicking the "add-ons" button in the matlab main window. Then search for "Googlenet", "Resnet50", and "Resnet18" to install these packages that correspond to pre-trained neural nets.

Make sure to include all DetecDiv folders and subfolders in the Matlab path using the "Set Path" in the main Matlab workspace.

<p align="right">(<a href="#top">back to top</a>)</p>

<div id="gui"></div>

## User guide ##

A guide on how to use the graphical user-interface can be found here: 

 <a href="https://github.com/gcharvin/DetecDiv/blob/master/Tutorial/GUI_tutorial.md">GUI User guide</a>
 
A list of command-line instructions to use DetecDiv in scripts or in the Matlab workspace can be found here: 

 <a href="https://github.com/gcharvin/DetecDiv/blob/master/Tutorial/commandline_tutorial.md">Command-line instructions</a>
 
 <p align="right">(<a href="#top">back to top</a>)</p>
 
 <div id="data"></div>
 
 ## Available datasets and models ##
 
 ### Trained models and annotated image trainingset bundle ###
 
All the classification models used in the  <a href="https://elifesciences.org/articles/79519"> paper </a> can be downloaded from Zenodo:

  <a href="https://zenodo.org/record/7018296#.Y9oVNnbMI9E"> This repository </a> contains classifiers used to score cell division and lifespan in different contexts (geometries, microscopes). Each .zip files contains the trained classification model, along with the training and validation annonated image datasets that were used to train and test the classfiers. The generalist model is located in a different <a href="https://zenodo.org/record/7112521#.Y9pNV3bMI9E"> This repository </a>. 
 


| Sample images and labels          |  Description | Link to the zip file
:-------------------------:|:-------------------------:|:----------------
 <img src="Tutorial/classifier_acar.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Trap geometry as used in the Acar lab | <a href="https://zenodo.org/record/7018296/files/acar40x_theo_1.zip?download=1"> Download </a>
 <img src="Tutorial/classifier_div_1.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Trap geometry as used in the Charvin lab with a 20x objective and the RAMM microscope | <a href="https://zenodo.org/record/7018296/files/div_1.zip?download=1"> Download </a>
 <img src="Tutorial/classifier_div_n60b_1.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Trap geometry as used in the Charvin lab with a 60x objective and a Nikon microscope | <a href="https://zenodo.org/record/7018296/files/div_n60b_1.zip?download=1"> Download </a>
  <img src="Tutorial/classifier_jo_theo_1.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Trap geometry similar to that used in the Qin lab | <a href="https://zenodo.org/record/7018296/files/jo_theo_1.zip?download=1"> Download </a>
  <img src="Tutorial/classifier_swain_div_1.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Trap geometry as used in the Swain lab | <a href="https://zenodo.org/record/7018296/files/swain_div_1.zip?download=1"> Download </a>
  <img src="Tutorial/classifier_segcellpaper_5.png" alt="acar" width="300">  |  Image sequence classification for cell contour segmentation. | <a href="https://zenodo.org/record/7018296/files/segcellpaper_5.zip?download=1"> Download </a>  
  <img src="Tutorial/classifier_generalist_1.png" alt="acar" width="300">  |  Image sequence classification for division and lifespan analysis. Works for any trap geometry listed above | <a href="https://zenodo.org/record/7112521/files/generalist_1.zip?download=1"> Download </a>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5771536.svg)](https://doi.org/10.5281/zenodo.5771536)

![zenodo 7112521](https://user-images.githubusercontent.com/5951608/216031808-5da79e07-fa4c-4f5c-aaf9-0d33a4de7cbc.svg)

 ### Individual images and classification models ###
 
 The repositories below contain datasets (training sets and validation sets) used to train classification models, as well as the trained model itself (.mat file). Unlike the "bundle" above, this respositories contain either images or the model, so they are not intended to be used seamlessly within Detecdiv. If you want to use a particular model within Detecdiv, please dowanload a "bundle" as indicated above. 
 
 | Description         |  Training set repository | Testset repository | Trained model 
:-------------------------:|:-------------------------:|:----------------:|:--------------
Image sequence classification for division and lifespan analysis. Trap geometry as used in the Charvin lab with a 20x objective and the RAMM microscope. Relates to Figure 1 in the <a href="https://elifesciences.org/articles/79519"> paper </a> (id01) | <a href="https://zenodo.org/record/6078462"> Link </a> |  <a href="https://zenodo.org/record/5866747"> Link </a> | <a href="https://zenodo.org/record/5553862"> Link </a>
Cell segmentation. Trap geometry as used in the Charvin lab with a 20x objective and the RAMM microscope. Relates to Figure 5 in the <a href="https://elifesciences.org/articles/79519"> paper </a> (id02) | <a href="https://doi.org/10.5281/zenodo.6077125"> Link </a> |  <a href="https://doi.org/10.5281/zenodo.6077125"> Link </a> | <a href="https://doi.org/10.5281/zenodo.5553851"> Link </a>
SEP detection within lifespan data. Relates to Figure 4 in the <a href="https://elifesciences.org/articles/79519"> paper </a> (id03) | <a href="https://doi.org/10.5281/zenodo.6075691"> Link </a> |  <a href="https://doi.org/10.5281/zenodo.6075691"> Link </a> | <a href="https://doi.org/10.5281/zenodo.5553829"> Link </a>



<div id="demo"></div>

## DetecDiv demo project ##
 
A demo project that contains all the necessary files (i.e. raw image files, ROIs, groudtruth data, classifier models, trained classifiers) to learn how to use DetecDiv can be found here: 

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5771536.svg)](https://doi.org/10.5281/zenodo.5771536)

<p align="right">(<a href="#top">back to top</a>)</p>

<div id="thanks"></div>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Many thanks to those who provided the necessary resources to make this project possible, including the <a href="https://charvin.igbmc.science">Charvin lab</a> group members, the <a href="https://www.igbmc.fr">IGBMC staff and facilities</a>. 

<p align="right">(<a href="#top">back to top</a>)</p>
 







<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/gcharvin/DetecDiv
[contributors-url]: https://github.com/gcharvin/DetecDiv/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/gcharvin/DetecDiv
[forks-url]: https://github.com/gcharvin/DetecDiv/network/members
[stars-shield]: https://img.shields.io/github/stars/gcharvin/DetecDiv
[stars-url]: https://github.com/gcharvin/DetecDiv/stargazers
[issues-shield]: https://img.shields.io/github/issues/gcharvin/DetecDiv
[issues-url]: https://github.com/gcharvin/DetecDiv/issues
[license-shield]: https://img.shields.io/github/license/gcharvin/DetecDiv
[license-url]: https://github.com/gcharvin/DetecDiv/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png



