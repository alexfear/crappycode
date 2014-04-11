for dir in $(find /mnt/video/radio24/music/ -type d); do
    cd $dir;
    for i in * ; do.
	mv "$i" `echo ${i} | sed "s: :_:g;s:'::g;s:,::g;s:&::g;s:(::g;s:)::g;" | tr [:upper:] [:lower:]` ;
    done
done