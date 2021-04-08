import sys
import os

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
temp = open(BASE_DIR + '/config.temp').read().rstrip()
(base, inp, output, work, tmp) = sys.argv[1:6]
print(temp.format(base=base, inp=inp, output=output, work=work, tmp=tmp))
