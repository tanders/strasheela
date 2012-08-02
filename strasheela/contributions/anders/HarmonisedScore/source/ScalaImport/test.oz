%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Test Scala Parser
%%

%%
%% Test scanner
%%

local 
   MyScanner = {New HS.scalaScanner.'class' init()}
   proc {GetTokens} T V in 
      {MyScanner getToken(?T ?V)}
      case T of 'EOF' then 
         {System.showInfo 'End of file reached.'}
      else 
         {System.show T#V}
         {GetTokens}
      end 
   end 
in
   %% TODO: generalise test file path name
   {MyScanner scanFile('/Users/torsten/oz/music/Strasheela/strasheela/strasheela/contributions/anders/HarmonisedScore/source/ScalaImport/ScalaChords-12ET.par')}
   {GetTokens}
   {MyScanner close()}
end 


%%
%% Test parser
%%

local 
   MyScanner = {New HS.scalaScanner.'class' init()}
   MyParser = {New HS.scalaParser.'class' init(MyScanner)}
   Chords Status
in 
   {MyScanner scanFile('/Users/torsten/oz/music/Strasheela/strasheela/strasheela/contributions/anders/HarmonisedScore/source/ScalaImport/ScalaChords-12ET.par')}
   {MyParser parse(database(?Chords) ?Status)}
   {MyScanner close()}
   if Status then 
      {Browse Chords}
      {System.showInfo 'accepted'}
   else 
      {System.showInfo 'rejected'}
   end 
end 

