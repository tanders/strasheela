
%%
declare
%SendOSC = '/Users/t/Desktop/OSC/sendOSCFolder/sendOSC'
SendOSC = 'sendOSC'
proc {Exec Cmd Args}
   Pipe = {New Open.pipe
	   init(cmd:Cmd
		args:Args)}
in
   {System.showInfo
    {Pipe read(list:$   
	       size:all)}}
   {Pipe flush}
   {Pipe close}
end
proc {SendSCserver OSCcmd}
   Port = 57110
in
   {Exec SendOSC ['-r' Port OSCcmd]}
end
proc {SendSClang OSCcmd}
   Port = 57120 
in
   {Exec SendOSC ['-r' Port OSCcmd]}
end
%% setting server by option -h does not work, so use environment var
%% REMOTE_ADDR instead
{OS.putEnv 'REMOTE_ADDR' '127.0.0.1'}


{Exec SendOSC ['-h' '127.0.0.1' 57110 '/s_new,default,2000']}

% {Exec 'sndplay' '/Users/t/Sound/VirtualOrchestra/sounds/percussion/vibraphone/large-soft-bass-drum-beater/ordinario/vib-soft.bd-B3-ff.AIF'}

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% doing default
{SendSCserver '/s_new,default,2000'}

{SendSCserver '/n_set,2000,freq,500'}

{SendSCserver '/n_free,2000'}


%%%%%%%%%%%%%%%%%%
%% playing a soundfile (I could use this also to play CSound files more efficiently ;-)
{SendSCserver '/b_allocRead,1,sounds/a11wlk01.wav'}

% {SendSCserver '/b_allocRead,1,/Applications/SuperCollider_f/sounds/a11wlk01.wav'}

{SendSCserver '/s_new,helpPlayBuf,1000,0,0,bufnum,1,duration,2'}

% cmd above determines itself, this kills SC
% {SendSCserver '/n_free,1000,0,0'}

{SendSCserver '/b_free,1'}



%%%%%%%%%%%%%%%%%%%
%% doing a little Score: time tags (in seconds) are relative to predecessor,
%% i.e. how much to wait before progressing
declare
Score = [[0.0 '/s_new,default,2000']
	 [1.0 '/n_set,2000,freq,500']
	 [1.0 '/n_free,2000']]

%% Perform a Sequential, non-stopable
{ForAll Score
 proc {$ [TimeOffset Cmd]}
    {Delay {FloatToInt TimeOffset*1000.0}}
    {SendSCserver Cmd}
 end}

%% the same with timing info in milliseconds
%%
%% this shows how much wrong this simple technique performs..
%%
%% However, SC Score.play is no more fancy. Is also only performs a
%% deltaTime.wait
%%
%% For precise timing I may output a score in the list format of SC
%% Score and do NRT processing. But for checking I may just do it like
%% this?? 
local
   StartTime = {Property.get 'time.total'}
