echo "Annotation begins. "
date
echo "Preparing input files ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/chr_pos_ref_alt_hg19.txt
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/7.vcf.snp.gz" /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g input_to_ANNOVAR_vcf_dbNSFP2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz
echo "Done. "
date
echo "Searching integrated SNV annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/lz4-1.3.0.jar -Xmx60g search_integrated_output13_hg19 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz /home/pmd-01/zhuliu/WGSA_08/resources/precomputed/ ,5-12,13-37,38-59,60-67,68-92,93-112,113-120 false 1
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz.IntegratedSNV.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.1.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ucsc.txt
echo "Done. "
date
echo "Searching dbSNP ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_dbSNP_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.1.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/dbSNP/hg19/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.1.gz.adddbSNP.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.2.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.1.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/dbsnp.txt
echo "Done. "
date
echo "Searching snoRNA/miRNA annotation ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.2.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/snoRNA_miRNA_hg19.bed.gz.chr*.gz" 1 1 5,6 sno_miRNA_name,sno_miRNA_type snoRNA_miRNA t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.2.gz.addsnoRNA_miRNA.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.3.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.2.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snoRNA_miRNA.txt
echo "Done. "
date
echo "Searching miRNA target annotation ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.3.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/Predicted_Targets_6cols.hg19.bed.gz.chr*.gz" 1 1 4,5 UTR3_miRNA_target,TargetScan_context++_score_percentile UTR3_miRNA_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.3.gz.addUTR3_miRNA_target.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.4.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.3.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/UTR3_miRNA_target.txt
echo "Done. "
date
echo "Searching dbscSNV ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_splicing_consensus_prediction_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.4.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/scSNV/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.4.gz.addSplicingPred.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.5.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.4.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/scSNV.txt
echo "Done. "
date
echo "Searching GWAS catalog ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GWAS_catalog_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.5.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GWAS_catalog/gwas_catalog_v1.0.2-associations_e93_r2019-01-31.tsv.var.hg19.snp.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.5.gz.addGWAS_catalog.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.6.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.5.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GWAS_catalog2.txt
echo "Done. "
date
echo "Searching GRASP2 ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GRASP_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.6.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GRASP/GRASP2final.summary.addhg19.snp.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.6.gz.addGRASP.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.7.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.6.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GRASP.txt
echo "Done. "
date
echo "Searching clinvar ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_clinvar_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.7.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/clinvar/hg19/clinvar_20190311.vcf.gz.summary.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.7.gz.addClinvar.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.8.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.7.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/clinvar4.txt
echo "Done. "
date
echo "Searching COSMIC ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_COSMIC_coding_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.8.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/COSMIC/hg19/CosmicCodingMuts.vcf.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.8.gz.addCOSMIC.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.9.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.8.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/cosmic.txt
echo "Done. "
date
echo "Searching GTEx eQTL ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GTEX_eQTL_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.9.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GTEx/GTEx_Analysis_v7_eQTL.summary2.gz.snp.gz.chr*.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.9.gz.addGTEXeQTL.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.10.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.9.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GTEx4.txt
echo "Done. "
date
echo "Searching GERP++ conservation score ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_GERP_gz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.10.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/GERP/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.10.gz.addGERP.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.11.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.10.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GERP.txt
echo "Done. "
date
echo "Searching 1000 genomes phase 3 allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_1000genomes_phase3_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.11.gz true 1 2 3 4 "All.chr*.phase3.+AC+AN.1alt.left-normalized.vcf.snp.gz" "/home/pmd-01/zhuliu/WGSA_08/resources/1000Gp3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.11.gz.add1000genome_p3.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.12.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.11.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/1000genome_p3.txt
echo "Done. "
date
echo "Searching UK10K cohorts allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_UK10K_frequencies2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.12.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/UK10K/" snp
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.12.gz.addUK10K.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.13.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.12.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/uk10k.txt
echo "Done. "
date
echo "Searching ESP6500 consortium allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ESP6500_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.13.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/ESP6500/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.13.gz.addESP6500.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.14.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.13.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ESP6500.txt
echo "Done. "
date
echo "Searching ExAC consortium allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ExACgz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.14.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/ExACr0.3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.14.gz.addExAC.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.15.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.14.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ExAC.txt
echo "Done. "
date
echo "Searching gnomAD consortium exomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_exomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.15.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.15.gz.addgnomAD_exomes.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.16.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.15.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_exomes3.txt
echo "Done. "
date
echo "Searching gnomAD consortium genomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_genomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.16.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.16.gz.addgnomAD_genomes.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.17.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.16.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_genomes3.txt
echo "Done. "
date
echo "Searching RegulomeDB scores ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_regulome_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.17.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/regulomeDB/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.17.gz.addRegulomeDB.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.18.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.17.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/RegulomeDB.txt
echo "Done. "
date
echo "Searching funseq-like noncoding scores ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_motif_breaking_funseq_nc_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.18.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/funseq-like/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.18.gz.addfunseq-like-score.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.19.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.18.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/funseq.txt
echo "Done. "
date
echo "Searching CADD scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_CADD_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.19.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/CADDv1.4/hg19/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.19.gz.addCADD.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.20.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.19.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/CADD.txt
echo "Done. "
date
echo "Searching fathmm-MKL scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_FATHMM_MKL_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.20.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmMKL/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.20.gz.addFATHMM-MKL.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.21.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.20.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/MKL.txt
echo "Done. "
date
echo "Searching fathmm-XF scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_FATHMM_XF_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.21.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmXF/hg19/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.21.gz.addFATHMM-XF.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.22.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.21.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/fathmmXF.txt
echo "Done. "
date
echo "Searching ORegAnno regulatory annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_gfflike_annotation_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.22.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/ORegAnno/ORegAnno_Combined_2015.12.22.tsv.gz.hg19.gz.chr*.gz" 2 16 4,12 ORegAnno_type,ORegAnno_PMID ORegAnno t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.22.gz.addORegAnno.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.23.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.22.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ORegAnno.txt
echo "Done. "
date
echo "Searching ENCODE TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.23.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/Txn_Factor_ChIP/wgEncodeRegTfbsClusteredWithCellsV3.bed.gz.chr*.gz" 1 1 4,5,6 ENCODE_TFBS,ENCODE_TFBS_score,ENCODE_TFBS_cells ENCODE_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.23.gz.addENCODE_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.24.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.23.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_TFBS.txt
echo "Done. "
date
echo "Searching ENCODE Dnase annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.24.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/DNase_Clusters/wgEncodeRegDnaseClusteredV2.bed.gz.chr*.gz" 1 1 5,4 ENCODE_Dnase_score,ENCODE_Dnase_cells ENCODE_Dnase t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.24.gz.addENCODE_Dnase.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.25.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.24.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_Dnase.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.25.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/human_permissive_enhancers_phase_1_and_2.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.25.gz.addFANTOM5_enhancer_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.26.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.25.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.26.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/robust_enhancers.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.26.gz.addFANTOM5_enhancer_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.27.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.26.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_robust.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer target annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.27.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_gene_pair.bed.gz.chr*.gz" 2 1 4 FANTOM5_enhancer_target FANTOM5_enhancer_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.27.gz.addFANTOM5_enhancer_target.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.28.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.27.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_target.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer expression annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.28.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_expression.summary.gz.chr*.gz" 2 1 4,5 FANTOM5_enhancer_expressed_tissue_cell,FANTOM5_enhancer_differentially_expressed_tissue_cell FANTOM5_enhancer_expression t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.28.gz.addFANTOM5_enhancer_expression.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.29.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.28.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_expression.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.29.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/DPIcluster_hg19_20120116.permissive_set.GencodeV10_annotated.osc.gz.chr*.gz" 30 1 FANTOM5_CAGE_peak_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.29.gz.addFANTOM5_CAGE_peak_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.30.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.29.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.30.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/hg19.cage_peak_phase1and2combined_coord.bed.gz.chr*.gz" 1 1 FANTOM5_CAGE_peak_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.30.gz.addFANTOM5_CAGE_peak_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.31.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.30.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_robust.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build Overviews .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline6 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.31.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/Ensembl_Build_Overviews/homo_sapiens.GRCh37.Regulatory_Build.regulatory_features.20161117.gff.gz.bed.gz.chr*.gz" 2 1 8,4 Ensembl_Regulatory_Build_feature_type,Ensembl_Regulatory_Build_ID Ensembl_Regulatory_Build_Overviews t true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.31.gz.addEnsembl_Regulatory_Build_Overviews.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.32.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.31.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_Overviews.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.32.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/TFBS_Summaries/homo_sapiens.GRCh37.motiffeatures.20161117.gff.gz.bed.gz.chr*.gz" 2 1 5,4 Ensembl_Regulatory_Build_TFBS,Ensembl_Regulatory_Build_TFBS_matrix Ensembl_Regulatory_Build_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.32.gz.addEnsembl_Regulatory_Build_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.33.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.32.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_TFBS.txt
echo "Done. "
date
echo "Searching dbNSFP_variant .."
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/dbNSFP/ search_dbNSFP40b2c -i /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz.dbNSFP.in -o /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz.dbNSFP.out -v hg19
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_dbNSFP_annotations_exl_geneinfo_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.gz.dbNSFP.out 5,6,12-26,31-85 /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.33.gz true 1 2 4 hg19
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.33.gz.adddbNSFP.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.33.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/dbNSFP4.0b2c.txt
echo "Done. "
date
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/type_specific.txt
echo "Searching Roadmap 15-state model .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_roadmap_15_state_model_commandline /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz true 1 2 /home/pmd-01/zhuliu/WGSA_08/resources/Roadmap-15-state_model/ "n"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz.addRoadmap15State.gz /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.35.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz.addRoadmap15State.column.txt
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.34.gz.addRoadmap15State.column.txt
echo "Done. "
date
mv -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.35.gz "/home/pmd-01/zhuliu/WGSA_08/res/HRC_03_07_19/7.annotated.snp.gz"
rm -f /home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/annotation.in.0.*
echo "SNV annotation done. "
date
rm -f "/home/pmd-01/zhuliu/WGSA_08/work/HRC_03_07_19/7/7.vcf.indel.gz"
