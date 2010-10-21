indexing
	description: "Constants and compile-time tunables for timed_command. Feel free to inherit."

class
	WATCHDOG_CONSTANTS


feature -- some useful compile-time tunables

	default_expiration: INTEGER is 60
			-- in seconds

	max_expiration: INTEGER is 300
			-- 5 minutes

	termination_timeout: INTEGER is 1000
			-- Terminating a thread is an asynchronous procedure,
			-- so define a constant in milliseconds to wait in case the thread
			-- doesn't want to die.

	environment_var: STRING is "EXPIRATION"
			-- the name of the environment variable that we read
			-- to establish the timeout for user_cli

	report_verbosely: BOOLEAN is True
			-- describe in detail what we're doing

	should_use_stderr: BOOLEAN is True
			-- whether to user stderr for reporting to user.
			-- This applies only to our messages; any output
			-- from user_cli is passed along unchanged.

	max_retries: INTEGER is 5
			-- how many times to retry terminating a thread that won't go away

	version: REAL is 0.9
			-- wd version


feature -- labels

	-- wd uses these grep-able labels on its output to inform user
	-- what is happening. The intention is to provide something that
	-- consistent that the user can use for grep in output (stderr by default)

	label_time_limit_exceeded: STRING is "wd time-limit exceeded: "
			-- label to be used when informing user that user_cli exceeded time limit

	label_launch_ok: STRING is "wd launch ok: "
			-- label to be used when informing user that user_cli is started ok

	label_internal_launch_fail: STRING is "wd internal launch fail: "
			-- failed to start user_cli due to internal failure
			-- (as opposed to problem with user_cli)

	label_time_limit_ok: STRING is "wd time-limit ok: "
			-- user_cli finished within time-limit/expiration
			-- wd's exit status is equal to user_cli's exit status

	label_not_executable: STRING is "wd requested command not executable: "
			-- user's command is not executable

	label_command_not_found: STRING is "wd command not found: "
			-- user's command was not found in path

	label_successful_termination: STRING is "terminated%N"

	label_failed_termination: STRING is "failed (look out for zombies)%N"


feature -- error/exit codes

	invalid_user_cli: INTEGER is 125
			-- user_cli is invalid filename

	user_command_not_executable: INTEGER is 124
			-- user_command is not executable by user

	missing_arguments: INTEGER is 123

	time_limit_exceeded: INTEGER is 210
			-- watchdog counted down ;-)

	kill_failure: INTEGER is 255
			-- watchdog tried but failed to kill worker thread

	command_failure: INTEGER is 122
			-- generic failure to start user_cli in worker thread

	command_not_found: INTEGER is 1
			-- user_command was not found in user's PATH

end
