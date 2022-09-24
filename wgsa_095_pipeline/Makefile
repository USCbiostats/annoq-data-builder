%/all: %/create_dir.touch
	bash annovar.sh
.PRECIOUS: %/create_dir.touch
%/create_dir.touch:
	bash create_dir.sh $*
	touch $@
