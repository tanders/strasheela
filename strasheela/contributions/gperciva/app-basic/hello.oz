%% ozc -x hello.oz
%% ./hello
functor
	import
		System Application
	define
	{System.showInfo 'hello world'}
	{Application.exit 0}
end