in
   {ForAll Score
    proc {$ [TimeOffset Cmd]}
       {Delay {FloatToInt TimeOffset*1000.0}}
       {Inspect ({Property.get 'time.total'}-StartTime)#Cmd}
       {SendSCserver Cmd}
    end}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sending something to SClang directly via OSC, on the SClang side I
%% first must create an OSCresponder which defines a function to
%% execute on a certain OSC command

{SendSClang 'hi'}

{SendSClang 'hi,SinOsc.ar(440)'}

'//'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% OZ book: soft RT programming
declare
fun {NewTicker}
   fun {Loop}
      X={OS.localTime}
   in
      {Delay 1000}
      X|{Loop}
   end
in thread {Loop} end
end

{Inspect {NewTicker}}

%% exactly one per second, but no regularity
declare
fun {NewTicker}
   fun {Loop T}
      T1={Time.time}
   in
      {Delay 900}
      if T1\=T
      then T1|{Loop T1}
      else {Loop T1}
      end
   end
in
   thread {Loop {Time.time}} end
end 

{Inspect {NewTicker}}

%% using time stamps in dumpOSC

%% Time tags are represented by a 64 bit fixed point number. The first 32 bits specify the number of seconds since midnight on January 1, 1900, and the last 32 bits specify fractional parts of a second to a precision of about 200 picoseconds. This is the representation used by Internet NTP timestamps.The time tag value consisting of 63 zero bits followed by a one in the least signifigant bit is a special case meaning "immediately."

% dumpOSC: If you have a hexadecimal number after the open bracket character, it will be used as the time tag. Since OSC time tags are 8 bytes, you can have up to 16 hex digits.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% almost OK
%%
%% * waiting must happen before check for Run/Stop
%%
%% * I must introduce bundles (e.g. eventOn/eventOff message pairs) which are not stopable, but the sequence of bundles can be stopped 
declare
Run = {Cell.new true}
proc {ExecuteScore Score}
   if {Cell.access Run}
   then
      [TimeOffset Cmd] = Score.1
   in
      {Delay {FloatToInt TimeOffset*1000.0}}
      {Inspect {OS.time}#{Time.time}#Cmd}
      {SendSCserver Cmd}
      {ExecuteScore Score.2}
   else skip
   end
end

{ExecuteScore Score}

{Cell.assign Run false}

%%
%% In case a Score is computationally to expensive for RT processing I
%% can always write an event list readable by the SC class Score for
%% NRT processing.
%%
%% Actually, I should do this in general to generate acurately timed
%% sound files (I don't really trust Delay, but for testing its timing
%% is pretty good)
%% 


/*
declare
Repeater = {New Time.repeat
	    setRepAll(final:proc {$} {Inspect done} end
		      number:{Length Score})} 

{ForAll Score
 proc {$ [TimeOffset Cmd]}
    {Delay {FloatToInt TimeOffset*1000.0}}
    {Inspect {OS.time}#{Time.time}#Cmd}
    {SendSCserver Cmd}
 end}
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% Timestamp
%%

%% OSC Time tags are represented by a 64 bit fixed point number. The first
%% 32 bits specify the number of seconds since midnight on January 1,
%% 1900, and the last 32 bits specify fractional parts of a second to
%% a precision of about 200 picoseconds. This is the representation
%% used by Internet NTP timestamps.The time tag value consisting of 63
%% zero bits followed by a one in the least signifigant bit is a
%% special case meaning "immediately."

%%  sendOSC: The OpenSound Control protocol includes space for a
%%  8-byte time tag in each bundle. By default, sendOSC uses the value
%%  1, meaning "do it immediately" as the time tag for every
%%  bundle. But you can put a time tag into a bundle by typing some
%%  stuff after the open bracket character that opens the
%%  bundle. 
%%
%% If you have a hexadecimal number after the open bracket character,
%% it will be used as the time tag. Since OSC time tags are 8 bytes,
%% you can have up to 16 hex digits.

declare
fun {SecondsPerYear}
   %% seconds/minute * minutes/hour * hours/day * days/year
   60*60*24*365
end
SECONDS_FROM_1900_to_1970 = {SecondsPerYear}*70
fun {CurrentSecond}
   SECONDS_FROM_1900_to_1970 = 2208988800
in
   {Time.time} + SECONDS_FROM_1900_to_1970
end
%% must add MaxNumber if I don't want no seconds fraction
%MaxNumber = [f f f f f f f f]
MaxNumber = 0xffffffff
%% ?? hex numbers are represented as lists of integers and atoms
% fun {DecimalToHexAux X N}
%    %% N is hex digits already output
%    if X < 15
%    then X
%    else X
%    end
% end
% fun {HexToDecimal X}
%    X
% end


{Show {CurrentSecond}}

{Show MaxNumber}
{Show {CurrentSecond} + MaxNumber}

%% Hex number in Oz
0xDadBeddedABadBadBabe


%% binary number in Oz
0b1001 


{VirtualString.toByteString 0b1001}

%% ?? how do I convert decimal to hex:
%% tmp output using Lisp (format nil "~X" <my number>)

%% 32 bit correspond to 4 byte, i.e. 8 hex digits

%% checking with sendOSC:
%% this timestap should be close to current timestap,
%% however, it outputs immediately
84162194ffffffff
%% Even this timestap produces output immediately:
c000000000000000
%% this timestap does not
d000000000000000


/*
%% VB
' convert from decimal to hexadecimal
' if you pass the Digits argument, the result is truncated to that number of 
' digits
'
' you should always specify Digits if passing negative values

Function Hex(ByVal value As Long, Optional ByVal digits As Short = -1) As String
    ' convert to base-16
    Dim res As String = Convert.ToString(value, 16).ToUpper()

    ' truncate or extend the number
    If digits > 0 Then
        If digits < res.Length Then
            ' truncate the result
            res = res.Substring(res.Length - digits)
        ElseIf digits > res.Length Then
            ' we must extend the result to the left
            If value >= 0 Then
                ' extend with zeroes if positive
                res = res.PadLeft(digits, "0"c)
            Else
                ' extend with "F"s if negative
                res = res.PadLeft(digits, "F"c)
            End If
        End If
    End If
    ' return to caller
    Return res
End Function


%% turbo pascal
A: Here is one 
possibility

  function HEXFN (decimal : word) : string;
  const hexDigit : array [0..15] of char = '0123456789ABCDEF';
  begin
    hexfn := hexDigit[(decimal shr 12)]
          + hexDigit[(decimal shr 8) and $0F]
          + hexDigit[(decimal shr 4) and $0F]
          + hexDigit[(decimal and $0F)];
  end;  (* hexfn *)

Here is another conversion example (from longint to binary string)

  function LBINFN (decimal : longint) : string;
  const BinDigit : array [0..1] of char = '01';
  var i     : byte;
      binar : string;
  begin
    FillChar (binar, SizeOf(binar), ' ');
    binar[0] := chr(32);
    for i := 0 to 31 do
      binar[32-i] := BinDigit[(decimal shr i) and 1];
    lbinfn := binar;
    end;  (* lbinfn *)
*/
