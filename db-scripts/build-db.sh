
NCBI_PATH='ftp://ftp.ncbi.nlm.nih.gov/genomes'

DOMAIN=''
SUBSET=" "
getopts ":bavfpt" opt
case "$opt" in
    h|\?)
        echo -e "Select one of the following options:\n\t-b (bacteria)\n\t-a (archaea)\n\t-v (viral)\n\t-f (fungi)\n\t-p (protozoa)\n\t-t (bacterial-subset-list-file)"
        exit 0
        ;;
    b)  DOMAIN='bacteria'
        ;;
    a)  DOMAIN='archaea'
        ;;
    v)  DOMAIN='viral'
        ;;
    f)  DOMAIN='fungi'
        ;;
    p)  DOMAIN='protozoa'
        ;;
    t)  DOMAIN='bacteria'
        SUBSET='bacterial-subset-list-file'
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
esac

echo "Download $DOMAIN database..."
wget -O assembly_summary.raw.txt ${NCBI_PATH}/refseq/${DOMAIN}/assembly_summary.txt

echo "subset file: "
echo ${SUBSET}

if [ "${SUBSET}" = " " ]; then
    mv assembly_summary.raw.txt assembly_summary.txt
else
    grep -f ${SUBSET} assembly_summary.raw.txt >assembly_summary.txt
    rm assembly_summary.raw.txt
fi

nextflow run $REFERENCE_SEEKER_HOME/db-scripts/build-db.nf --ass_sum ./assembly_summary.txt --ncbiPath $NCBI_PATH --domain $DOMAIN  ||  { echo "Nextflow failed!"; exit; }

$REFERENCE_SEEKER_HOME/share/mash paste db sketches/*.msh  ||  { echo "Mash failed!"; exit; }

rm -rf work/ .nextflow* sketches/ assembly_summary.txt

mv db.msh $DOMAIN/
