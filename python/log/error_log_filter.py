# python2
import sys

exception_found = False
line_number = 1;

for line in sys.stdin:
  if exception_found and line.find('at ') != -1:
      sys.stdout.write("  " + str(line_number) + ": " + line)  # RET already in line
  elif exception_found:
      exception_found = False
  if line.find("Exception") != -1 or line.find("NullReference") != -1 or line.find("Error") != -1 or line.find("error") != -1 or line.find("ERROR") != -1:
      sys.stdout.write("  " + str(line_number) + ": " + line)  # RET already in line
      exception_found = True

  line_number = line_number + 1
