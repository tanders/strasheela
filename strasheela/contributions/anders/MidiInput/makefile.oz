
makefile(
   lib: ['source/CSV_Scanner.so'
	 'source/CSV_Scanner.ozf'
	 'source/CSV_Parser.ozf'
	 'MidiInput.ozf']
   rules: o('source/CSV_Scanner.so': ozg('source/CSV_Scanner.ozf'))
   uri: 'x-ozlib://anders/strasheela/MidiInput'
   mogul: 'mogul:/anders/strasheela/MidiInput'
   author: 'Torsten Anders')
