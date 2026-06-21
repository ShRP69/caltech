## caltech

A simple command-line calendar tool written in Ruby.
It can display monthly or yearly calendars, show multiple months at once, and display the current time in different timezones. It also includes an interactive mode for navigating between months directly in the terminal.

### usage

```
ruby caltech.rb                            # Show current month
ruby caltech.rb 12                         # Show December (current year)
ruby caltech.rb 12 2025                    # Show December 2025
ruby caltech.rb -n 3                       # Show 3 months side-by-side
ruby caltech.rb -y                         # Show full year
ruby caltech.rb --time                     # Show current local time
ruby caltech.rb --tz Europe/Athens --time  # Show time in Europe/Athens
ruby caltech.rb --tz +02:00 --time         # Show time using UTC offset
ruby caltech.rb --tz list                  # List all available timezones
ruby caltech.rb -i                         # Interactive mode (arrow keys, q to quit)
```
<a href="https://www.ruby-lang.org/en/" target="_blank" rel="noreferrer">
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/ruby/ruby-original.svg" alt="ruby" width="50" height="50" /> 
