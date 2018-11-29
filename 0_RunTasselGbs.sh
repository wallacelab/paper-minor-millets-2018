#! /bin/bash

# Run TASSEL GBSv2 pipeline on 3 minor millets 
# Python scripts were used under Python 3.5.2

# Command to call TASSEL5 (version 5.2.26 used for Johnson et al paper)
# Note: TASSEL version appears to have a minor impact on resulting Hapmap file and SNP calls. MD5sums don't match and sometimes order of SNPs/samples is altered, but in our testing the resulting 
#       genetic distances among the samples always match out to 3-4 decimal places, so any changes appear extremely minor
# Note: TASSEL version 5.2.26 is assumed to be the one used to originally generate the files (it had been upgraded several times by the time the paper was written up); it may have actually been a 
#       few versions earlier, but any versioning differences appear to be extremely minor, as explained above
TASSEL5="perl $HOME/Software/TASSEL/tassel-5-standalone/run_pipeline.pl -Xms10g -Xmx50g" 

# Global variables affecting the GBS analysis
flowcells=0_flowcells  # Directory where GBS flowcells are saved
min_tag_count=10       # Minimum times a GBS "tag" sequence has to show up to be kept in the filtering step
enzyme="PstI"          # Enzyme used for GBS digestion
# Keyfiles supplied as SPECIES.keys.txt

# Make working directory
workdir=TasselGBS
if [ ! -e $workdir ]; then mkdir $workdir; fi


# Go through species and do GBS analysis
for species in kodo proso little; do
  keyfile=$species.keys.txt
  database=$workdir/$species.gbs_database.sql # Database to create for calling SNPs (part of GBSv2 pipeline)
  
  # Make directory for UNEAK output
  udir=$workdir/${species}_uneak    
  if [ ! -e $udir ]; then mkdir $udir; fi

  # Make initial database
  $TASSEL5 -GBSSeqToTagDBPlugin -i "$flowcells" -k $keyfile -db $database -e $enzyme -c $min_tag_count

  # Export tag counts, run UNEAK on them, and convert to a SAM file of pseudo-positions (UNEAK is not part of GBSv2 but the plugin commands are still around)
  $TASSEL5 -GetTagSequenceFromDBPlugin -db $database -o $udir/1a_$species.tags.txt
  python3 1b_ConvertTagSeqsToCountFile.py -i $udir/1a_$species.tags.txt -o $udir/1a_$species.tags.cnt.txt --pad 64 --count $min_tag_count
  $TASSEL5 -TextToBinaryPlugin -i $udir/1a_$species.tags.cnt.txt -o $udir/1a_$species.tags.cnt -t TagCounts
  $TASSEL5 -UTagCountToTagPairPlugin -inputFile $udir/1a_$species.tags.cnt -outputFile $udir/1a_$species.tags.tps
  $TASSEL5 -UTagPairToTOPMPlugin -input $udir/1a_$species.tags.tps -toText $udir/1a_$species.topm.txt
  python3 1c_ConvertTopmToFakeSam.py -i $udir/1a_$species.topm.txt -o $udir/1c_$species.topm.sam   
  
  # Import SAM file to the database to give genomic "positions" (based off UNEAK filter) to align against each other
  $TASSEL5 -SAMToGBSdbPlugin -i $udir/1c_$species.topm.sam -db $database

  # Run Discovery SNP Caller
  $TASSEL5 -DiscoverySNPCallerPluginV2 -db $database
  
  # Call SNPs
  $TASSEL5 -ProductionSNPCallerPluginV2 -db $database -e $enzyme -i $flowcells -k $keyfile -o $workdir/$species.raw.h5  # For some reason the export-to-VCF is not working
  $TASSEL5 -h5 $workdir/$species.raw.h5 -export $workdir/$species.raw.hmp.txt.gz -exportType Hapmap

#   break
done






