#/usr/bin/env bash
set -e
cwd=$(pwd)

dwndir=downloads
mkdir -p $dwndir
builddir=output
mkdir -p $builddir

if [ ! -f "$dwndir/c3d-1.0.0-Linux-x86_64.tar.gz" ]; then
wget https://deac-fra.dl.sourceforge.net/project/c3d/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz -O $dwndir/c3d-1.0.0-Linux-x86_64.tar.gz
fi
if [ ! -f "$dwndir/c3d-1.0.0-Linux-x86_64.tar.gz.md5sum" ]; then
echo "e27484a8a6ecc9710368c5db41f9d368  c3d-1.0.0-Linux-x86_64.tar.gz" > $dwndir/c3d-1.0.0-Linux-x86_64.tar.gz.md5sum
fi
if [ ! -d "$dwndir/c3d-1.0.0-Linux-x86_64" ]; then
cd $dwndir/
md5sum -c c3d-1.0.0-Linux-x86_64.tar.gz.md5sum
tar xzf c3d-1.0.0-Linux-x86_64.tar.gz
cd $cwd
fi

if [ ! -f "$dwndir/ICBM_SVPASEG_ATLAS.zip" ]; then
wget https://github.com/jussitohka/SVPASEG/raw/master/atlases/ICBM_SVPASEG_ATLAS.zip -O $dwndir/ICBM_SVPASEG_ATLAS.zip
fi
if [ ! -f "$dwndir/ICBM_SVPASEG_ATLAS.zip.md5sum" ]; then
echo "816979e0bc9ae0576b9a30a54e74dc92 ICBM_SVPASEG_ATLAS.zip" > $dwndir/ICBM_SVPASEG_ATLAS.zip.md5sum
fi
if [ ! -d "$dwndir/ICBM_SVPASEG_ATLAS" ]; then
cd $dwndir
md5sum -c ICBM_SVPASEG_ATLAS.zip.md5sum
cd $cwd
mkdir -p $dwndir/ICBM_SVPASEG_ATLAS
unzip $dwndir/ICBM_SVPASEG_ATLAS.zip -d $dwndir/ICBM_SVPASEG_ATLAS
fi

# insert line break
echo

c3d=./$dwndir/c3d-1.0.0-Linux-x86_64/bin/c3d

icbm=deps/mni152-icbm-frameofreference/data/mni152-icbm-frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI.nii

gendir="$builddir/ICBM_SVPASEG_ATLAS"
mkdir -p $gendir
for f in $dwndir/ICBM_SVPASEG_ATLAS/*.hdr; do
ofile=`basename $f`;
cmd="$c3d -int 1 $icbm $f -flip xy -origin -90.5x-90.5x-71.5mm -reslice-identity -type uchar -round -o $gendir/$ofile";
echo $cmd;
eval $cmd;
done

olddir="data/svpaseg/atlases/ICBM-2015"

if [ ! -f "$builddir/ncor.csv" ]; then
for f in $builddir/ICBM_SVPASEG_ATLAS/*.hdr; do
 ofile=`basename $f`;
 cmd="$c3d $olddir/$ofile $gendir/$ofile -ncor";
 stdout=$($cmd)
 ncor=$(echo $stdout | sed "s/NCOR = //g")
 record="$ofile,$ncor"
 echo $record | tee $builddir/ncor.csv
done
fi

# insert line break
echo

echo "average ncor for all files"
cat $builddir/ncor.csv | awk -F',' '{sum+=$2} END {print sum/NR}'
