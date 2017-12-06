# THE LA CITY HOMELESS PROJECT DOCUMENTATION

## BACKGROUND

Homelessness has been a growing problem in the city of Los Angeles. Both Measure H and Measure HHH were passed by the voters to grapple with the issue. Measure H is a sales tax measure to fund homeless programs and services and Measure HHH is a $1.2 billion bond measure to provide more affordable housing for the homeless people in the city. The city of Los Angeles asked our team to provide new risk measures for homeless people and recommend locations for building new shelters under the Measures.

## PROJECT GOAL AND SCOPE
Our objective was to help the Los Angeles City staff to investigate various homeless-related measures, so they can make better decisions as to where to allocate funding and resources, and in which areas to implement certain homeless intervention programs. In this project, we have developed a shiny dashboard that visualizes the density of the homeless as well as various safety risk measures. 

In order to accomplish this objective, first, we extracted multiple existing measures from the data of the homeless count in 2016 and 2017 collected by LAHSA--a subset of crime data provided by the city (victims were homeless people) and a subset of data from the 311 calls of LA city (regarding homeless encampment). Second, we created new measures such as ratio measures based on the available data. Third, we downloaded geospatial data of the LA County from online and merged it with our homeless-related measure data. 

After cleaning, manipulating and merging data, we created our shiny dashboard. In the shiny dashboard, Los Angeles City staff can select and/or combine any of the measures and the geographical level to create customized heat maps. As a secondary function, the dashboard allows Los Angeles City staff to look into crime data and shelters data for deep analyses. In the file Final Presentation for LA City Homeless Project (Group9).pdf, we describe our project in detail.

In Part I of this document, we describe each file in this folder. In Part II, we illustrate our data merging process. In Part III, we describe all the existing and new homeless related measures. In Part IV, we demonstrate an example analysis using our dashboard and provide general insights.

## Part I. Description of Files
File Name      | Description
----------------------------| -----------------------------------
Final Presentation for LA City Homeless Project(Group9).pdf|The file that describes the dashboard, summary of functions and insights we drew.
grp9App.R|The main shiny app script. It loads, merges, transforms data, creates new measures and calls shiny dashboard. Run grp9App.R to execute the dashboard.
dashboard/server.R|The server file for dashboard
dashboard/ui.R|The ui file for dashboard
dashboard/www|The folder containing LA city images for dashboard
data/311_calls_w_CTs20171102134828.csv|311 Calls data, including date, location and other action taken variables
data/crime_w_CTs20171102134814.csv|Crime data, including crime time, location, crime type and other related variables 
data/HC2016_Total_Counts_by_Census_Tract_LA_CoC_07132016.csv|Variety of types of homeless counts by census tract in 2016
data/homeless-count-2017-results-by-census-tract.csv|Variety of types of homeless counts by census tract in 2017 
data/homeless-count-2017-results-by-census-tract_by_community.csv|Homeless count in 2017 by community
data/lapop.rds|Population of different census tract and geometry information of census tract
data/LASpatialData.rda|Polygon data to create map presented in dashboard
data/shelters_w_CTs20171102134808,csv|Shelters information concerning location, services description, and contact method.

## Part II. Data Merging Process

First, we aggregated homeless count data at census tract level to get the homeless count data at community and city level. Therefore, we have homeless count data at three geographical levels.
Second, we merged crime data and 311 calls data with homeless count data at three geographical levels. 
Third, we merged the homeless-related measures data with geospatial data.

