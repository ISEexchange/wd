# Description of Eiffel command-line options is at:
# http://docs.eiffel.com/book/eiffelstudio/eiffelstudio-command-line-options

clean:
	@# wipe out binary and compile directories, if they exist
	rm -fr EIFGENs || :
	rm -f bin/wd || :

melt:
	@# fast compile, useful for iterative testing
	ec -melt -batch -config src/watchdog.ecf -c_compile
	@echo If the project compiled, you are ready to freeze or finalize

freeze: clean
	@# Compile to C with assertions, then compile executable.
	@# If the project compiles, the executable is at EIFGENs/wd/W_code/wd and bin/wd
	ec -freeze -batch -clean -config src/watchdog.ecf -c_compile
	@cp EIFGENs/wd/W_code/wd bin/

finalize: clean
	@# Make ready for final distribution.
	@# Full compilation, including dead code removal.
	@# If the project compiles, the executable is at EIFGENs/wd/F_code/wd and bin/wd
	ec -finalize -batch -clean -config src/watchdog.ecf -c_compile
	@cp EIFGENs/wd/F_code/wd bin/
