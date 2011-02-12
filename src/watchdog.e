indexing
	description	: "[
		Implementation of a straightforward duel.
		
		Main thread executes user command within shell, but a watchdog
		thread kills the command if it fails to finish in a reasonable
		amount of time. 
		
		See `show_usage' below for more details.
		]"
	author: "Paul Morgan <jumanjiman@gmail.com>"
	date: "$Date$"
	revision: "$Revision$"

class
	WATCHDOG

inherit
	ARGUMENTS

	EXCEPTIONS

	FILE_PATH_FUNCTIONS

	WATCHDOG_CONSTANTS

create
	make


feature -- help

	show_usage is
			-- print help to stderr
		do
			output.put_string ("Usage: ")
			output.put_string (basename(Command_name))
			output.put_string (" [/path/to/]command [arguments]%N")
			output.put_string (basename(command_name) + " version ")
			output.put_real (version)
			output.put_string (" runs command with optional arguments.%N")
			output.put_string (basename(command_name) + " provides current working dir and environment to command.%N")
			output.put_string ("If command fails to complete within ")
			output.put_string (environment_var + " seconds,%N")
			output.put_string ("then a watchdog thread terminates the command.%N")
			output.put_string ("If command finishes before " + environment_var + ", then the watchdog is killed.%N")
			output.put_string ("If " + environment_var + " does not exist or is outside the range 1-")
			output.put_integer (max_expiration)
			output.put_string (",%Nthen it defaults to ")
			output.put_integer (default_expiration)
			output.put_string (" seconds.%N")
			output.put_string ("Example:%N")
			output.put_string ("%Texport " + environment_var + "=25%N")
			output.put_string ("%T" + basename (command_name) )
			output.put_string (" cat /etc/redhat-release%N")
			output.put_string ("Caveat: command may not be an alias or a shell built-in (yet).%N")
		end




feature {NONE} -- Initialization

	make is
			-- Run application.
		do
			if
				argument_count < 1
			then
				error_code := missing_arguments
				show_usage
			else
				parse_command_line
				if error_code = command_not_found then
					output.put_string (label_command_not_found)
					output.put_string (command_line.split (' ').i_th (2) + "%N")
				elseif error_code = user_command_not_executable then
					output.put_string (label_not_executable)
					output.put_string (command_line.split (' ').i_th (2) + "%N")
				else
					run_user_cli (expiration)
				end
			end
			die (error_code)
		end



feature {NONE} -- implementation

	run_user_cli (seconds: INTEGER) is
			-- Run user_cli in a separate thread.
			-- If user_cli doesn't finish within `seconds' time,
			-- then terminate it.
			-- Set error code to one of:
			--   exit status of user_cli if it finished, OR
			--   `time_limit_exceeded' if it was terminated, OR
			--   other non-zero exit status if user_cli was invalid to start with
		require
			user_command_line_exists: user_command_line /= Void and then not user_command_line.is_empty
			launcher_exists: proc /= Void
		local
			msg: STRING
		do
			proc.launch
			if not proc.launched then
				error_code := command_failure
			else
				proc.wait_for_exit_with_timeout (seconds * 1000)
				if proc.has_exited then
						-- process exited on its own
					error_code := proc.exit_code
					if report_verbosely then
							-- facilitate an atomic write
						create msg.make_from_string (label_time_limit_ok)
						msg.append_string ("PID=")
						msg.append_integer (proc.id)
						msg.append_string (" finished. Use exit status to determine success or failure.%N")
						output.put_string (msg)
					end
				else
						-- proc has exceeded its expiration time,
						-- so time to kill it!
					error_code := time_limit_exceeded
					kill_proc
				end
			end
		ensure
			definition_of_success: error_code = 0 implies (proc.launched and proc.has_exited and proc.exit_code=0)
			meaningful_error_code: proc.launched implies (error_code=proc.exit_code or error_code=time_limit_exceeded)
			launch_failure: not proc.launched implies error_code = command_failure
		end

	parse_command_line is
			-- Parse the command-line and set:
			--   user_command: the command to execute
			--   user_command_line: the whole command line
		require
			sufficient_arguments: argument_count >= 1
		local
			path: STRING
			ufi: UNIX_FILE_INFO
		do
			create user_command_line.make_from_string (command_line)
			user_command_line.keep_tail (command_line.count - command_name.count)
			user_command_line.left_adjust

				-- make sure we have a path
			if user_command.has (directory_separator) then
					-- convert from relative to absolute path
				if user_command.index_of (directory_separator, 1) /= 1 then
					user_command_line.prepend_character (directory_separator)
					user_command_line.prepend (shell.current_working_directory)
				end
				if not path_exists (user_command) then
					error_code := command_not_found
				end
			else
					-- convert from basename to absolute path
				path := shell.get ("PATH")
				if not path.is_empty then
					path := path_for_base (user_command, path)
					if path = Void then
						error_code := command_not_found
					else
						user_command_line.prepend_character (directory_separator)
						user_command_line.prepend_string (path)
					end
				end
			end

			if error_code = 0 then
					-- file exists, so check executable
				create ufi.make
				ufi.update (user_command)
				if not ufi.is_access_executable then
					error_code := user_command_not_executable
				end
			end

		ensure
			if_command_not_found: user_command = Void implies error_code = command_not_found
			if_not_executable: user_command.is_empty implies error_code = user_command_not_executable
			stripped_wd: user_command_line.substring_index (command_name, 1) /= 1
			definition_of_success: error_code = 0 implies path_exists (user_command)
		end

	user_command: STRING is
			-- 1st word of user_command_line
		require
			user_command_line_exists: user_command_line /= Void and then not user_command_line.is_empty
		do
			Result := user_command_line.split (' ') @ 1
		ensure
			first_word_of_command_line: user_command_line.substring_index (Result, 1) = 1
		end


	user_command_line: STRING


	expiration: INTEGER is
			-- number of seconds after which to kill user_cli
		local
			tmp_string: STRING
		once
			Result := default_expiration
			tmp_string := shell.get (environment_var)
			if
				tmp_string /= Void and then tmp_string.is_integer
			then
				Result := tmp_string.to_integer
				if Result < 0 then
					Result := default_expiration
				elseif Result = 0 then
					Result := max_expiration
				elseif Result > max_expiration then
					Result := max_expiration
				end
			end
		ensure
			reasonable_expiration: Result > 0 and Result <= max_expiration
		end

	error_code: INTEGER

	shell: EXECUTION_ENVIRONMENT is
			-- reference to the shell
		once
			create Result
		end

	proc: PROCESS is
			-- A process launcher that enables us
			-- to start user_cli in a separate thread.
		require
			user_command_line_exists: user_command_line /= Void and not user_command_line.is_empty
		local
			factory: PROCESS_FACTORY
		once
			create factory
			--Result := factory.process_launcher_with_command_line (user_cli, shell.current_working_directory)
			Result := factory.process_launcher_with_command_line (user_command_line, shell.current_working_directory)

				-- make sure we pick up the current environment variables
			Result.set_environment_variable_table (shell.starting_environment_variables)

				-- make sure that any threads created by
				-- user_cli are within a process group
			Result.enable_launch_in_new_process_group

				-- retain the console
			Result.set_separate_console (False)

				-- allow user_cli to send stdout and stderr to console
			Result.enable_terminal_control

				-- report success or failure to launch user_cli
			Result.set_on_successful_launch_handler (agent show_pid_info)
			Result.set_on_fail_launch_handler (agent launch_failure)

				-- actions for meeting or missing expiration
			--proc.set_on_terminate_handler (agent terminator)
		ensure
			proc_exists: Result /= Void
			proc_has_control: Result.is_terminal_control_enabled
			correct_command: Result.command_line.is_equal (user_command_line)
		end

	kill_proc is
			-- kill the user_cli thread(s)
		require
			is_running: proc.is_running
		local
			retries: INTEGER
			msg: STRING
		do
			if retries = 0 then
					-- facilitate atomic write
				create msg.make_from_string (label_time_limit_exceeded)
				msg.append_string ("PID=")
				msg.append_integer (proc.id)
				msg.append_string (" after ")
				msg.append_integer (expiration)
				msg.append_string (" seconds...")
				output.put_string (msg)
			end

				-- terminate the entire process group!
			if retries < max_retries then
				proc.terminate_tree
			else
				proc.terminate
			end
			proc.wait_for_exit_with_timeout (termination_timeout)

			if proc.last_termination_successful then
				output.put_string (label_successful_termination)
			end

			if proc.is_running and retries > max_retries then
					-- time to give up
				output.put_string (label_failed_termination)
				error_code := kill_failure
			end
		ensure
			nonzero_error_code: error_code /= 0
			terminated: proc.force_terminated or else error_code = kill_failure
		rescue
			-- do something
			retries := retries + 1
			output.put_string (".")
			retry
		end

	output: PLAIN_TEXT_FILE is
			-- stdout or stderr
			-- This should probably be stderr just in case user_cli
			-- tries to read its stdin. We don't want our output going
			-- as input to user_cli!
		do
			if should_use_stderr then
				Result := io.error
			else
				Result := io.output
			end
		ensure
			consistent_with_tunable: (should_use_stderr and Result = io.error) or else Result = io.output
		end


	divider: STRING is
			-- a line of dashes
		once
			create Result.make_filled ('-', 60)
			Result.append_character ('%N')
		end

	double_divider: STRING is
			-- a line of '=' signs
		once
			create Result.make_filled ('=', 60)
			Result.append_character ('%N')
		end


feature  {NONE} -- agents

	show_pid_info is
			-- be informative if user_cli is successfully launched
		require
			path_to_command: user_command /= Void and then user_command.has (directory_separator)
		local
			msg: STRING
		do
			if report_verbosely then
					-- facilitate an atomic write
				create msg.make_from_string (label_launch_ok)
				msg.append_string ("PID=")
				msg.append_integer (proc.id)
				msg.append_string (" (" + proc.command_line + ")")
				msg.append_string (" using " + environment_var + "=")
				msg.append_integer (expiration)
				msg.append_string (" seconds%N")
				output.put_string (msg)
			end
		end

	launch_failure is
			-- be informative if user_cli fails to launch (our fault)
		do
			error_code := command_failure
			io.error.put_string (label_internal_launch_fail)
			io.error.put_string (" Something is seriously wrong.%N")
		ensure
			exit_code_is_nonzero: error_code /= 0
		end

end -- class WATCHDOG
