function [d,response] = locationcategories(c,id,varargin)
%LOCATIONCATEGORIES NOAA location category name and identifiers.
%   [DATA,RESPONSE] = LOCATIONCATEGORIES(C) returns up to 25 location 
%   category names and identifiers.  C is the NOAA object.
%
%   [DATA,RESPONSE] = LOCATIONCATEGORIES(C,ID) returns the location 
%   category name and identifier for a given category identifier, ID.  C is
%   the NOAA object.
%
%   [DATA,RESPONSE] = LOCATIONCATEGORIES(C,ID,VARARGIN) returns location 
%   category names and identifiers.  C is the NOAA object, ID is a location 
%   category identifier and VARARGIN is name and value parameters supported
%   by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
locationcatagoriesUrl = strcat(c.URL,"locationcategories");
if exist('id','var') && ~isempty(id)
  locationcatagoriesUrl = strcat(locationcatagoriesUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  locationcatagoriesUrl = strcat(locationcatagoriesUrl,"?");

  for i = 1:2:length(varargin)
    locationcatagoriesUrl = strcat(locationcatagoriesUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(locationcatagoriesUrl);

HttpHeader = matlab.net.http.HeaderField("token",c.Token,"Content-Type","application/json; charset=UTF-8");
      
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

options = matlab.net.http.HTTPOptions('ConnectTimeout',200,'Debug',c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

if isfield(response.Body.Data,"results")
  d = struct2table(response.Body.Data.results);
else
  d = struct2table(response.Body.Data);
end

% Convert cell arrays to string arrays
varNames = d.Properties.VariableNames;
for i = 1:length(varNames)
  switch varNames{i}
    case {"name","id"}
      d.(varNames{i}) = string(d.(varNames{i}));
  end
end