#!/usr/bin/env ruby

# Copyright 2025 Louis Phoenix (ShRP69) <shrp69@proton.me>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'date'
require 'optparse'
require 'io/console'
require 'tzinfo'

options = {
  months: 1,
  year: false,
  tz: "local",
  interactive: false,
  show_time: false
}

def fail!(parser, msg)
  puts "#{msg}\n\n"
  puts parser
  exit 1
end

parser = OptionParser.new do |opts|
  opts.banner = "Usage: calendar [month] [year] [options]"

  opts.on("-n NUM", Integer, "Show multiple months") do |n|
    fail!(opts, "Invalid number of months") if n <= 0
    options[:months] = n
  end

  opts.on("-y", "Show full year") { options[:year] = true }

  opts.on("--tz ZONE", "Timezone (+02:00, Europe/Athens, list)") do |z|
    options[:tz] = z
  end

  opts.on("-i", "Interactive mode") { options[:interactive] = true }

  opts.on("--time", "Show current time") do
    options[:show_time] = true
  end

  opts.on("-h", "--help") { puts opts; exit }
end

begin
  parser.parse!
rescue OptionParser::ParseError => e
  fail!(parser, e.message)
end

if options[:tz] == "list"
  puts "Available Timezones:\n\n"
  TZInfo::Timezone.all_identifiers.sort.each { |z| puts z }
  exit
end

def now_in_tz(tz, parser)
  return Time.now if tz == "local"

  if tz.match?(/^[+-]\d{2}:\d{2}$/)
    return Time.now.getlocal(tz) rescue fail!(parser, "Invalid timezone offset")
  end

  begin
    zone = TZInfo::Timezone.get(tz)
    return zone.to_local(Time.now.utc)
  rescue TZInfo::InvalidTimezoneIdentifier
    fail!(parser, "Invalid timezone")
  end
end

now   = now_in_tz(options[:tz], parser)
today = Date.new(now.year, now.month, now.day)

if options[:show_time]
  label = options[:tz] == "local" ? "Local" : options[:tz]
  offset = now.strftime("%:z")
  puts "Current time (#{label}, UTC#{offset}): #{now.strftime('%Y-%m-%d %H:%M:%S')}\n\n"
end

def parse_args(argv, today, parser)
  case argv.length
  when 0
    [today.month, today.year]
  when 1
    raise "Invalid number" unless argv[0] =~ /^\d+$/
    val = argv[0].to_i
    val > 12 ? [today.month, val] : [val, today.year]
  when 2
    raise "Invalid input" unless argv.all? { |a| a =~ /^\d+$/ }
    m, y = argv.map(&:to_i)
    raise "Month must be 1-12" unless (1..12).include?(m)
    [m, y]
  else
    raise "Too many arguments"
  end
rescue => e
  fail!(parser, e.message)
end

month, year = parse_args(ARGV, today, parser)

def render_horizontal(months, today)
  def strip_ansi(s) = s.gsub(/\e\[[0-9;]*m/, '')
  def pad(s, w) = s + " " * (w - strip_ansi(s).length)

  months.each_slice(3) do |group|
    blocks = group.map do |(y, m)|
      first = Date.new(y, m, 1)
      last  = Date.new(y, m, -1)

      lines = []
      lines << "#{Date::MONTHNAMES[m]} #{y}".center(20)
      lines << "Su Mo Tu We Th Fr Sa"

      week = ["  "] * first.wday

      (1..last.day).each do |d|
        date = Date.new(y, m, d)
        day = d.to_s.rjust(2)
        day = "\e[7m#{day}\e[0m" if date == today
        week << day

        if week.size == 7
          lines << week.join(" ")
          week = []
        end
      end

      unless week.empty?
        week.fill("  ", week.size...7)
        lines << week.join(" ")
      end

      lines << " " * 20 while lines.size < 8
      lines
    end

    (0...8).each do |i|
      puts blocks.map { |b| pad(b[i], 20) }.join("  ")
    end
    puts
  end
end

def interactive(today)
  current = today
  loop do
    system("clear")
    puts "Interactive Calendar (← →, q to quit)"
    render_horizontal([[current.year, current.month]], today)

    case STDIN.getch
    when "q" then break
    when "\e"
      STDIN.getch
      dir = STDIN.getch
      current = dir == "C" ? current >> 1 : current << 1 if ["C", "D"].include?(dir)
    end
  end
end

begin
  if options[:interactive]
    interactive(today)

  elsif options[:year]
    render_horizontal((1..12).map { |m| [year, m] }, today)

  elsif options[:months] > 1
    months = options[:months].times.map do |i|
      d = Date.new(year, month, 1) >> i
      [d.year, d.month]
    end
    render_horizontal(months, today)

  else
    render_horizontal([[year, month]], today)
  end

rescue => e
  fail!(parser, e.message)
end
