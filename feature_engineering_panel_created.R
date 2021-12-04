# rm(list = ls())
# set up
library(tidyverse)
library(sf)
library(lubridate)
library(tigris)
library(tidycensus)
library(gganimate)
library(viridis)
library(riem)
library(gridExtra)
library(knitr)
library(kableExtra)
library(RSocrata)
library(caret)
library(purrr)
library(FNN)
library(stargazer)
library(dplyr)
library(spatstat)
library(raster)
library(spdep)
library(grid)


palette5 <- c("#eff3ff","#bdd7e7","#6baed6","#3182bd","#08519c")
palette4 <- c("#D2FBD4","#92BCAB","#527D82","#123F5A")
palette4_2 <- c("#83c8f9","#2984c3","#075d9a","#000066")
palette2 <- c("#6baed6","#08519c")

source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

# import SF neighborhood boundaries
neighborhood_sf <-
  st_read("C:/Users/CSS/Desktop/508-final/Analysis Neighborhoods.geojson") %>%
  st_as_sf(coords = the_geom.coordinates, crs = 4326, agr = "constant") 

# import meters data
meters <-
  read.socrata("https://data.sfgov.org/resource/8vzz-qzz9.json") %>%
  dplyr::select(post_id, street_id, longitude, latitude) %>%
  na.omit()

meters_sf <-
  meters %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, agr = "constant")

# import street park records in a specific time span
street_parks <- 
  read.socrata("https://data.sfgov.org/resource/imvp-dq3v.json?$where=session_start_dt between '2019-01-01T12:00:00' and '2019-01-01T14:00:00'") %>%
  na.omit() %>%
  merge(meters, by="post_id")

street_parks_sf <-
  street_parks %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, agr = "constant") 


# fundamental plots of meters and street parks in neighborhoods
ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = meters_sf, colour="red", size=0.05, show.legend = "point") +
  labs(title= "Street Park Meters in San Francisco")
  
ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = street_parks_sf, colour="red", size=0.05, show.legend = "point") +
  labs(title= "Street Parks in San Francisco",
       subtitle = "From 2019-01-01 T12:00:00 to 2019-01-01 T14:00:00")

# Off-street Parking
off_parking <-
  read.socrata("https://data.sfgov.org/resource/vqzx-t7c4.json") %>%
  dplyr::select(objectid, osp_id, street_address, owner, capacity, main_entrance_long, main_entrance_lat) %>%
  na.omit() 

off_parking_sf <-
  off_parking %>%
  st_as_sf(coords = c("main_entrance_long", "main_entrance_lat"), crs = 4326, agr = "constant") %>%
  st_transform('ESRI:102243')

ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = off_parking_sf, colour="red", size=0.1, show.legend = "point") +
  labs(title= "Off-street Parking in San Francisco")

# sidewalk width
sidewalk <-
  st_read("C:/Users/CSS/Desktop/508-final/MTA.sidewalk_widths.geojson") %>%
  st_as_sf(coords = geometry, crs = 4326, agr = "constant") 

ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = sidewalk, colour="red",  show.legend = "point") +
  labs(title= "Sidewalks in San Francisco")

# speed limits
street_speed <-
  st_read("C:/Users/CSS/Desktop/508-final/Speed Limits per Street Segment.geojson") %>%
  st_as_sf(coords = geometry, crs = 4326, agr = "constant") %>%
  dplyr::select(cnn, st_type, speedlimit, street, from_st, to_st, geometry) %>%
  na.omit()

ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = street_speed, colour="red",  show.legend = "point") +
  labs(title= "Street Speed Limits in San Francisco")


# incidents
incidents <-
  read.socrata("https://data.sfgov.org/resource/wg3w-h783.json?$where=incident_date between '2021-07-16T00:00:00.000' and '2021-08-26T00:00:00.000'") %>%
  dplyr::select(incident_date, incident_day_of_week, incident_id, report_type_code, 
                incident_category, police_district, analysis_neighborhood, latitude, longitude) %>%
  na.omit() %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, agr = "constant")%>%
  st_transform('ESRI:102243')
  
ggplot() + 
  geom_sf(data = neighborhood_sf) +
  geom_sf(data = incidents, colour="red", size=0.1, show.legend = "point") +
  labs(title= "Police Incidents Parking in San Francisco",
       subtitle = "From 2021-07-16 to 2021-08-26")

# census data
census_api_key("e79f3706b6d61249968c6ce88794f6f556e5bf3d", overwrite = TRUE)

