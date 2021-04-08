export Z_HOME="/home/pmd-01/zhuliu"
export LD_LIBRARY_PATH=$Z_HOME/lib/:$LD_LIBRARY_PATH
export PERL5LIB=$Z_HOME/lib/perl5/lib64/perl5:$Z_HOME/lib/perl5/share/perl5


PATH=$PATH:$Z_HOME/bin:$Z_HOME/.local/bin
PATH=$PATH:$Z_HOME/local/bin

#perl env
export PERL_BASE="$Z_HOME/perl"
export PERL5LIB="$PERL_BASE/perl-5.22.2/lib/perl5:$PERL_BASE/perl-5.22.2/lib/perl5/x86_64-linux:$PERL5LIB"
PATH="$PERL_BASE/perl-5.22.2/bin:$PATH"

export OPENCL_LIB="/usr/usc/cuda/default/lib64/"
export OPENCL_INC="/usr/usc/cuda/default/include/"

#java env
export JAVA_HOME=/usr/usc/java/1.8.0_45
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$Z_HOME/lib/java/GenomeAnalysisTK.jar
