d=false
f=false
v=false

while true; do
    case "$1" in 
        -d|--debug)
            d=true
            shift
            ;;
        -f|--force)
            f=true
            shift
            ;;
        -v|--verbose)
            v=true
            shift
            ;;
        *)
            # echo "Programming error"
            # exit 3
            break
            ;;
    esac
done

echo "verbose: $v, force: $f, debug: $d"
