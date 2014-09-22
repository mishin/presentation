usage() {
    printf "Usage: $0 [-o outdir]\n"
    exit 2
}

outdir="."

while getopts "ho:" opt; do
    case $opt in
        h)
            usage
            ;;
        o)
            outdir=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done