function [d,response] = locations(c,id,varargin)
%LOCATIONS NOAA location name and identifiers.
%   [DATA,RESPONSE] = LOCATIONS(C) returns up to 25 geographic location 
%   names and identifiers.  C is the NOAA object.
%
%   [DATA,RESPONSE] = LOCATIONS(C,ID) returns the geographic location 
%   name and identifier for a given geographic location identifier, ID.  C 
%   is the NOAA object.
%
%   [DATA,RESPONSE] = LOCATIONS(C,ID,VARARGIN) returns geographic location 
%   names and identifiers.  C is the NOAA object, ID is a geographic location 
%   identifier and VARARGIN is name and value parameters supported
%   by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
locationsUrl = strcat(c.URL,"locations");
if exist('id','var') && ~isempty(id)
  locationsUrl = strcat(locationsUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  locationsUrl = strcat(locationsUrl,"?");

  for i = 1:2:length(varargin)
    locationsUrl = strcat(locationsUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(locationsUrl);

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
    case {"mindate","maxdate"}
      d.(varNames{i}) = datetime(d.(varNames{i}));
  end
end