ARGV=$1;
if [ "x$ARGV" = "x" ]; then
        echo "USAGE: ./fdnumber process_name_or_its_part";
        exit 0
fi
for i in `ps -ef|grep $ARGV|grep -v grep|awk '{print $2}'`;
do
ps -ef|grep $i|grep -v grep;
egrep 'files|Limit' /proc/$i/limits;
echo "File descriptors number: $(ls -1 /proc/$i/fd/ |wc -l)";
echo -e '\n';
done;