SF_census <- 
  get_acs(geography = "tract", 
          variables = c("B01003_001", "B19013_001", 
                        "B02001_002", "B08013_001",
                        "B08012_001", "B08301_001", 
                        "B08301_010", "B01002_001"), 
          year = 2019, 
          state = '06',      # '06' for California
          geometry = TRUE, 
          county = '075',    # '075' for San Francisco county
          output = "wide") %>%
  rename(Total_Pop =  B01003_001E,
         Med_Inc = B19013_001E,
         Med_Age = B01002_001E,
         White_Pop = B02001_002E,
         Travel_Time = B08013_001E,
         Num_Commuters = B08012_001E,
         Means_of_Transport = B08301_001E,
         Total_Public_Trans = B08301_010E) %>%
  dplyr::select(Total_Pop, Med_Inc, White_Pop, Travel_Time,
                Means_of_Transport, Total_Public_Trans,
                Med_Age, GEOID, geometry) %>%
  mutate(Percent_White = White_Pop / Total_Pop,
         Mean_Commute_Time = Travel_Time / Total_Public_Trans,
         Percent_Taking_Public_Trans = Total_Public_Trans / Means_of_Transport)


# street_parks <- 
#   read.socrata("https://data.sfgov.org/resource/imvp-dq3v.json?$where=session_start_dt between '2021-01-01T12:00:00' and '2021-01-31T14:00:00'") %>%
#   na.omit() %>%
#   merge(meters, by="post_id")

street_parks_0708 <- 
  read.socrata("https://data.sfgov.org/resource/imvp-dq3v.json?$where=session_start_dt between '2021-07-08T12:00:00' and '2021-07-08T12:15:00'") %>%
  na.omit() %>%
  mutate(week = week(session_start_dt),
         dotw = wday(session_start_dt, label = TRUE)) %>%
  merge(meters, by="post_id") %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, agr = "constant") %>%
  st_transform('ESRI:102243')

# select the study regions
selected_nhoods_list = c("North Beach", "Russian Hill", "Nob Hill", "Chinatown",
                    "Financial District/South Beach", "Tenderloin", "South of Market")
selected_nhoods_sf <-
  neighborhood_sf %>%
  filter(nhood %in% selected_nhoods_list)
ggplot() + 
  geom_sf(data = selected_nhoods_sf) 

# total study area
study_area <-
  st_union(selected_nhoods_sf) %>%
  st_sf %>%
  st_transform('ESRI:102243')
ggplot() + 
  geom_sf(data = study_area) 

# create the fishnet and count the parking number
fishnet_sf <- 
  st_make_grid(study_area,
               cellsize = 200, 
               square = TRUE) %>%
  .[study_area] %>%           
  st_sf() %>%
  mutate(uniqueID = rownames(.))

parking_net <- 
  dplyr::select(street_parks_0708) %>% 
  mutate(countPark = 1) %>% 
  aggregate(., fishnet_sf, sum) %>%
  mutate(countPark = replace_na(countPark, 0),
         uniqueID = rownames(.),
         cvID = sample(round(nrow(fishnet_sf) / 24), 
                       size=nrow(fishnet_sf), replace = TRUE))

ggplot() +
  geom_sf(data = parking_net, aes(fill = countPark), color = NA) +
  scale_fill_viridis() +
  labs(title = "Parking Counts in the fishnet")
# summary(parking_net)

ggplot(parking_net, aes(countPark)) + 
  geom_histogram(binwidth = 1, color = 'black', fill='white') +
  labs(title = "Parking Number Distribution in Each Fishnet Grid",
       subtitle = "2021-07-08 12:00-12:15")

ggplot() + 
  geom_sf(data = study_area) +
  geom_sf(data = meters_sf, colour="red", size=0.05, show.legend = "point") +
  labs(title= "Street Park Meters in San Francisco")

meters_sf <-
  meters_sf %>%
  st_transform('ESRI:102243')

# select the fishnet grids with meters
meter_net <- 
  dplyr::select(meters_sf) %>% 
  mutate(countMeters = 1) %>% 
  aggregate(., fishnet_sf, sum) %>%
  mutate(countMeters = replace_na(countMeters, 0),
         uniqueID = rownames(.),
         cvID = sample(round(nrow(fishnet_sf) / 24), 
                       size=nrow(fishnet_sf), replace = TRUE)) %>%
  filter(countMeters>0)

# plot fishnets with meters inside
ggplot() +
  geom_sf(data = meter_net, aes(fill = countMeters), color = NA) +
  scale_fill_viridis() +
  labs(title = "Fishnets with meters inside")

