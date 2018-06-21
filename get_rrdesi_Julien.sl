#!/bin/bash -l

#SBATCH --partition=debug
#SBATCH --account=desi
#SBATCH --nodes=16
#SBATCH --time=00:10:00
#SBATCH --job-name=lyasim_rrdesi
#SBATCH --output=test_julien.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alma.gonzalez@fisica.ugto.mx

source /project/projectdirs/desi/software/desi_environment.sh
module unload redrock
module unload redrock-templates/0.5
module load redrock-templates/master
module load redrock/master
#export PYTHONPATH=$SCRATCH/desi/code/redrock/py:$PYTHONPATH
#export PATH=$SCRATCH/desi/code/redrock/bin:$PATH
export OMP_NUM_THREADS=1

idir=/project/projectdirs/desi/users/alxogm/desi/mocks/london/v1.1/no_dla/spectra-16/
#idir=/project/projectdirs/desi/users/jguy/qso-v2.0.2/spectra-$pix/$num
#idir=/project/projectdirs/desi/users/afont/quickquasar-sims/quick-v2.1.0/spectra-16/
outdir=/project/projectdirs/desi/users/alxogm/desi/mocks/london/v1.1/test_rr_julien



    
if [ ! -d $outdir/logs ] ; then
    mkdir -p $outdir/logs
fi
if [ ! -d $outdir/spectra-16 ] ; then
    mkdir -p $outdir/spectra-16
fi

echo "get list of spectra  to analize ..."

#files=`\ls -1 $idir/*/spectra-16*.fits`
files=`\ls -1 $idir/*/*/spectra-16*.fits`
nfiles=`echo $files | wc -w`

echo "n files =" $nfiles

echo "log in $outdir/logs/"

for infile  in $files ; do
    name=${infile##*/}
##    echo $name
    if [ ! -f $outdir/spectra-16/zbest-$name ] ; then
    
   	command="srun -N 16 -n 384 -c 1 rrdesi_mpi  --zbest $outdir/spectra-16/zbest-$name $infile"
  #  	echo $command
  #  	echo "log in $outdir/logs/$name.log"
    
    	$command >& $outdir/logs/$name.log & 
    	wait
    fi
    echo "done with file:" $name
done

wait
echo "END"
