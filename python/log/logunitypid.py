import sys

log_path = sys.argv[1]

# print('debug: ' + log_path)

log_lines = []

with open(log_path, 'r') as f:
    log_lines = f.readlines()

for l in log_lines:
    if 'I/Unity' in l:
        pid_start = -1
        for i in range(0, len(l)):
            if pid_start != -1:
                if l[i] == ')':
                    print(l[pid_start:i])
                    break
            elif l[i] == '(':
                pid_start = i+1
        break