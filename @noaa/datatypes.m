function [d,response] = datatypes(c,id,varargin)
%DATATYPES NOAA data types information.
%   [DATA,RESPONSE] = DATATYPES(C) returns up to 25 records containing
%   information pertaining to the available NOAA data types.
%
%   [DATA,RESPONSE] = DATATYPES(C,ID) returns the data type information for a 
%   given data type identifier, ID.  C is the NOAA 
%   object.
%
%   [DATA,RESPONSE] = DATATYPES(C,ID,VARARGIN) returns data type information.
%   C is the NOAA object, ID is a data type identifier and VARARGIN is name 
%   and value parameters supported by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.
% Set request parameters
method = "GET";

% Create URL
datatypesUrl = strcat(c.URL,"datatypes");
if exist('id','var') && ~isempty(id)
  datatypesUrl = strcat(datatypesUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  datatypesUrl = strcat(datatypesUrl,"?");

  for i = 1:2:length(varargin)
    datatypesUrl = strcat(datatypesUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(datatypesUrl);

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
  % Unstructured data return
  d = response;
  return
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