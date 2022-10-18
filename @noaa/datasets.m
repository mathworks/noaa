function [d,response] = datasets(c,id,varargin)
%DATASETS NOAA dataset information.
%   [DATA,RESPONSE] = DATASETS(C) returns up to 25 records containing
%   information pertaining to the available NOAA datasets
%
%   [DATA,RESPONSE] = DATASETS(C,ID) returns the dataset information for a 
%   given dataset identifier, ID.  C is the NOAA 
%   object.
%
%   [DATA,RESPONSE] = DATASETS(C,ID,VARARGIN) returns dataset information.
%   C is the NOAA object, ID is a dataset identifier and VARARGIN is name 
%   and value parameters supported by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
datasetsUrl = strcat(c.URL,"datasets");
if exist('id','var') && ~isempty(id)
  datasetsUrl = strcat(datasetsUrl,"/",id);
end

% Add name value pairs
if nargin > 2
  datasetsUrl = strcat(datasetsUrl,"?");

  for i = 1:2:length(varargin)
    datasetsUrl = strcat(datasetsUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end

HttpURI = matlab.net.URI(datasetsUrl);

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
    case {"uid","name","id"}
      d.(varNames{i}) = string(d.(varNames{i}));
    case {"mindate","maxdate"}
      d.(varNames{i}) = datetime(d.(varNames{i}));
  end
end