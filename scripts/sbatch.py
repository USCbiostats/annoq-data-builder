import sys
import os

BASE_DIR = os.path.dirname(os.path.realpath(__file__))
temp = open(BASE_DIR + '/sbatch.temp').read()
config, config_dir, slurm_out, slurm_err = sys.argv[1:5]
print(temp.format(config=config, config_dir=config_dir, slurm_out=slurm_out, slurm_err=slurm_err))
