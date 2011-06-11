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
state(BaseUrl) -> state(BaseUrl, #hackstate{guid = ""}).
state(BaseUrl, Last) ->
	{ok, {{_, Status, _}, _, CSV}} = httpc:request(get,
		{BaseUrl ++ "/status.csv", [{"User-Agent", "hspbp-topicgen"},
			{"If-None-Match", Last#hackstate.guid}]}, [], []),
	case Status of
		304 -> Last;
		_ ->
			[GUID, Timestamp, State | _] = string:tokens(
				string:strip(CSV, right, $\n), ";"),
			#hackstate{
				guid = GUID, timestamp = Timestamp, state = list_to_integer(State)}
	end.

% convert a hackstate record into a string
state_to_list(#hackstate{timestamp = Timestamp, state = State}) ->
	case State of
		0 -> "CLOSED";
		_ -> "OPEN"
	end ++ " since " ++ string:left(Timestamp, 16).

% send a {hacksense, State} message if the state of HackSense has changed
send_if_newer() -> send_if_newer(?BASEURL).
send_if_newer(BaseUrl) -> send_if_newer(BaseUrl, invalid).
send_if_newer(BaseUrl, Last) -> send_if_newer(BaseUrl, Last, self()).
send_if_newer(BaseUrl, Last, Pid) ->
	spawn(fun() ->
		case state(BaseUrl, Last) of
			Last -> ok;
			New -> Pid ! {hacksense, New}
		end
	end).
