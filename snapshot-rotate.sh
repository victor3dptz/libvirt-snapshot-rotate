#!/bin/bash

# Названия виртуальных машин через пробел
VM='vm1 vm2'
# Количество снапшотов
MAX='6'

clear
for MACHINE in $VM
do
echo "Виртуальная машина: "$MACHINE
virsh snapshot-create --atomic $MACHINE

out=`mktemp`
virsh snapshot-list $MACHINE > $out

list=`mktemp`
awk 'NR > 2 {print $1"	"$2}' $out > $list
list_sorted=`mktemp`
sort -k 2,2 < $list > $list_sorted

awk 'NR > 1 {print $1}' $list_sorted > $list

if (( `cat $list | wc -l` <= $MAX))
	then
		echo не надо удалять
	else
		echo удаление старого снапшота
		virsh snapshot-delete $MACHINE --snapshotname `head -n 1 $list`
fi
rm -f $list_sorted
rm -f $list

rm -f $out

virsh snapshot-list $MACHINE
done
