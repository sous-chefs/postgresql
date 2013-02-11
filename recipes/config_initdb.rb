#
# Cookbook Name:: postgresql
# Recipe:: config_initdb
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#######
# This recipe is derived from the setup_config() source code in the
# PostgreSQL initdb utility. It determines postgresql.conf settings that
# conform to the system's locale and timezone configuration, and also
# sets the error reporting and logging settings.
#
# See http://doxygen.postgresql.org/initdb_8c_source.html for the
# original initdb source code.
#
# By examining the system configuration, this recipe will set the
# following node.default['postgresql']['config'] attributes:
#
# - Locale and Formatting -
#   * datestyle
#   * lc_messages
#   * lc_monetary
#   * lc_numeric
#   * lc_time
#   * default_text_search_config
#
# - Timezone Conversion -
#   * log_timezone
#   * timezone
#
# In addition, this recipe will recommend the same error reporting and
# logging settings that initdb provided. These settings do differ from
# the PostgreSQL default settings, which would log to stderr only. The
# initdb settings rotate 7 days of log files named postgresql-Mon.log,
# etc. through these node.default['postgresql']['config'] attributes:
#
# - Where to Log -
#   * log_destination = 'stderr'		
#   * log_directory = 'pg_log'		
#   * log_filename = 'postgresql-%a.log'
#     (Default was: postgresql-%Y-%m-%d_%H%M%S.log)
#   * logging_collector = true # on
#     (Turned on to capture stderr logging and redirect into log files)
#     (Default was: false # off)
#   * log_rotation_age = 1d			
#   * log_rotation_size = 0
#     (Default was: 10MB)
#   * log_truncate_on_rotation = true # on
#     (Default was: false # off)

#######
# Locale Configuration

# Function to test the date order.
def locale_date_order
    # Test locale conversion of mon=11, day=22, year=33
    testtime = DateTime.new(2033,11,22,0,0,0,"-00:00")
            #=> #<DateTime: 2033-11-22T00:00:00-0000 ...>

    # %x - Preferred representation for the date alone, no time
    res = testtime.strftime("%x")

    if res.nil?
       return 'mdy'
    end

    posM = res.index("11")
    posD = res.index("22")
    posY = res.index("33")

    if (posM.nil? || posD.nil? || posY.nil?)
        return 'mdy'
    elseif (posY < posM && posM < posD)
        return 'ymd'
    elseif (posD < posM)
        return 'dmy'
    else
        return 'mdy'
    end
end

node.default['postgresql']['config']['datestyle'] = "iso, #{locale_date_order()}"

# According to the locale(1) manpage, the locale settings are determined
# by environment variables according to the following precedence:
# LC_ALL > (LC_MESSAGES, LC_MONETARY, LC_NUMERIC, LC_TIME) > LANG.

node.default['postgresql']['config']['lc_messages'] =
  [ ENV['LC_ALL'], ENV['LC_MESSAGES'], ENV['LANG'] ].compact.first

node.default['postgresql']['config']['lc_monetary'] =
  [ ENV['LC_ALL'], ENV['LC_MONETARY'], ENV['LANG'] ].compact.first

node.default['postgresql']['config']['lc_numeric'] =
  [ ENV['LC_ALL'], ENV['LC_NUMERIC'], ENV['LANG'] ].compact.first

node.default['postgresql']['config']['lc_time'] =
  [ ENV['LC_ALL'], ENV['LC_TIME'], ENV['LANG'] ].compact.first

node.default['postgresql']['config']['default_text_search_config'] =
  case ENV['LANG']
  when /da_.*/
    'pg_catalog.danish'
  when /nl_.*/
    'pg_catalog.dutch'
  when /en_.*/
    'pg_catalog.english'
  when /fi_.*/
    'pg_catalog.finnish'
  when /fr_.*/
    'pg_catalog.french'
  when /de_.*/
    'pg_catalog.german'
  when /hu_.*/
    'pg_catalog.hungarian'
  when /it_.*/
    'pg_catalog.italian'
  when /no_.*/
    'pg_catalog.norwegian'
  when /pt_.*/
    'pg_catalog.portuguese'
  when /ro_.*/
    'pg_catalog.romanian'
  when /ru_.*/
    'pg_catalog.russian'
  when /es_.*/
    'pg_catalog.spanish'
  when /sv_.*/
    'pg_catalog.swedish'
  when /tr_.*/
    'pg_catalog.turkish'
  else
    nil
  end
  
#######
# Timezone Configuration
require 'find'

def validate_zone(tzname)
    # PostgreSQL does not support leap seconds, so this function tests
    # the usual Linux tzname convention to avoid a misconfiguration.
    # Assume that the tzdata package maintainer has kept all timezone
    # data files with support for leap seconds is kept under the
    # so-named "right/" subdir of the shared zoneinfo directory.
    #
    # The original PostgreSQL initdb is not Unix-specific, so it did a
    # very complicated, thorough test in its pg_tz_acceptable() function
    # that I could not begin to understand how to do in ruby :).
    #
    # Testing the tzname is good enough, since a misconfiguration
    # will result in an immediate fatal error when the PostgreSQL
    # service is started, with pgstartup.log messages such as:
    # LOG:  time zone "right/US/Eastern" appears to use leap seconds
    # DETAIL:  PostgreSQL does not support leap seconds.

    if tzname.index("right/") == 0
        return false
    else
        return true
    end
end

