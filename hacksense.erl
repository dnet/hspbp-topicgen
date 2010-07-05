% Copyright (c) 2010 András Veres-Szentkirályi
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

-module(hacksense).
-compile(export_all).
-define(BASEURL, "http://vsza.hu/hacksense").

-include("hacksense.hrl").

% get hacksense state in a hackstate record
state() -> state(?BASEURL).
state(BaseUrl) ->
	{ok, {_, _, CSV}} = httpc:request(BaseUrl ++ "/status.csv"),
	[GUID, Timestamp, State | _] = string:tokens(
		string:strip(CSV, right, $\n), ";"),
	#hackstate{
		guid = GUID, timestamp = Timestamp, state = list_to_integer(State)}.

% convert a hackstate record into a string
state_to_list(#hackstate{timestamp = Timestamp, state = State}) ->
	case State of
		0 -> "CLOSED";
		_ -> "OPEN"
	end ++ " since " ++ Timestamp.
