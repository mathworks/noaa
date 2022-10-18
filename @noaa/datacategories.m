function [d,response] = datacategories(c,id,varargin)
%DATACATEGORIES NOAA data category name and identifiers.
%   [DATA,RESPONSE] = DATACATEGORIES(C) returns up to 25 category names
%   and identifiers.  C is the NOAA object.
%
%   [DATA,RESPONSE] = DATACATEGORIES(C,ID) returns the category name
%   and identifier for a given category identifier, ID.  C is the NOAA 
%   object.
%
%   [DATA,RESPONSE] = DATACATEGORIES(C,ID,VARARGIN) returns category names
%   and identifiers.  C is the NOAA object, ID is a category identifier and
%   VARARGIN is name and value parameters supported by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
datacatagoriesUrl = strcat(c.URL,"datacategories");
if exist('id','var') && ~isempty(id)
  datacatagoriesUrl = strcat(datacatagoriesUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  datacatagoriesUrl = strcat(datacatagoriesUrl,"?");

  for i = 1:2:length(varargin)
    datacatagoriesUrl = strcat(datacatagoriesUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(datacatagoriesUrl);

HttpHeader = matlab.net.http.HeaderField("token",c.Token,"Content-Type","application/json; charset=UTF-8");
      
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

options = matlab.net.http.HTTPOptions('ConnectTimeout',200,'Debug',c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

% Convert output to table
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