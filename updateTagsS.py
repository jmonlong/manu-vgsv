import fileinput
import re


pattern = re.compile('tag="(S[0-9]+)"')
tabcpt = 1
figcpt = 1
for line in fileinput.input():
    line = line.rstrip()
    mres = pattern.search(line)
    if mres:
        stag = mres.group(1)
        if '#tbl:' in line:
            line = line.replace('tag="{}"'.format(stag),
                                'tag="S{}"'.format(tabcpt))
            tabcpt += 1
        if '#fig:' in line:
            line = line.replace('tag="{}"'.format(stag),
                                'tag="S{}"'.format(figcpt))
            figcpt += 1
    print line
