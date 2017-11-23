#!/bin/bash

# Названия виртуальных машин через пробел
VM='vm1 vm2'
# Количество снапшотов
MAX='6'
# MySQL
DBUSER='user'
DBPASS='pass'
DBHOST='host'
DB='db'

error=`mktemp`
clear
for MACHINE in $VM
do
echo "Виртуальная машина: "$MACHINE
virsh -c qemu:///system snapshot-create --atomic $MACHINE 2>$error
if [ $? -ne 0 ]; then
echo "Ошибка создания снапшота"
echo "INSERT INTO snapshot (datetime, host, vm, action, status) VALUES (NOW(), '`hostname`', '$MACHINE', 'CREATE', 'ERROR: `cat $error`')" | mysql -u$DBUSER -p$DBPASS -h $DBHOST $DB
exit 1
fi

out=`mktemp`
virsh -c qemu:///system snapshot-list $MACHINE > $out

list=`mktemp`
awk 'NR > 2 {print $1"	"$2}' $out > $list
list_sorted=`mktemp`
sort -k 2,2 < $list > $list_sorted

awk 'NR > 1 {print $1}' $list_sorted > $list

echo "INSERT INTO snapshot (datetime, host, vm, action, snapshot, status) VALUES (NOW(), '`hostname`', '$MACHINE', 'CREATE', '`tail -n 1 $list`', 'OK')" | mysql -u$DBUSER -p$DBPASS -h $DBHOST $DB

if (( `cat $list | wc -l` <= $MAX))
	then
		echo не надо удалять
	else
		echo удаление старого снапшота
		virsh -c qemu:///system snapshot-delete $MACHINE --snapshotname `head -n 1 $list` 2>$error
		if [ $? -ne 0 ]; then
		echo "Ошибка удаления снапшота"
		echo "INSERT INTO snapshot (datetime, host, vm, action, snapshot, status) VALUES (NOW(), '`hostname`', '$MACHINE', 'DELETE', '`head -n 1 $list`', 'ERROR: `cat $error`')" | mysql -u$DBUSER -p$DBPASS -h $DBHOST $DB
		exit 1
		fi
		echo "INSERT INTO snapshot (datetime, host, vm, action, snapshot, status) VALUES (NOW(), '`hostname`', '$MACHINE', 'DELETE', '`head -n 1 $list`', 'OK')" | mysql -u$DBUSER -p$DBPASS -h $DBHOST $DB
fi
rm -f $list_sorted
rm -f $list

rm -f $out
#virsh -c qemu:///system snapshot-list $MACHINE
done
rm -f $error
