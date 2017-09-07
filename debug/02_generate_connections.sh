for i in {1..10000}
do
  echo $i
  sqlplus -S /nolog @02_generate_connections.sql
done
