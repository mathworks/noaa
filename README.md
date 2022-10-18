# Getting Started with National Oceanic and Atmospheric Administration (NOAA)  in MATLAB&reg;

## Description

This interface allows users to access the NOAA directly from MATLAB.  Quantative and climate risk analysts can use the available data to make investment decisions based on climate data and weather patterns.

## System Requirements

- MATLAB R2022a or later
- Web services token supplied by NOAA: https://www.ncdc.noaa.gov/cdo-web/token

## Features

Users can retrieve NOAA data directly from MATLAB.   NOAA documentation for Datasets, Data Categories, Data Types, Location Categories, Locations, Stations and Data can be found here: 

https://www.ncdc.noaa.gov/cdo-web/webservices/v2

A valid NOAA connection is required for all requests.  Users can retrieve information required to make subsequent data requests.

## Create a NOAA connection.

```MATLAB
n = noaa("myNOAAToken");
```

## Retrieve datasets information

### Get all available datasets information or information for a specific dataset
```MATLAB
d = datasets(n);
d = datasets(n,"GSOY");
```

### Get data category information
```MATLAB
d = datacategories(n);
d = datacategories(n,"ANNAGR");
d = datacategories(n,[],"location","CITY:US390029","locationid","FIPS:37","limit",100);
```

### Get data types information
```MATLAB
d = datatypes(n);
d = datatypes(n,"ACMH");
d = datatypes(n,[],"datacategoryid","TEMP","limit",10);
d = datatypes(n,[],"stationid","COOP:310090");
```

### Get location category information
```MATLAB
d = locationcategories(n);
d = locationcategories(n,"CLIM_REG");
d = locationcategories(n,[],"startdate","1970-01-01");
```

### Get location information
```MATLAB
d = locations(n);
d = locations(n,"FIPS:37");
d = locations(n,[],"datasetid","GHCND");
d = locations(n,[],"locationcategoryid","ST","limit",52);
d = locations(n,[],"locationcategoryid","CITY","sortfield","name","sortorder","desc");
```

### Get station information
```MATLAB
d = stations(n)
d = stations(n,"COOP:010008")
d = stations(n,[],"locationid","FIPS:37")
d = stations(n,[],"datatypeid","EMNT","datatypeid","EMXT","datatypeid","HTMN")
```

### Get daily summary data for a given date range and location id
```MATLAB
d = getdata(n,"GHCND",datetime("2010-05-01"),datetime("2010-05-10"),"locationid","ZIP:28801")
```

### Aggregate daily temperature data into a timetable
```MATLAB
annualTemperatureData = [];
for y = 2015:2022
  annualTemperatureData = [annualTemperatureData;getdata(n,"GHCND", ...
                            datetime(strcat(num2str(y),"-01-01")), ... 
                            datetime(strcat(num2str(y),"-12-31")), ...
                            stationid  = "GHCND:SPE00119783", ...
                            datatypeid = "TAVG", ...
                            locationid = "FIPS:SP", ...
                            limit      = 1000, ...
                            units      = "metric")]; 
end

Temperature = annualTemperatureData.value;
Date = datetime(annualTemperatureData.date);
T = timetable(Date, Temperature);
head(T)
```

## License

The license is available in the LICENSE.TXT file in this GitHub repository.

Community Support

MATLAB Central

Copyright 2022 The MathWorks, Inc.
