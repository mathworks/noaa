classdef noaa < handle
%NOAA National Oceanic and Atmospheric Administration connection.
%   C = NOAA(TOKEN,TIMEOUT) creates a NOAA connection object using the 
%   TOKEN.  TOKEN can be input as a string scalar or character vector.  
%   TIMEOUT is the request value in milliseconds and input as a numeric 
%   value. The default value is 200 milliseconds. C is an noaa object.
%
%   For example,
%   
%   c = noaa("tokenstring")
%
%   returns
%
%   c = 
%   
%     noaa with properties:
%   
%       TimeOut: 200.00

%   Copyright 2022 The MathWorks, Inc. 

  properties
    TimeOut
  end
  
  properties (Hidden = true)
    DebugModeValue
    MediaType
    URL   
  end
  
  properties (Access = 'private')
    Token 
  end
  
  methods (Access = 'public')
  
      function c = noaa(apiToken,timeout,url,mediatype,debugmodevalue)
         
        %  Registered noaa users will have an authentication token
        if nargin < 1
          error("datafeed:noaa:missingToken","NOAA token required for data requests.");
        end
        
        % Timeout value for requests
        if exist("timeout","var") && ~isempty(timeout)
          c.TimeOut = timeout;
        else
          c.TimeOut = 200;
        end
        
        % Set URL
        if exist("url","var") && ~isempty(url)
          c.URL = url;
        else
          c.URL = "https://www.ncdc.noaa.gov/cdo-web/api/v2/";
        end

        % Specify HTTP media type i.e. application content to deal with
        if nargin < 4 || isempty(mediatype)
          HttpMediaType = matlab.net.http.MediaType("application/json; charset=UTF-8");
        else
          HttpMediaType = matlab.net.http.MediaType(mediatype);
        end
        c.MediaType = string(HttpMediaType.MediaInfo);
       
        % Debug value for requests
        if exist("debugmodevalue","var") && ~isempty(debugmodevalue)
          c.DebugModeValue = debugmodevalue;
        else
          c.DebugModeValue = 0;
        end

        % Check valid 
        % Set request parameters
        method = "GET";
        
        HttpURI = matlab.net.URI(c.URL);

        HttpHeader = matlab.net.http.HeaderField("token",apiToken,"Content-Type",c.MediaType);
      
        RequestMethod = matlab.net.http.RequestMethod(method);
        Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);

        options = matlab.net.http.HTTPOptions('ConnectTimeout',c.TimeOut,'Debug',c.DebugModeValue);

        % Send Request
        response = send(Request,HttpURI,options);

        % Check for response error
        switch response.StatusCode

          case "NotFound"
          
            error("datafeed:noaa:invalidURL",strcat("URL not found. Status code: ", string(response.StatusCode)))

          case "OK"

            % Valid connection response

          otherwise
            responseError = response.Body.Data;
            error("datafeed:noaa:connectFailure",strcat(responseError.message," Status code: ",responseError.status))
        
        end

        % Store token in object
        c.Token = apiToken;

      end
          
  end
  
  methods (Static)

  end

end