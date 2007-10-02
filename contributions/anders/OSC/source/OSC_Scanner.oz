%%% -*-oz-gump-*-
\switch +gump

%%
%% NB: this scanner works only for output of dumpOSC, no some other
%% textual representation of OSC
%%

functor
export 'class': OSC_Scanner
import
   System
   GumpScanner('class':GS)
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   
define
   
   scanner OSC_Scanner from GS
		       
   %% !!?? do I need to show line numbers?? Used for lex <.> below..
   attr LineNumber
   meth init()
      GumpScanner.'class', init()
      LineNumber <- 1
   end 
   meth getLineNumber($)
      @LineNumber
   end 
   
   lex digit = <[0-9]> end
   lex hexDigit = <[a-f0-9]> end
   lex letter = <[A-Za-z]> end
   %% FIXME: punctuation character: without :,;<>?!(){}[]
   lex punct = <[./\_]|"-"> end
   %% FIXME: any white space missing?
   %% white space
   lex white =  <[ \t]> end

   lex pos_int = <({digit})+> end
   lex neg_int = <"-"({digit})+>  end
   %% dumpOSC hex format: only lowercase letters, and no leading 0x
   lex hex_int = <({hexDigit})+> end
   %% never omit figure before .
   lex pos_float = <({digit}+"."{digit}*)> end
   lex neg_float = <"-"({digit}+"."{digit}*)> end
   %% dumpOSC alway surrounds strings by quotes -- clearly distinguishable from hex int
   lex string = <\"({letter}|{digit}|{punct}|{white})*\"> end
   %% does dumpOSC always put an addressPattern at beginning of a new line? 
   lex addressPattern = <^({letter}|{digit}|{punct})*> end
%   lex arg = <{int}|{float}|{string}> end

   lex <{pos_int}> S in
      GumpScanner.'class', getString(?S)
      GumpScanner.'class', putToken('int' {String.toInt S})
   end
   lex <{neg_int}> S in
      GumpScanner.'class', getString(?S)
      %% replace leading sign - with ~
      GumpScanner.'class', putToken('int' {String.toInt &~|S.2})
   end
   lex <{hex_int}> S in
      GumpScanner.'class', getString(?S)
      GumpScanner.'class', putToken('hex' S)
   end
   lex <{pos_float}> S in
      GumpScanner.'class', getString(?S)
      GumpScanner.'class', putToken('float' {String.toFloat S})
   end 
   lex <{neg_float}> S in
      GumpScanner.'class', getString(?S)
      %% replace leading sign - with ~
      GumpScanner.'class', putToken('float' {String.toFloat  &~|S.2})
   end
   lex <{string}> S in
      GumpScanner.'class', getString(?S)
      %% skip leading and trailing "
      GumpScanner.'class', putToken('string' {LUtils.butLast S.2})
   end
   lex <{addressPattern}> A in
      GumpScanner.'class', getAtom(?A)
      GumpScanner.'class', putToken('addressPattern' A)
   end

   lex <"["|"]"> A in 
      GumpScanner.'class', getAtom(?A)
      GumpScanner.'class', putToken1(A)
   end 
   
  lex <\n> 
     LineNumber <- @LineNumber + 1
  end
   
   lex <{white}> skip end
   
   lex <.> 
      {System.showInfo 'line '#@LineNumber#': unrecognized character'}
      GumpScanner.'class', putToken1('error')
   end 
 
   lex <<EOF>> 
      GumpScanner.'class', putToken1('EOF')
   end
   
end

end
