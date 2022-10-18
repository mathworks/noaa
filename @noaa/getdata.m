function [d,response] = getdata(c,id,startdate,enddate,varargin)
%GETDATA NOAA dataset data.
%   [DAT,RESPONSE] = GETDATA(C,ID,STARTDATE,ENDDATE) returns the data for a
%   given NOAA object C and dataset identifier ID for the date range
%   defined by STARTDATE and ENDDATE.
%
%   [DAT,RESPONSE] = GETDATA(C,ID,STARTDATE,ENDDATE,VARARGIN) returns the data for a
%   given NOAA object C and dataset identifier ID for the date range
%   defined by STARTDATE and ENDDATE. VARARGIN is name and value parameters
%   supported by the NOAA REST API.
%
%   See also NOAA.

% Copyright 2022 The MathWorks, Inc.

% Set request parameters
method = "GET";

% Create URL
dataUrl = strcat(c.URL,"data");

% Add datasetid
if exist("id","var") && ~isempty(id)
  varargin = [{"datasetid" id} varargin];
else
  error("datafeed:noaa:missingDataSetId","Dataset identifier required.")
end

% Add startdate
if exist("startdate","var") && ~isempty(startdate)
  startdate = matlab.datetime.compatibility.convertDatenum(startdate);
  startdate.Format = "yyyy-MM-dd";
  varargin{end+1} = "startdate";
  varargin{end+1} = string(startdate);
else
  error("datafeed:noaa:missingStartDate","Start date required.")
end

% Add enddate
if exist("enddate","var") && ~isempty(enddate)
  enddate = matlab.datetime.compatibility.convertDatenum(enddate);
  enddate.Format = "yyyy-MM-dd";
  varargin{end+1} = "enddate";
  varargin{end+1} = string(enddate);
else
  error("datafeed:noaa:missingEndDate","End date required.")
end

% Add name value pairs
if nargin > 1
  dataUrl = strcat(dataUrl,"?");

  for i = 1:2:length(varargin)
    dataUrl = strcat(dataUrl,varargin{i},"=",string(varargin{i+1}),"&");
  end
end
dataUrl{end}(end) = [];

HttpURI = matlab.net.URI(dataUrl);

HttpHeader = matlab.net.http.HeaderField("token",c.Token,"Content-Type","application/json; charset=UTF-8");
      
RequestMethod = matlab.net.http.RequestMethod(method);
Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

options = matlab.net.http.HTTPOptions('ConnectTimeout',200,'Debug',c.DebugModeValue);

% Send Request
response = send(Request,HttpURI,options);

if isfield(response.Body.Data,"results")
  d = struct2table(response.Body.Data.results);
else
  try
    d = struct2table(response.Body.Data);
  catch
    d = response;
  end
end