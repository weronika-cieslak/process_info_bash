#! /bin/bash
usage(){
echo -e "usage: -a [-f <file>]\n         -f <file>: save to file named <file> pids and names of all processes running on the system (default display on screen)\n"
echo -e "usage: -u <pid> [-f <file>]\n       -f <file>: save to file named <file> name of process whose pid is in the given parameter <pid> (default display on screen)\n"
echo -e "usage : -n <name> [-f <file]\n      -f <file>: save to file named <file> pid of process whose name is in the given parameter <name> (default display on screen)\n"
exit -1
}
check_if_valid_parameters(){
if  [[ "$1" =~ ^(-a|-u|-n)$ ]]
then
    return 1
else
    return 0
fi
}
check_f_parameter(){
if [[ "$1" =~ ^(-f)$ ]]
then
    return 1
else
    return 0
fi
}
print_or_rename_file()
{
    if [ -z "$1" ]; then
        cat "$2"
        find ~ -name "$2" -exec rm {} \;
    else 
        mv $2 $1
    fi
}
get_name_of_process()
{
    if [ -f "/proc/$1/comm" ]; then
       echo "$(cat /proc/$1/comm)" >> result
    else
       echo "There is no process with PID $1" >> result
    fi
}
get_pids_and_names()
{
    while read pid
    do
        if [ -d "/proc/$(echo "$pid")" ]; then
            echo "$pid"| tr "\n" " " >> result
            get_name_of_process "$pid" >> result 
        fi
    done < "$1"
}
get_pid_of_process()
{
    while read pid
    do
        if [ -d "/proc/$(echo "$pid")" ]; then
            if [ -f "/proc/$(echo "$pid")/comm" ]; then
                name_of_process=$(cat /proc/$(echo "$pid")/comm) 
                if [ "$2" = "$name_of_process" ]; then
                    echo "$pid" >> result
                    found_process=1
                    break;
                fi
            fi
        fi
    done < "$1"
    if ! [ "$found_process" ]; then
        echo "There is no process with name $2" >> result
    fi
}
allowable_number_of_parametres=4
minimum_number_of_parametres_A=1
minimum_number_of_parametres_U_N=2
parameter_a="-a"
parameter_n="-n"
parameter_u="-u"
if [ "$#" -gt "$allowable_number_of_parametres" ]; then
    usage
fi
if check_if_valid_parameters "$1" ; then
    usage
fi
ls /proc| grep -P "^[0-9]"|sort -n > pids

if [ "$1" = "$parameter_a" ]; then
    if [ "$#" -gt "$minimum_number_of_parametres_A" ]; then
        if check_f_parameter "$2" ; then
            usage
        fi
    filename="$3"
    fi
    pids=$(ls /proc| grep -P "^[0-9]"|sort -n)
    file_temp="./pids"
    get_pids_and_names "$file_temp"
    find ~ -name "pids" -exec rm {} \;
    print_or_rename_file "$filename" result
   
else
    if [ "$#" -gt "$minimum_number_of_parametres_U_N" ]; then
        if check_f_parameter "$3" ; then
            usage
        fi
    filename="$4"
    fi
    if [ "$1" = "$parameter_n" ]; then
        pids=$(ls /proc| grep -P "^[0-9]"|sort -n)
        file_temp="./pids"
        get_pid_of_process "$file_temp" "$2"
        find ~ -name "pids" -exec rm {} \;
        print_or_rename_file "$filename" result
    fi
    if [ "$1" = "$parameter_u" ]; then
        PID=$2
        get_name_of_process "$PID"
        print_or_rename_file "$filename" result
    fi
fi

