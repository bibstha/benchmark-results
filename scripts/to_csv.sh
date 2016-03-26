#!/bin/bash
#This expects csv_from_sysbench and csv_to_png from https://github.com/Percona-Lab/benchmark_automation/ to be on the PATH 
#It must be executed from within the scripts directory, as it uses relative paths

for engine in ft wt rocks; do
    env _ONLYHEADER=1 csv_from_sysbench.sh ../raw/sysbench-${engine}-2000000-1-oltp.txt psfm 2000000 1 > ../alldata-${engine}.csv
    for workload in oltp oltp_ro; do
	for f in ../raw/sysbench-$engine-*$workload.txt; do 
	    threads=$(echo $f|sed 's/.*2000000-//g'|sed 's/-oltp.*//g')
	    env _NOHEADER=1 csv_from_sysbench.sh $f $workload 2000000 $threads >> ../alldata-${engine}.csv
	done
    done
done
echo "engine,$(head -1 ../alldata-ft.csv)" > ../alldata.csv
for engine in ft wt rocks; do
   cat ../alldata-${engine}.csv | grep -v workload|while read l; do
				      echo "$engine,$l" >> ../alldata.csv
   done
done

env _INPUT_FILE=../alldata.csv \
    _OUTPUT_FILE=../alldata.png \
    _FACET_X=user_provided_threads \
    _FACET_Y=engine \
    _FACTOR=workload \
    _X_AXIS=ts _X_AXIS_LABEL="Time in seconds (10 sec interval)" \
    _Y_AXIS=tps _Y_AXIS_LABEL="Throughput (read/write ops per second)" \
    _GRAPH_TITLE="Percona Server for MongoDB / throughput per threads and engine" csv_to_png.sh
