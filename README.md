# THE LA CITY HOMELESS PROJECT DOCUMENTATION

## BACKGROUND

Homelessness has been a growing problem in the city of Los Angeles. Both Measure H and Measure HHH were passed by the voters to grapple with the issue. Measure H is a sales tax measure to fund homeless services and program and Measure HHH is $1.2 billion bond measure to provide more affordable housing in the city. The city of Los Angeles asked our team to provide new risk measures for homeless people and recommend locations for building new shelters under the propositions.

## PROJECT GOAL AND SCOPE
In this project, we developed a shiny dashboard that visualizes homelessness density as well as other risk measures for homeless such as safety risk. Our objective was to help LA city staff investigate various homeless-related measures, so they can make decisions such as where to allocate funding and resources, which homeless intervention program to implement in a certain area, etc.

To accomplish this goal, first, we extracted multiple existing measures from 2017 and 2016 homeless count data collected by LAHSA, a subset of crime data from LA city (victims were homeless people), a subset of 311 calls data from LA city (regarding homeless encampment). Second, we created new measures based on the available data such as ratio measures. Third, we downloaded LA county geospatial data from online and merge it with our homeless-related measure data. 

After cleaning, manipulating, and merging data, we created our shiny dashboard. In the shiny dashboard, you can select any of the measures and any of the geographical level to create a customized heat map. As a secondary function, the dashboard also allows LA city staff to look into crime data and shelters data for deep analysis. In the file Final Presentation for LA City Homeless Project (Group9).pdf, we describe our project in detail.

In this document, in Part I., we describe each file in this folder. In Part II., we illustrate our data merging process. In Part III, we describe all the existing and new homeless related measures. Part IV is example analyses done using our dashboard and some insights.

## Part I. Description of files
File Name      | Description
----------------------------| -----------------------------------
Final Presentation for LA City Homeless Project(Group9).pdf|The file that describes the dashboard, summary of functions and insights we drew.
grp9App.R|The main shiny app script. It loads, merges, transforms data, creates new measures and calls shiny dashboard. 
Run grp9App.R to execute the dashboard.
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

## Part II: Data Merging Process

First, we aggregated homeless count data at census tract level to get the homeless count data at community and city level. So we have homeless count data at three geographical levels. 
Second, we merged crime data and 311 calls data with homeless count data at three geographical levels. 

Third, then we merge the homeless-related measures data with geo data. 

Part III : Homeless Measures 
This section describes all measures available for investigation on our dashboard. V-1 refers to measures we extracted from the existing dataset. V-2 are new ratio measures we created based on the existing data. V-3 is an aggregated measure computed from measures in V2. 

V-1 Homeless Count Measures (Existing, 15):
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

V-2 Risk Measures for Homeless (New Created,3)
Crime to Unsheltered People Ratio = Crime Count / Total Unsheltered People

311 Calls to Unsheltered People Ratio = 311 Calls  Count / Total Unsheltered People

Total Homeless People to Shelters Ratio = Total Homeless People / Shelter Counts


V-3 Aggregated Measure (e.g. Shelters to be located)
Our final recommendation is based on some weighting scheme as follows: 

Weight = 10% to Crime to Unsheltered Homeless Ratio (“CUR”).
Crime to unsheltered homeless ratio demonstrates the safety risk of unsheltered homeless people are facing.

Weight = 20% to 311 Calls to Unsheltered Homeless Ratio (“3UR”).
311 calls to unsheltered homeless ratio reflects the density of unsheltered people in some extent, and partially reflect how tolerant people in the area are regarding homeless encampment.

Weight = 70% to Total Homeless to Number of Shelters Ratio (“THSR”).
Total number of homeless people to the number of shelters ratio demonstrate the magnitude of need for resources.
Note: When shelter number is 0, we add by 1 to allow the computation of ratio.

Equation:
	Shelters to be located = 10% * (CUR^2) + 20% * (3UR^2) + 70% * (THSR^2)


## Part IV: Example Analyses

Our dashboard includes three pages: the main dashboard, the crime dashboard and the 311 calls dashboard. We described the dashboard in detail in the Final Presentation for LA City Homeless Project(Group9).pdf

### Part IV-1 Some Insights from the Main Dashboard

The following is the snapshot of our main dashboard.




Using the aggregated measure we created (For more information about our measures, please refer to Part III-V3)., our dashboard visualizes the need for shelters of different communities in LA cities. We recommend four communities for building new shelters, which are also placed on the top of the dashboard. 

You can customize the dashboard to further examine by choosing any of the three geographical levels, 19 Homeless measures and 2 overlay markers.

### Part IV-2 Some Insights from the Crime Dashboard


Our dashboard illustrates different types of crime where victims are the homeless people. We have included selection features to select the time interval as well as crime type to examine further. 

We can conclude two insights from this page: first, the most common risk for unsheltered homeless people is assault. Second, 6 am to 12 am is a relatively safer period for homeless people. 

### Part IV-3 Some Insights from 311 Calls Dashboard: Homeless Encampment


[311 ANALYSIS]

In this page, you can choose different threshold to see a bar graph of  census tracts that have high frequency 311 calls. The heatmap will show these census tracts’ locations. 

From this map, we can see the Top 5 census tracts that have high frequency 311 calls located close to each other.


## Part V: Recommendation

Our recommendation for building new shelters within LA is:

Encino
Vermont Square
Woodland Hills
Studio City

Our recommendation for building new shelters outside of LA is:

Unincorporated Antelope Valley
Unincorporated Palmdale


