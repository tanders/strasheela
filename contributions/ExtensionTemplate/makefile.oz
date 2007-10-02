
makefile(
   %% The feature lib lists files which ozmake should create from your
   %% sources. You specify all paths relative to the directory in
   %% which this file is contained in. The file MyExtension.ozf is a
   %% compiled Oz functor, created from the functor defined in
   %% MyExtension.oz. Compiled functors can be linked by other
   %% Oz programs -- like MyExtension.oz links other functors in the
   %% import section.
   lib: ['MyExtension.ozf']
   %% The feature uri indicates the URI where the extension is
   %% installed. This URI is used for platform independent
   %% linking. Even if you install your extension on different
   %% computers and operating systems, this uri will always be the
   %% same.
   uri: 'x-ozlib://authorname/MyExtension'
   %% The feature mogul states an unique identifier for Mogul
   %% (http://www.mozart-oz.org/mogul/). This feature is required,
   %% even if you will not publish this extension on Mogul.
   mogul: 'mogul:/authorname/MyExtension'
   %% The author of this extension. 
   author: 'Author Name'
   )
