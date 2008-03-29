/** %% TODO: general description of Intonation-funcs.  (test of doc-string) */

functor
import
%   FD
%   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   %% for debug
   %Browser

export
   firstPos: FirstPosition
define
   proc {FirstPosition Positions}
      {ForAll Positions proc {$ X} X =: 2 end}
   end

end