meter_net <-
  meter_net %>%
  dplyr::select(geometry, uniqueID)

parking_net <- 
  dplyr::select(street_parks_0708) %>% 
  mutate(countPark = 1) %>% 
  aggregate(., meter_net, sum) %>%
  mutate(countPark = replace_na(countPark, 0),
         uniqueID = rownames(.),
         cvID = sample(round(nrow(meter_net) / 24), 
                       size=nrow(meter_net), replace = TRUE))

# plot parking information in grids with meters
ggplot(parking_net, aes(countPark)) + 
  geom_histogram(binwidth = 1, color = 'black', fill='white') +
  labs(title = "Parking Number Distribution in Each Fishnet Grid",
       subtitle = "2021-07-08 12:00-12:15")

# ggplot() + 
#   geom_sf(data = study_area) +
#   geom_sf(data = meters_sf, colour="red", size=0.05, show.legend = "point") +
#   labs(title= "Street Park Meters in San Francisco")

# put police incidents into fishnet grids
incident_net <- 
  dplyr::select(incidents) %>% 
  mutate(countInci = 1) %>% 
  aggregate(., meter_net, sum) %>%
  mutate(countInci = replace_na(countInci, 0),
         uniqueID = rownames(.),
         cvID = sample(round(nrow(meter_net) / 24), 
                       size=nrow(meter_net), replace = TRUE))

ggplot() +
  geom_sf(data = incident_net, aes(fill = countInci), color = NA) +
  scale_fill_viridis() +
  labs(title = "Police Incidents in Fishnet Grids")

# Off-street Parking
centroid_fishnet <- st_centroid(meter_net) %>%
  dplyr::select(uniqueID, geometry)

ggplot() + 
  geom_sf(data = study_area) +
  geom_sf(data = centroid_fishnet, colour="red", size=0.05, show.legend = "point") +
  labs(title= "Centroid of Fishnet Grids")

# put all variables into fishnet
st_c <- st_coordinates
var_net <-
  parking_net %>% 
  dplyr::select(uniqueID, geometry, countPark) %>%
  mutate(
    off_parking.nn = nn_function(st_c(centroid_fishnet), st_c(off_parking_sf), 2),
    Incident = incident_net$countInci
  )

# create space-time panel
street_parks_0709 <- 
  read.socrata("https://data.sfgov.org/resource/imvp-dq3v.json?$where=session_start_dt between '2021-07-09T00:00:00' and '2021-07-09T23:00:00'") %>%
  na.omit() %>%
  mutate(week = week(session_start_dt),
         dotw = wday(session_start_dt, label = TRUE),
         interval60 = floor_date(ymd_hms(session_start_dt), unit = "hour"),
         interval15 = floor_date(ymd_hms(session_start_dt), unit = "15 mins")) %>%
  merge(meters, by="post_id") %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, agr = "constant") %>%
  st_transform('ESRI:102243')

street_park_grid <-
  st_join(
    street_parks_0709,
    var_net%>%
      dplyr::select(uniqueID, geometry, off_parking.nn, Incident),
    join=st_intersects,
    left = TRUE
  ) %>%
  na.omit() 

park.panel <- 
  expand.grid(interval60=unique(street_park_grid$interval60), 
              uniqueID = unique(street_park_grid$uniqueID)) %>%
  left_join(., street_park_grid %>%
              dplyr::select(post_id, session_start_dt, gross_paid_amt, 
                            interval60, interval15, 
                            uniqueID, off_parking.nn, Incident)%>%
              distinct() %>%
              group_by(uniqueID))

park.panel.count <- 
  street_park_grid %>%
  mutate(Park_Counter = 1) %>%
  right_join(park.panel) %>% 
  group_by(interval60, uniqueID) %>%
  summarize(Park_Count = sum(Park_Counter, na.rm=T)) %>%
  ungroup() %>%
  mutate(week = week(interval60),
         dotw = wday(interval60, label = TRUE))

# add time lag to the panel
park.panel.lag <- 
  park.panel.count %>% 
  arrange(interval60, uniqueID) %>% 
  mutate(lagHour = dplyr::lag(Park_Count,1),
         lag2Hours = dplyr::lag(Park_Count,2),
         lag3Hours = dplyr::lag(Park_Count,3)) %>%
  mutate(day = yday(interval60))

ggplot(park.panel.lag, aes(interval60, Park_Count)) + 
  geom_line() +
  scale_colour_manual(values = palette2) +
  labs(title="On-street Car Parks per hour, SF, 2021-07-09",
       x="Time", y="Number of Parking Records")




