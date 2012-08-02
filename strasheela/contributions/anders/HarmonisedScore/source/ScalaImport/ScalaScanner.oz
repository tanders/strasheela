%%% -*-oz-gump-*-
\switch +gump
\gumpscannerprefix 'scala'

%%
%% TODO:
%%
%% BUG:
%% OK - # and * are unrecognised characters. Seemingly these are special regular expressions chars, but how to deal with that?
%% OK - text in a string can start with a digit, so a string is not just containing text...
%% OK? - text separated at " includes white space before the "
%% - white space in text snippets gone, no way to later distinguish between 2nd and 2 nd (with both consist of an int and text)
%% - ratios (3:4:5:7) not broken down -- parenthesis must not be part of text


%%
%% Simplified def: only for one notation
%%
%% - As a list of relative steps of an equal temperament separated by dashes, like 4-3-3.
%%


functor
import
   System
   GumpScanner('class':GS)
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   
export
   'class': ScalaScanner
   
define
   
   scanner ScalaScanner from  GS
		       
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
      lex int = <{digit}+> end
      lex float = <{int}"."{int}> end

      lex alpha = <[A-Za-z]> end
      %% TODO: revise
      %% punctuation characters (some chars with special meaning in brackets are put extra..)
      %% Left out: , = ( ) 
      %% BUG: # and * are unrecognised characters. Seemingly these are special regular expressions chars, but how to deal with that?
      % lex punct = <[./\_:;<>?!\*&|$#-(){}]|"["|"]"> end
      lex punct = <[\.'/\_:;<>?!{}]|"*"|"&"|"|"|"$"|"\#"|"-"|"["|"]"> end
      % excluding some more chars, namely - / :
      lex punct_subset = <[.\_;<>?!{}]|"*"|"&"|"|"|"$"|"\#"|"["|"]"> end
      % lex punct = <\*|"#"|"&"> end
      %% any character except those listed -- not possible?
      % lex punct = <[^{alpha}{digit}{white},=\"]> end
      
      %% white space
      lex white =  <[ \t]> end
      lex linebreak =  <[\\]> end
      %% text may contain any printable character (including spaces)
      % lex text = <({alpha}|"=")({alpha}|{digit}|{punct}|{white})*> end
      lex text = <({alpha}|{punct_subset})({alpha}|{digit}|{punct})*> end 
      %% ? BUG: ? Should '=' be of class 'text' or an extra token?
      % lex text = <({alpha}|{punct_subset}|"=")({alpha}|{digit}|{punct})*> end 
      % lex string = <\"({alpha}|{digit}|{punct}{white})*\"> end 
      %% a string may contain any printable character except a double quote (and except newline)
      lex string = <\"[^\"]*\"> end 
      %% After leading char, text may contain any printable character except those listed (and except newline)
      % lex text = <({alpha}|"=")[^,=\"]*> end 
      %% Text may contain any printable character except those listed (and except newline)
      % lex text = <[^,=\" \t]*> end 

      lex comment = <^"!".*> end

      % %% TODO: better do this in lexer?      
      % %% As a list of absolute frequency ratios separated by colons, like 4:5:6
      % lex ratio_list = <{int}(:{int})+> end
      
      % %% TODO: better do this in lexer?      
      % lex ratio2 = <{int}/{int}> end
      % % lex ratio2_list = <{ratio2}+> end  %% TODO: handle white space 
      % lex cents_list = <{cents}+> end %% TODO: handle white space


      %% !! TODO:
      %% chord name notations
      %% - list of names preceeded by = if it begins with a digit, or if chord is list of tone names
      %% - names can be surrounded by "double quotes", and double quotes serves as separator between multiple names
      %%   there can be colons within double quotes
      %% - otherwise multiple names are separated by commas

      
      

      %% ??
      %% A Scala chord/scale spec starts at the beginning of a line
      %% TODO: 
      % lex chord = <^{digit}+> end


      
      lex <{int}> S in 
	 GumpScanner.'class', getString(?S)
	 GumpScanner.'class', putToken('int' {String.toInt S})
      end      
      lex <{float}> S in 
	 GumpScanner.'class', getString(?S)
	 GumpScanner.'class', putToken('float' {String.toFloat S})
      end 
      
      lex <{white}> skip end
      %% ? BUG: do I need the linebreaks in the parser?
      lex <{linebreak}> skip end

      lex <{text}> S in
	 GumpScanner.'class', getAtom(?S)
	 GumpScanner.'class', putToken('text' S)
      end
      lex <{string}> S in
	 %% TMP: for debugging output string with " as atom
	 GumpScanner.'class', getAtom(?S)
	 GumpScanner.'class', putToken('string' S)
	 % GumpScanner.'class', getString(?S)
	 % GumpScanner.'class', putToken('string' {LUtils.butLast S.2})
      end

      lex <"-"|\"|"="|","|"("|")"|":"> A in 
	 GumpScanner.'class', getAtom(?A)
	 GumpScanner.'class', putToken1(A)
      end

      
      lex <{comment}> A in 
	 GumpScanner.'class', getAtom(?A)
	 GumpScanner.'class', putToken('comment' A)	 
      end

      %% For reporting parsing errors with line number
      %% NOTE: does this only work if line breaks are never included in any other Gump rule?
      lex <\n> 
	 LineNumber <- @LineNumber + 1
	 GumpScanner.'class', putToken1('newline')
      end
      lex <.> A in
	 GumpScanner.'class', getAtom(?A)
	 {System.showInfo 'line '#@LineNumber#': unrecognized character: '#A}
	 GumpScanner.'class', putToken1('error')
      end 
 
      lex <<EOF>> 
	 GumpScanner.'class', putToken1('EOF')
      end
      % lex <<EOF>> 
      % 	 GumpScanner.'class', putToken1('EOF')
      % end
	 
   end

end
