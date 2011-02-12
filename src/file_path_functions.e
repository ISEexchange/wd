indexing
	description: "Objects that need this functionality should inherit."
	author: "Paul Morgan <jumanjiman@gmail.com>"

class
	FILE_PATH_FUNCTIONS

inherit
	OPERATING_ENVIRONMENT


feature -- convenience functions for dealing with file pathnames

	basename (s: STRING): STRING is
			-- basename of /some/path
		require
			s_not_void: s /= Void
		do
			create Result.make_from_string (s)
			Result.keep_tail (Result.count - Result.last_index_of (directory_separator, Result.count) )
		ensure
			not_void: Result /= Void
			new_string: Result /= s
				-- strings are really pointers
		end


	base2path (cmd, path: STRING): STRING is
			-- return absolute path of cmd within path, where:
			--  cmd is a basename (i.e., no directories in filename), and
			--  path is user's $PATH environment variable
			-- Returns Void if cmd not found in path

		require
			cmd_not_void: cmd /= Void and then not cmd.is_empty
			short_name: not cmd.has (directory_separator)
			path_exists: path /= Void and then not path.is_empty
		do
			Result := path_for_base (cmd, path)
			if Result /= Void then
				Result.append_character (directory_separator)
				Result.append_string (cmd)
			end
		ensure
			cmd_is_in_result: Result /= Void implies Result.has_substring (cmd)
			result_is_absolute: Result /= Void implies Result.item (1) = directory_separator
		end


	path_for_base (cmd, path: STRING): STRING is
			-- Returns the directory name in which cmd lives within path,
			-- where cmd should be a short name
			-- and path is formatted like $PATH environment variable
		require
			cmd_not_void: cmd /= Void and then not cmd.is_empty
			short_name: not cmd.has (directory_separator)
			path_exists: path /= Void and then not path.is_empty
		local
			dir: DIRECTORY
			dn: DIRECTORY_NAME
			dirs: LIST [STRING]
		do
			create dn.make
			dirs := path.split (':')
			from
				dirs.start
			until
				Result /= Void or dirs.off
			loop
				if dn.is_directory_name_valid (dirs.item_for_iteration) then
					create dir.make (dirs.item_for_iteration)
					if dir.exists and then dir.is_executable then
						dir.open_read
						if dir.has_entry (cmd) then
							create Result.make_empty
							Result.append_string (dir.name)
						end
						dir.close
					end
				end
				dirs.forth
			end -- loop
		ensure
			result_is_absolute: Result /= Void implies Result.item (1) = directory_separator
		end

	dir_name (path: STRING): STRING is
			-- Returns the directory part of `path'
		require
			path_exists: path /= Void and then not path.is_empty
		do
			create Result.make_from_string (path)
			Result.keep_head (path.count - basename (path).count)
		end


	path_exists (path: STRING): BOOLEAN is
			-- check to see whether path really exists
		require
			path_exists: path /= Void and then not path.is_empty
			absolute_path: path /= Void and then not path.is_empty and then path.index_of (directory_separator, 1) = 1
		local
			dir: DIRECTORY
			tmp_string: STRING
		do
			if path.last_index_of (directory_separator, path.count) = 1 then
					-- name ends with /
				create dir.make (path)
				Result := dir.exists
			else
				create tmp_string.make_from_string (path)
				tmp_string.keep_head (tmp_string.count - basename (path).count)
				create dir.make (tmp_string)
				if dir.exists and then (dir.is_readable and dir.is_executable) then
				--if dir.exists then
					dir.open_read
					Result := dir.has_entry (basename (path))
					dir.close
				end
			end
		end


end
