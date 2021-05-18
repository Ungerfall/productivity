#!/bin/bash

usage()
{
  echo "usage: multisearch.sh [--path | -p] path/to/folder \
    [--regex | -r] search string [--ext | -e] file extension"
}



##### Main

path=
declare -A search
i=0
iname=

while [ "$1" != "" ]; do
    case $1 in
        -p | --path )           shift
                                path=$1
                                ;;
        -r | --regex )          shift
                                search[regex,$i]=$1
                                search[found,$i]=false
                                ((i++))
                                ;;
        -n | --iname )          shift
                                iname=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

len=$(("${#search[@]}"/2))

#  for (( i = 0; i < ${len}; i++ )); do
#    echo "${search[regex,$i]}"
#    search[found,$i]=true
#    echo "${search[found,$i]}"
#  done

# for item in "${!search[@]}" ; do
#   echo "key  : $item"
#   echo "value: ${search[$item]}"
# done

shopt -s nocasematch
find "$path" -iname "$iname" -print0 | while read -d  $'\0' file
do
  found=false
  for (( i = 0; i < ${len}; i++ )); do
    search[found,$i]=false
  done

  while IFS= read -r line
  do
    for (( i = 0; i < ${len}; i++ )); do
      [[ $line =~ "${search[regex,$i]}" ]] && search[found,$i]=true
    done

    for (( i = 0; i < ${len}; i++ )); do
      found="${search[found,$i]}"
      if [[ "$found" != "true" ]]; then
        break;
      fi
    done

    # if all regexes are found - break the file reading
    if [[ "$found" = "true" ]]; then
      echo "$file"
      break
    fi

  done < "$file"

done
