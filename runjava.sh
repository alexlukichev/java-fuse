#!/bin/bash

cassandra=${CASSANDRA:-cassandra}
wd=${JAVA_WORKDIR:-.}
cp=${JAVA_CLASSPATH:-.}
jvmopts=${JVM_OPTS:-}
archive=${APP_ARCHIVE:-}
main=$1
shift 
args=$*

if [ -z $main ]; then
  echo "No main class supplied"
  exit 1
fi

function start_java() {
  if [ -f .lock ]; then
    return
  fi
  touch .lock
  echo "(Re)starting java..."
  actual_cp="$cp"
  if [ ! -z $archive ]; then
    echo "Listing archives at ${archive}..."
    tgz=$(ls -t $archive|head -1)
    if [ ! -z $tgz ]; then
      echo "Newest one is: $tgz"
      main_dir=$wd/.dist
      modified_cp=$(echo $cp|awk 'BEGIN {FS=":"} { for (i=1;i<=NF;i++) { print $i; }}'|while read d; do echo "$main_dir/$d"; done|tr "\n" ":")
      actual_cp="$modified_cp"
      echo "Modified classpath: $actual_cp"
      echo "Unpacking in ${main_dir}..."
      (rm -rf $main_dir; mkdir -p $main_dir && cd $main_dir && tar zxf $tgz --strip=1)
    fi
  fi
  ( cd $wd; java -cp "$wd:$actual_cp" $jvmopts $main $args )
  rm -f .lock
}

rm -f .lock
start_java
