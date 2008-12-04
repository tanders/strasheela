
%% The following is a documentation string which can be exported to HTML documentation using ozh. 

/** %% This functor serves as a template which shows how you can define a Strasheela extension. An extention is defined as an Oz functor. The explanation is this template should be sufficient for defining your first functor, for more details see http://www.ps.uni-sb.de/~niehren/Web/Vorlesungen/Oz-NL-SS01/vorlesung/node106.html#chapter.modprog and http://www.mozart-oz.org/documentation/apptut/index.html, Part I. The extension is compiled and installed with ozmake (http://www.mozart-oz.org/documentation/mozart-ozmake/index.html). You compile/install this functor at the commandline by moving into its directory and then entering simply

  ozmake --install

%% or, for re-compilation 

  ozmake --upgrade 

%% Moreover, if you store your functor in strasheela/contributions/yourname then it will be installed automatically (together with the rest of Strasheela) whenever you call the UNIX script strasheela/scripts/upgrade-all.sh (see also the related scripts there).       
%% */

functor  

import
   %% Put all others functors you depend on here and bind them to a variable.

   %% Most buildin Oz functors can be imported simply by stating their
   %% usual variable name here
   FD 
   
   %% Oz functors which are part of this extension can be stated
   %% simply with their path relative to the present file.
   Aux at 'source/MyFunctor.ozf'
   ClassDef at 'source/ClassDefinitionDemo.ozf'
   
   %% Other functors (e.g. Strasheela functors) require to specify
   %% their platform-independent URI. LUtils is not used in this
   %% functor (a warning would be shown at compilation time).
%    LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'   

   
export
   %% Put all your exported variables here (e.g. procedures, functions, classes, etc.).

   %% You export a value by specifying a functor feature (here add) an
   %% its corresponding value (here the constraint Add defined
   %% below). 
   add : Add
   
   %% For convenience, you can also export variables simply by stating
   %% them: a feature will be created implicitly form the variable
   %% name. Here, the functor Aus is exported as a subfunctor of
   %% MyExtension.
   Aux
   ClassDef

define
   %% Put all your definitions here.

   %% the following line is again a documentation string  which can be exported to HTML documentation using ozh.
   
   /** %% Declares X, Y, and Z to FD integers and defines X + Y = Z.
   %% */
   proc {Add X Y Z}
      X = {FD.decl}
      Y = {FD.decl}
      Z = {FD.decl}
      %%
      X + Y =: Z
   end   
   
end