![dataflow](https://github.com/BenKang34/LACountyHomelessness/blob/master/images/dataflow.png)


## Part III. Homeless People Measures 
This section describes all measures available for investigation on our dashboard. III-1 refers to measures we extracted from the existing dataset. III-2 are new ratio measures we created based on the existing data. III-3 is an aggregated measure computed from measures in III-2. 

### III-1 Homeless Count Measures (Existing, 15)
Measure Name      |
----------------------------|
Total Homeless People
Total Unsheltered People
Total Unsheltered People(Log10 Scale)
Total Sheltered People
Total Sheltered People(Log10 Scale)
Total Street Single Adult
Total Street Family Members
Total Youth Family Households
Total Unaccompanied Kids in Shelters
Total Single Youth in Shelters
Total Unsheltered People(2016)
Crime Counts
311 Calls Counts
Shelter Counts
Change of Total Unsheltered People = Total Unsheltered People(2017) - Total Unsheltered People(2016)

### III-2 Risk Measures for Homeless (New Created,3)
Crime to Unsheltered People Ratio = Crime Count / Total Unsheltered People

311 Calls to Unsheltered People Ratio = 311 Calls  Count / Total Unsheltered People

Total Homeless People to Shelters Ratio = Total Homeless People / Shelter Counts


### III-3 Aggregated Measure (e.g. Shelters to be located)
Our final recommendation is based on some weighting scheme as follows: 

**Equation:**\
	(Shelters to be located) = w<sub>1</sub> x (CUR/CUR<sub>max</sub>)<sup>2</sup> + w<sub>2</sub> x (EUR/EUR<sub>max</sub>)<sup>2</sup> + w<sub>3</sub> x (THSR/THSR<sub>max</sub>)<sup>2</sup>
	
w<sub>1</sub>: Weight of Crime to Unsheltered Homeless People Ratio (“CUR”) by default 0.1 \
Crime to unsheltered homeless ratio demonstrates the safety risk of unsheltered homeless people are facing.

w<sub>2</sub>: Weight of 311 Calls to Unsheltered Homeless People Ratio (“EUR”) by default 0.2 \
311 calls to unsheltered homeless ratio reflects the density of unsheltered people in some extent, and partially reflect how tolerant people in the area are regarding homeless encampment.

w<sub>3</sub>: Weight of Total Homeless People to Number of Shelters Ratio (“THSR”) by default 0.7 \
Total number of homeless people to the number of shelters ratio demonstrate the magnitude of need for resources.
Note: When shelter number is 0, we add by 1 to allow the computation of ratio.



## Part IV. Example Analyses

Our dashboard includes three pages: the main dashboard, the crime dashboard and the 311 calls dashboard. We described the dashboard in detail in the Final Presentation for LA City Homeless Project(Group9).pdf

### Part IV-1 General Insights from the Main Dashboard

The following is the snapshot of our main dashboard.

![dashboard](https://github.com/BenKang34/LACountyHomelessness/blob/master/images/dashboard.png)

Using the aggregated measure we created (for more information about our measures, please refer to Part III-V3)., our dashboard visualizes the need for shelters in different communities. We recommend four communities for building new shelters, which are also placed on the top of the dashboard. 

Los Angeles City staff can customize the dashboard to further examine by choosing any of the three geographical levels, nineteen homeless measures and two overlay markers.

### Part IV-2 General Insights from the Crime Dashboard

![crime](https://github.com/BenKang34/LACountyHomelessness/blob/master/images/crime.png)

Our dashboard illustrates different types of crime where victims are the homeless people. We have included selection features of time interval and crime type to examine further. 

We can draw two insights from this page: first, the most common risk for unsheltered homeless people is assault. Second, midnight to 6am is a relatively safer period for homeless people. 

### Part IV-3 General Insights from 311 Calls Dashboard: Homeless Encampment

![311call](https://github.com/BenKang34/LACountyHomelessness/blob/master/images/311call.png)

In this page, Los Angeles City staff can set different threshold to see a bar graph of census tracts that have high frequency 311 calls. The heatmap will show these census tracts’ locations. 

From this map, we can see the top five census tracts with the highest frequency of 311 calls are located close to each other.


## Part V. Recommendations

Our recommendation for building new shelters within LA is:

**Encino**\
**Vermont Square**\
**Woodland Hills**\
**Studio City**

Our recommendation for building new shelters outside of LA is:

**Unincorporated Antelope Valley**\
**Unincorporated Palmdale**


