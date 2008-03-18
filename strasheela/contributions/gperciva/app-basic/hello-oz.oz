%% works in the OPI now.
declare
functor HelloWorld
import
  Browser
  Application
define
  {Browser.browse 'hello world'}
%  {Application.exit 0}
end
[HelloModule] = {Module.apply [HelloWorld]}

