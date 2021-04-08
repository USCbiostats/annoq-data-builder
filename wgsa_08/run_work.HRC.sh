#work pipeline
#1 create a directory under input, all files under that folder will be automaticly scanned and used as input
#2 change the name of work_name in script
#3 run
#detail WGSA configures can be found under ./scripts
work_name='HRC_03_07_19'

base_dir='.'
input_dir=$base_dir/input/$work_name
config_dir=$base_dir/configs/$work_name

#mkdir $base_dir/input
#mkdir $base_dir/configs
#mkdir $base_dir/res
#mkdir $base_dir/work
#mkdir $base_dir/tmp
#mkdir $base_dir/slurm

files=(`ls $input_dir|grep vcf$`)
echo $base_dir, $input_dir, $config_dir
#create  folders
#generate config files
for i in "${files[@]}";do
 input=$input_dir/$i
 output_dir=$base_dir/res/$work_name/
 output=$base_dir/res/$work_name/${i%%.*}.annotated
 work=$base_dir/work/$work_name/${i%%.*}
 tmp=$base_dir/tmp/$work_name/${i%%.*}
 config=$config_dir/${i%%.*}.config.txt
 mkdir -p $config_dir
 mkdir -p $output_dir
 mkdir -p $work
 mkdir -p $tmp
 #echo $input $output $work $tmp $config
 python $base_dir/scripts/config.py $input $output $work $tmp > $config
done


#generate slurm scripts
slurm_dir=$base_dir/slurm/$work_name
mkdir -p $slurm_dir
for i in "${files[@]}";do
 config=$config_dir/${i%%.*}.config.txt
 python $base_dir/scripts/sbatch.py $config $config_dir $slurm_dir/${i%%.*}.output $slurm_dir/${i%%.*}.error > $slurm_dir/${i%%.*}.sbatch
 sbatch $slurm_dir/${i%%.*}.sbatch
done


