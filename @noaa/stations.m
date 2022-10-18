function [d,response] = stations(c,id,varargin)
%STATIONS NOAA station name and identifiers.
%   [DATA,RESPONSE] = STATIONS(C) returns up to 25 geographic station 
%   names and identifiers.  C is the NOAA object.
%
%   [DATA,RESPONSE] = STATIONS(C,ID) returns the geographic station 
%   name and identifier for a given station identifier, ID.  C is
%   the NOAA object.
%
%   [DATA,RESPONSE] = STATIONS(C,ID,VARARGIN) returns geographic station 
%   names and identifiers.  C is the NOAA object, ID is a geographic station 
%   identifier and VARARGIN is name and value parameters supported
%   by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
stationsUrl = strcat(c.URL,"stations");
if exist('id','var') && ~isempty(id)
  stationsUrl = strcat(stationsUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  stationsUrl = strcat(stationsUrl,"?");

  for i = 1:2:length(varargin)
    stationsUrl = strcat(stationsUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(stationsUrl);

HttpHeader = matlab.net.http.HeaderField("token",c.Token,"Content-Type","application/json; charset=UTF-8");
      
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

options = matlab.net.http.HTTPOptions('ConnectTimeout',200,'Debug',c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

try
  if isfield(response.Body.Data,"results")
    d = struct2table(response.Body.Data.results);
  else
    d = struct2table(response.Body.Data);
  end
catch
  d = response.Body.Data;
end

% Convert cell arrays to string arrays
varNames = d.Properties.VariableNames;
for i = 1:length(varNames)
  switch varNames{i}
      case {"name","id","elevationUnit"}
      d.(varNames{i}) = string(d.(varNames{i}));
    case {"mindate","maxdate"}
      d.(varNames{i}) = datetime(d.(varNames{i}));
  end
end