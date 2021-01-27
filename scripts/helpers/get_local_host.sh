#!/bin/bash

get_local_host(){
    localhost=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}')
}