def scan_available_timezones(tzdir)
    # There should be an /etc/localtime zoneinfo file that is a link to
    # (or a copy of) a timezone data file under tzdir, which should have
    # been installed under the "share" directory by the tzdata package.
    #
    # The initdb utility determines which shared timezone file is being
    # used as the system's default /etc/localtime. The timezone name is
    # the timezone file path relative to the tzdir.

    bestzonename = nil

    if (tzdir.nil?)
        Chef::Log.error("The zoneinfo directory not found (looked for /usr/share/zoneinfo and /usr/lib/zoneinfo)")
    elsif !::File.exists?("/etc/localtime")
        Chef::Log.error("The system zoneinfo file not found (looked for /etc/localtime)")
    elsif ::File.directory?("/etc/localtime")
        Chef::Log.error("The system zoneinfo file not found (/etc/localtime is a directory instead)")
    elsif ::File.symlink?("/etc/localtime")
        # PostgreSQL initdb doesn't use the symlink target, but this
        # certainly will make sense to any system administrator. A full
        # scan of the tzdir to find the shortest filename could result
        # "US/Eastern" instead of "America/New_York" as bestzonename,
        # in spite of what the sysadmin had specified in the symlink.
        # (There are many duplicates under tzdir, with the same timezone
        # content appearing as an average of 2-3 different file names.)
        path = ::File.readlink("/etc/localtime")
        bestzonename = path.gsub("#{tzdir}/","")
    else # /etc/localtime is a file, so scan for it under tzdir
        localtime_content = File.read("/etc/localtime")

        Find.find(tzdir) do |path|
            # Only consider files (skip directories or symlinks)
            if !::File.directory?(path) && !::File.symlink?(path)
                # Ignore any file named "posixrules" or "localtime"
                if ::File.basename(path) != "posixrules" && ::File.basename(path) != "localtime"
            	    # Do consider if content exactly matches /etc/localtime.
            	    if localtime_content == File.read(path)
                        tzname = path.gsub("#{tzdir}/","")
            	        if validate_zone(tzname)
            	            if (bestzonename.nil? ||
            		        tzname.length < bestzonename.length ||
            		        (tzname.length == bestzonename.length &&
                                 (tzname <=> bestzonename) < 0)
                               )
            		        bestzonename = tzname
            		    end
            	        end
            	    end
            	end
            end
    	end
    end

    return bestzonename
end

def identify_system_timezone(tzdir)
    resultbuf = scan_available_timezones(tzdir)

    if !resultbuf.nil?
        # Ignore Olson's rather silly "Factory" zone; use GMT instead
        if (resultbuf <=> "Factory") == 0
            resultbuf = nil
        end

    else
        # Did not find the timezone.  Fallback to use a GMT zone.  Note that the
        # Olson timezone database names the GMT-offset zones in POSIX style: plus
        # is west of Greenwich.
        testtime = DateTime.now
        std_ofs = testtime.strftime("%:z").split(":")[0].to_i

        resultbuf = [
            "Etc/GMT",
            (-std_ofs > 0) ? "+" : "",
            (-std_ofs).to_s
          ].join('')
    end

    return resultbuf
end

def select_default_timezone(tzdir)

    system_timezone = nil

    # Check TZ environment variable 
    tzname = ENV['TZ']
    if !tzname.nil? && !tzname.empty? && validate_zone(tzname)
        system_timezone = tzname

    else
        # Nope, so try to identify system timezone from /etc/localtime
        tzname = identify_system_timezone(tzdir)
        if validate_zone(tzname)
            system_timezone = tzname
        end
    end

    return system_timezone
end

# System time zone conversions are controlled by a timezone data file
# identified through environment variables (TZ and TZDIR) and/or file
# and directory naming conventions specific to the Linux distribution.
# Each of these timezone names will have been loaded into the PostgreSQL
# pg_timezone_names view by the package maintainer.
#
# Instead of using the timezone name configured as the system default,
# the PostgreSQL server uses ones named in postgresql.conf settings
# (timezone and log_timezone). The initdb utility does initialize those
# settings to the timezone name that corresponds to the system default.
#
# The system's timezone name is actually a filename relative to the
# shared zoneinfo directory. That is usually /usr/share/zoneinfo, but
# it was /usr/lib/zoneinfo in older distributions and can be anywhere
# if specified by the environment variable TZDIR. The tzset(3) manpage
# seems to indicate the following precedence:
tzdirpath = nil
if ::File.directory?("/usr/lib/zoneinfo")
    tzdirpath = "/usr/lib/zoneinfo"
else
    share_path = [ ENV['TZDIR'], "/usr/share/zoneinfo" ].compact.first
    if ::File.directory?(share_path)
        tzdirpath = share_path
    end
end

# Determine the name of the system's default timezone and specify node
# defaults for the postgresql.cof settings. If the timezone cannot be
# identified, do as initdb would do: leave it unspecified so PostgreSQL
# uses it's internal default of GMT.
default_timezone = select_default_timezone(tzdirpath)
if !default_timezone.nil?
    node.default['postgresql']['config']['log_timezone'] = default_timezone
    node.default['postgresql']['config']['timezone'] = default_timezone
end

#######
# - Where to Log -
node.default['postgresql']['config']['log_destination'] = 'stderr'
node.default['postgresql']['config']['log_directory'] = 'pg_log'
node.default['postgresql']['config']['log_filename'] = 'postgresql-%a.log'
node.default['postgresql']['config']['logging_collector'] = true # on
node.default['postgresql']['config']['log_rotation_age'] = '1d'
node.default['postgresql']['config']['log_rotation_size'] = 0
node.default['postgresql']['config']['log_truncate_on_rotation'] = true # on
