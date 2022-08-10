# get fourth line of generated file passed as an argument (stored automatically in $1)
line=$(cat $1 | grep Deployed)

# return the last word of that line using grep
echo $line | grep -o "\w*$"

# to store this 'echo' into a file, call this script with output redirection '>'