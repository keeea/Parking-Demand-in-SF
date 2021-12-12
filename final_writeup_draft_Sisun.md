# Final Write-up Draft
 - Lan Xiao
 - Sisun Cheng

## 1. Introduction and Background

The City and County of San Francisco, is a cultural, commercial, and financial center in the U.S. state of California. Located in Northern California, San Francisco is the fourth most populous in California, with 873,965 residents as of 2020. San Francisco is the 12th-largest metropolitan statistical area in the United States with about 4.7 million residents, and the fourth-largest by economic output, with a GDP of $592 billion in 2019.

San Francisco is also a popular tourist destination, which is known for its cool summers, fog, steep rolling hills, eclectic mix of architecture, and landmarks, including the Golden Gate Bridge, cable cars, the former Alcatraz Federal Penitentiary, Fisherman's Wharf, and its Chinatown district. With so many famous resorts, San Francisco attracts over 26.5 million visitors in 2019.

With such a large population and huge number of visitors, it is extraordinarily difficult to find a parking space in San Francisco, especially in the downtown San Francisco, or near the tourist destinations. Most residents as well as visitors have experienced cruising and cruising on the street to find just a place to accommodate their car. On-street parking hot spots cluster in the northeastern section of San Francisco, including Financial District, China Town, Fisherman’s Wharf, etc., where many commercial hot spots also gather here.

To solve the problem of parking shortage, the San Francisco Municipal Transportation Agency (SFMTA) has made great effort, and one of the effective methods is to carry out a better pricing plan for on-street parkings. San Francisco is one of the first cities to apply a dynamic park pricing method, many on-street parking meters only operate from Monday to Saturday, between 9am and 6pm. The parking fee rate differs by the day of the week and time of day. Generally, the parking fee rate in San Francisco is shown in the table below.

(Table 1)

## 2. Use Case

### 2.1 General Use Case

For this project, our main stakeholder is SFMTA which operates most of the on-street parking in San Francisco. We want to carry out a prediction model to help SFMTA with parking pricing process.

Many researchers and planners believe that parking is underpriced in the US, and therefore leading to parking shortage and overuse of parking facilities. According to Donald Shoup (2004), when curbside parking spaces are overcrowded, and vacant spaces are unavailable, drivers “cruise” in search of parking. Cruising creates negative externalities including congestion, air pollution and unnecessary fuel consumption. Thus, it is of vital importance to carry out suitable pricing method for on-street parking in San Francisco, and the demand-based dynamic pricing model is a good choice.

### 2.2 Demand-based Dynamic Pricing Model

The model works as follows, SFMTA sets a floating price according to a real-time demand or predicted demand, so that parking demand and supply can be balanced to keep a on-street parking vacancy of about 20-30%, minimizing the time it takes to find parking and minimizing the negative externalities.

To take full use of the demand-based dynamic pricing model, we need to identify the parking demands. Compared to real-time parking demands from the real-time parking data, predictions of parking demands can help SFMTA adjust their parking fee rate in advance, before the upcoming parking peaks, so that they can make more reasonable changes in price.

### 2.3 Our Goals

In this project, we aim to carry out a demand prediction model with satisfying spati0-temporal accuracy and generalizability in San Francisco region. Then we’d apply the prediction result of this model in the demand-based dynamic pricing model and design an APP to manage parking congestion through price manipulation in order to optimize occupancy and reduce traffic congestion. Our goal is to make the overall revenues rise, occupancy move towards target ranges on most streets and price changes have the intended impact on driver behavior in San Francisco.



## 3. Data Wrangling and Feature Engineering


## 4. Exploratory Analysis


## 5. Modeling and Validation


## 6. Applications

As is discussed above, we carry out a regression model to predict the future parking demands in San Francisco, and we reach a satisfying accuracy. This prediction model serves as important data scource for the demand-based dynamic pricing model. Considering our use case, we develop a web-based APP towards SFMTA, and the user interface is shown as follows.

 
Fig. x Spatial Interface of the Webpage

In this page (Fig. x), the APP gives a general sense of the spatial distribution of on-street parking demand. The time span can be selected by the selector, both real-time and predicted parking demand are integrated into this page.

 
Fig. x+1 Temporal Interface of the Webpage

In the page above (Fig. x+1), the APP focuses on the temporal distribution of the parking demand. Line charts and bar charts are applied to illustrate the change of parking demand across time. Users can also select the specific time series and fishnet grid ID with the selectors. When users click on Pricing Advice in the left bar, suggestions show up automatically according to the model prediction results.


## 7. Conclusions


