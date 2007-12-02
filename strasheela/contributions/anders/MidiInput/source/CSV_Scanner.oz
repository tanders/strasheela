%%% -*-oz-gump-*-
\switch +gump


functor
export 'class': CSV_Scanner
import
   System
   GumpScanner
   
define

   scanner CSV_Scanner from  GumpScanner.'class'
	       
      attr LineNumber
      meth init()
	 GumpScanner.'class', init()
	 LineNumber <- 1
      end 
      meth getLineNumber($)
	 @LineNumber
      end

      lex digit = <[0-9]> end
      lex alpha = <[A-Za-z]> end
      %% punctuation characters (some chars with special meaning in brackets are put extra..)
      lex punct = <[./\_:,;<>?!(){}|]|"-"|"["|"]"> end	
      %% white space
      lex white =  <[ \t]> end
   
      %% A track is an integer at the beginning of a line
      lex track = <^{digit}+> end
      %% An integer consists of digits. Only positive integers are supported.
      lex int = <{digit}+> end
      %% A type consists of alphabetic chars and the _ char
      %% Missing: must start with upper case.
      lex type = <({alpha}|_)+> end
%    %% A string may contain any printable character (including spaces). Surrounding quotes are compulsary.
%    %% !!?? can this def cause any problems with quotes in strings?
      lex string = <\"({alpha}|{digit}|{punct}|{white})*\"> end
      %% A comment is a line starting with either char # or ;
      lex comment = <^[#;].*> end
   
      %% !! commas are ignored ;-)
      lex <","> skip end

      %% comments are ignored
      lex <{comment}> skip end

      lex <{track}> S in
	 GumpScanner.'class', getString(?S)
	 GumpScanner.'class', putToken('track' {String.toInt S})
      end
      %% NB: int must follow track (otherwise int always matches before track)
      lex <{int}> S in
	 GumpScanner.'class', getString(?S)
	 GumpScanner.'class', putToken('int' {String.toInt S})
      end
      lex <{type}> A in
	 GumpScanner.'class', getAtom(?A)
	 GumpScanner.'class', putToken('type' A)
      end
      lex <{string}> S in
	 GumpScanner.'class', getString(?S)
	 %% include leading and trailing quotes
	 GumpScanner.'class', putToken('string' S)
      end

      lex <\n> 
	 LineNumber <- @LineNumber + 1
      end
      %% white space is ignored
      lex <[ \t]> skip end
   
      lex <.> 
	 {System.showInfo 'line '#@LineNumber#': unrecognized character'}
	 GumpScanner.'class', putToken1('error')
      end 
 
      lex <<EOF>> 
	 GumpScanner.'class', putToken1('EOF')
      end
   
   end

end

