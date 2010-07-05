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

-module(topicgen).
-compile(export_all).

% check HackSense every Interval ms, change topic if necessary, quit @ quit msg
ircproc(Interval, Pid, HSURL, HSState) ->
	hacksense:send_if_newer(HSURL, HSState),
	ircproc(Interval, Pid, HSURL, HSState, false).
ircproc(Interval, Pid, HSURL, HSState, true) ->
	Pid ! {topic,
		"http://hspbp.org || " ++ hacksense:state_to_list(HSState)},
	ircproc(Interval, Pid, HSURL, HSState, false);
ircproc(Interval, Pid, HSURL, HSState, false) ->
	receive
		{hacksense, NewHSState} ->
			ircproc(Interval, Pid, HSURL, NewHSState, true);
		quit -> quit
		after Interval -> ircproc(Interval, Pid, HSURL, HSState)
	end.

% entry point for dnet's fork of erlang-ircbot
ircmain(Bot, HSURL) -> ircmain(Bot, HSURL, 90000).
ircmain(Bot, HSURL, Interval) ->
	spawn(?MODULE, ircproc, [Interval, Bot, HSURL, invalid]).
