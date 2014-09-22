#actdir=`pwd`
#for files in *tar.gz ; do
#  filedir=`basename $files .tar.gz`
#  mkdir $filedir 
#  cd $filedir
#  tar -xzf ../$files
#  cd $actdir
#done

#for i in *.tar.gz; do tar -xvzf $i -C directory; done
for i in *.tar.gz; do tar -xvzf $i; done
