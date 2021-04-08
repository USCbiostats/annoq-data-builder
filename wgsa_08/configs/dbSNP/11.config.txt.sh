echo "Annotation begins. "
date
echo "Mapping hg38 to hg19 ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g hg38_to_hg19_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.snp.gz true /home/pmd-01/zhuliu/WGSA_08/resources/crossmap/ /home/pmd-01/zhuliu/WGSA_08/resources/hg19/
rm -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.snp.gz"
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.snp.gz.addhg38tohg19.gz" "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.snp.gz"
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g hg38_to_hg19_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz true /home/pmd-01/zhuliu/WGSA_08/resources/crossmap/ /home/pmd-01/zhuliu/WGSA_08/resources/hg19/
rm -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz"
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz.addhg38tohg19.gz" "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz"
echo "Done. "
date
echo "Preparing input files ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/chr_pos_ref_alt_hg38.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/hg38_to_hg19.txt
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.snp.gz" /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g input_to_ANNOVAR_vcf_dbNSFP2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz
echo "Done. "
date
echo "Searching integrated SNV annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/lz4-1.3.0.jar -Xmx60g search_integrated_output13_hg38 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz /home/pmd-01/zhuliu/WGSA_08/resources/precomputed_hg38/ ,5-12,13-37,38-59,60-67,68-92,93-112,113-120 false 1
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz.IntegratedSNV.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.1.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_ensembl.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_refseq.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ucsc.txt
echo "Done. "
date
echo "Searching dbSNP ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_dbSNP_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.1.gz true 1 2 3 4 snp "/home/pmd-01/zhuliu/WGSA_08/resources/dbSNP/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.1.gz.adddbSNP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.2.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.1.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/dbsnp.txt
echo "Done. "
date
echo "Searching snoRNA/miRNA annotation ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.2.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/snoRNA_miRNA_hg38.bed.gz.chr*.gz" 1 1 5,6 sno_miRNA_name,sno_miRNA_type snoRNA_miRNA t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.2.gz.addsnoRNA_miRNA.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.3.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.2.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snoRNA_miRNA.txt
echo "Done. "
date
echo "Searching miRNA target annotation ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.3.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/Predicted_Targets_6cols.hg38.bed.gz.chr*.gz" 1 1 4,5 UTR3_miRNA_target,TargetScan_context++_score_percentile UTR3_miRNA_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.3.gz.addUTR3_miRNA_target.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.4.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.3.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/UTR3_miRNA_target.txt
echo "Done. "
date
echo "Searching dbscSNV ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_splicing_consensus_prediction_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.4.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/scSNV/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.4.gz.addSplicingPred.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.5.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.4.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/scSNV.txt
echo "Done. "
date
echo "Searching GWAS catalog ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GWAS_catalog_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.5.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GWAS_catalog/gwas_catalog_v1.0.2-associations_e93_r2019-01-31.tsv.var.hg38.snp.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.5.gz.addGWAS_catalog.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.6.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.5.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GWAS_catalog2.txt
echo "Done. "
date
echo "Searching GRASP2 ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GRASP_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.6.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GRASP/GRASP2final.summary.addhg38.snp.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.6.gz.addGRASP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.7.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.6.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GRASP.txt
echo "Done. "
date
echo "Searching clinvar ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_clinvar_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.7.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/clinvar/hg38/clinvar_20190311.vcf.gz.summary.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.7.gz.addClinvar.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.8.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.7.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/clinvar4.txt
echo "Done. "
date
echo "Searching COSMIC ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_COSMIC_coding_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.8.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/COSMIC/hg38/CosmicCodingMuts.vcf.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.8.gz.addCOSMIC.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.9.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.8.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/cosmic.txt
echo "Done. "
date
echo "Searching GTEx eQTL ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GTEX_eQTL_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.9.gz true 5 6 7 8 "/home/pmd-01/zhuliu/WGSA_08/resources/GTEx/GTEx_Analysis_v7_eQTL.summary2.gz.snp.gz.chr*.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.9.gz.addGTEXeQTL.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.10.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.9.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GTEx4.txt
echo "Done. "
date
echo "Searching GERP++ conservation score ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_GERP_gz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.10.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/GERP/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.10.gz.addGERP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.11.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.10.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GERP.txt
echo "Done. "
date
echo "Searching 1000 genomes phase 3 allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_1000genomes_phase3_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.11.gz true 1 2 3 4 "All.chr*.hg38.phase3.+AC+AN.1alt.left-normalized.vcf.gz.snp.gz" "/home/pmd-01/zhuliu/WGSA_08/resources/1000Gp3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.11.gz.add1000genome_p3.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.12.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.11.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/1000genome_p3.txt
echo "Done. "
date
echo "Searching UK10K cohorts allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_UK10K_frequencies2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.12.gz true 5 6 7 8 "/home/pmd-01/zhuliu/WGSA_08/resources/UK10K/" snp
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.12.gz.addUK10K.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.13.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.12.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/uk10k.txt
echo "Done. "
date
echo "Searching ESP6500 consortium allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ESP6500_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.13.gz true 5 6 7 8 snp "/home/pmd-01/zhuliu/WGSA_08/resources/ESP6500/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.13.gz.addESP6500.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.14.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.13.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ESP6500.txt
echo "Done. "
date
echo "Searching ExAC consortium allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ExACgz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.14.gz true 5 6 7 8 snp "/home/pmd-01/zhuliu/WGSA_08/resources/ExACr0.3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.14.gz.addExAC.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.15.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.14.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ExAC.txt
echo "Done. "
date
echo "Searching gnomAD consortium exomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_exomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.15.gz true 5 6 7 8 snp "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.15.gz.addgnomAD_exomes.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.16.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.15.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_exomes3.txt
echo "Done. "
date
echo "Searching gnomAD consortium genomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_genomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.16.gz true 5 6 7 8 snp "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.16.gz.addgnomAD_genomes.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.17.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.16.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_genomes3.txt
echo "Done. "
date
echo "Searching RegulomeDB scores ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_regulome_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.17.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/regulomeDB/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.17.gz.addRegulomeDB.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.18.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.17.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/RegulomeDB.txt
echo "Done. "
date
echo "Searching funseq-like noncoding scores ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_motif_breaking_funseq_nc_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.18.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/funseq-like/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.18.gz.addfunseq-like-score.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.19.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.18.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/funseq.txt
echo "Done. "
date
echo "Searching CADD scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_CADD_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.19.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/CADDv1.4/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.19.gz.addCADD.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.20.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.19.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/CADD.txt
echo "Done. "
date
echo "Searching fathmm-MKL scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_FATHMM_MKL_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.20.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmMKL/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.20.gz.addFATHMM-MKL.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.21.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.20.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/MKL.txt
echo "Done. "
date
echo "Searching fathmm-XF scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg38_FATHMM_XF_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.21.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmXF/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.21.gz.addFATHMM-XF.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.22.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.21.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/fathmmXF.txt
echo "Done. "
date
echo "Searching ORegAnno regulatory annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_gfflike_annotation_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.22.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/ORegAnno/ORegAnno_Combined_2015.12.22.tsv.gz.hg38.gz.chr*.gz" 2 16 4,12 ORegAnno_type,ORegAnno_PMID ORegAnno t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.22.gz.addORegAnno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.23.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.22.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ORegAnno.txt
echo "Done. "
date
echo "Searching ENCODE TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.23.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/Txn_Factor_ChIP/wgEncodeRegTfbsClusteredWithCellsV3.bed.gz.chr*.gz" 1 1 4,5,6 ENCODE_TFBS,ENCODE_TFBS_score,ENCODE_TFBS_cells ENCODE_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.23.gz.addENCODE_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.24.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.23.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_TFBS.txt
echo "Done. "
date
echo "Searching ENCODE Dnase annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.24.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/DNase_Clusters/wgEncodeRegDnaseClusteredV2.bed.gz.chr*.gz" 1 1 5,4 ENCODE_Dnase_score,ENCODE_Dnase_cells ENCODE_Dnase t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.24.gz.addENCODE_Dnase.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.25.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.24.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_Dnase.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.25.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/human_permissive_enhancers_phase_1_and_2.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.25.gz.addFANTOM5_enhancer_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.26.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.25.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.26.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/robust_enhancers.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.26.gz.addFANTOM5_enhancer_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.27.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.26.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_robust.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer target annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.27.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_gene_pair.bed.gz.chr*.gz" 2 1 4 FANTOM5_enhancer_target FANTOM5_enhancer_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.27.gz.addFANTOM5_enhancer_target.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.28.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.27.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_target.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer expression annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.28.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_expression.summary.gz.chr*.gz" 2 1 4,5 FANTOM5_enhancer_expressed_tissue_cell,FANTOM5_enhancer_differentially_expressed_tissue_cell FANTOM5_enhancer_expression t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.28.gz.addFANTOM5_enhancer_expression.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.29.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.28.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_expression.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.29.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/DPIcluster_hg19_20120116.permissive_set.GencodeV10_annotated.osc.gz.chr*.gz" 30 1 FANTOM5_CAGE_peak_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.29.gz.addFANTOM5_CAGE_peak_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.30.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.29.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.30.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/hg19.cage_peak_phase1and2combined_coord.bed.gz.chr*.gz" 1 1 FANTOM5_CAGE_peak_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.30.gz.addFANTOM5_CAGE_peak_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.31.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.30.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_robust.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build Overviews .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline6 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.31.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/Ensembl_Build_Overviews/homo_sapiens.GRCh38.Regulatory_Build.regulatory_features.20161111.gff.gz.bed.gz.chr*.gz" 2 1 8,4 Ensembl_Regulatory_Build_feature_type,Ensembl_Regulatory_Build_ID Ensembl_Regulatory_Build_Overviews t true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.31.gz.addEnsembl_Regulatory_Build_Overviews.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.32.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.31.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_Overviews.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.32.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/TFBS_Summaries/homo_sapiens.GRCh38.motiffeatures.20161111.gff.gz.bed.gz.chr*.gz" 2 1 5,4 Ensembl_Regulatory_Build_TFBS,Ensembl_Regulatory_Build_TFBS_matrix Ensembl_Regulatory_Build_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.32.gz.addEnsembl_Regulatory_Build_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.33.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.32.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_TFBS.txt
echo "Done. "
date
echo "Searching dbNSFP_variant .."
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/dbNSFP/ search_dbNSFP40b2c -i /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz.dbNSFP.in -o /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz.dbNSFP.out -v hg38
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_dbNSFP_annotations_exl_geneinfo_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.gz.dbNSFP.out 5,6,12-26,31-85 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.33.gz true 1 2 4 hg38
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.33.gz.adddbNSFP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.33.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/dbNSFP4.0b2c.txt
echo "Done. "
date
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/type_specific.txt
echo "Searching Roadmap 15-state model .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_roadmap_15_state_model_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz true 5 6 /home/pmd-01/zhuliu/WGSA_08/resources/Roadmap-15-state_model/ "n"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz.addRoadmap15State.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.35.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.description.txt /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz.addRoadmap15State.column.txt
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.34.gz.addRoadmap15State.column.txt
echo "Done. "
date
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.35.gz "/home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.snp.gz"
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.0.*
echo "SNV annotation done. "
date
echo "Preparing input files ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g indel_to_snps3 "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz" "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz" "/home/pmd-01/zhuliu/WGSA_08/resources/hg38/"
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g hg38_to_hg19_commandline "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz" true /home/pmd-01/zhuliu/WGSA_08/resources/crossmap/ /home/pmd-01/zhuliu/WGSA_08/resources/hg19/
rm -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz"
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz.addhg38tohg19.gz" "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz"
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/chr_pos_ref_alt_hg38.txt
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/hg38_to_hg19.txt
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.gz" /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g input_to_ANNOVAR_vcf_dbNSFP2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz
echo "Done. "
date
echo "Running ANNOVAR/Ensembl indel annotations .."
cd /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/
perl /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/table_annovar.pl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb -buildver hg38 -protocol ensGene -operation g -polish -arg '-separate -transcript_function -hgvs -neargene 5000'
cd /home/pmd-01/zhuliu/WGSA_08/resources/
cd ..
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSA06_ANNOVAR_Ensembl_summary5_2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensGene /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensGene.ensembl.summary /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensembl.summary
gzip -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensembl.summary
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensembl.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_ANNOVAR_summary_rowcompressed_summary_commandline ensembl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensembl.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ensembl.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.37.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ensembl.txt
echo "Done. "
date
echo "Running ANNOVAR/Refseq indel annotations .."
cd /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/
perl /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/table_annovar.pl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb -buildver hg38 -protocol refGene -operation g -polish -arg '-separate -transcript_function -hgvs -neargene 5000'
cd /home/pmd-01/zhuliu/WGSA_08/resources/
cd ..
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSA06_ANNOVAR_RefSeq_summary5_2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refGene /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refGene.refseq.summary /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refseq.summary
gzip -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refseq.summary
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refseq.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_ANNOVAR_summary_rowcompressed_summary_commandline refseq /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refseq.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.37.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.refseq.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.37.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.37.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.38.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.37.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_refseq.txt
echo "Done. "
date
echo "Running ANNOVAR/UCSC knownGene indel annotations .."
cd /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/
perl /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/table_annovar.pl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb -buildver hg38 -protocol knownGene -operation g -polish -arg '-separate -transcript_function -hgvs -neargene 5000'
cd /home/pmd-01/zhuliu/WGSA_08/resources/
cd ..
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSA06_ANNOVAR_UCSC_summary5_2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.knownGene /home/pmd-01/zhuliu/WGSA_08/annovar20180416/annovar/humandb
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.knownGene.ucsc.summary /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ucsc.summary
gzip -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ucsc.summary
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ucsc.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_ANNOVAR_summary_rowcompressed_summary_commandline ucsc /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ucsc.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.38.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ANNOVAR.ucsc.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.38.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.38.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.39.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.38.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/annovar_ucsc.txt
echo "Done. "
date
echo "Running SnpEff/Ensembl indel annotations .."
java -Xmx60g -jar /home/pmd-01/zhuliu/WGSA_08/snpeff/snpEff/snpEff.jar -noStats -v GRCh38.86 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ensembl.vcf >/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/simpleGUI.jar -Xmx60g WGSA01_snpEff_summary6 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out true
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out.LOF_NMD.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out.TF_binding.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_snpEff_summary_rowcompressed_summary_commandline ensembl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.39.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_ensembl.out.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.39.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.39.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.40.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.39.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_ensembl.txt
echo "Done. "
date
echo "Running SnpEff/Refseq indel annotations .."
java -Xmx60g -jar /home/pmd-01/zhuliu/WGSA_08/snpeff/snpEff/snpEff.jar -noStats -v hg38 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.refseq.vcf >/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/simpleGUI.jar -Xmx60g WGSA01_snpEff_summary6 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out true
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out.LOF_NMD.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out.TF_binding.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_snpEff_summary_rowcompressed_summary_commandline refseq /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.40.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.snpEff_refseq.out.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.40.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.40.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.41.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.40.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snpeff_refseq.txt
echo "Done. "
date
echo "Running VEP indel annotations .."
mkdir /home/pmd-01/zhuliu/WGSA_08/tmp/dbSNP/11/VEP
cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.ensembl.vcf /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSA05_VEP_annotate10 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf /home/pmd-01/zhuliu/WGSA_08/tmp/dbSNP/11/VEP 2000 /home/pmd-01/zhuliu/WGSA_08/vep/ensembl-vep-release-94/ /home/pmd-01/zhuliu/WGSA_08/.vep/ /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ /home/pmd-01/zhuliu/WGSA_08/.vep/homo_sapiens/94_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz GRCh38
bash /home/pmd-01/zhuliu/WGSA_08/tmp/dbSNP/11/VEP.sh
rm /home/pmd-01/zhuliu/WGSA_08/tmp/dbSNP/11/VEP.sh
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/simpleGUI.jar/ -Xmx60g WGSA02_VEP_summary6_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.gz 
gzip -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.ensembl.summary
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.ensembl.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_VEP_summary_rowcompressed_summary_commandline ensembl /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.ensembl.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.41.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.ensembl.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.41.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.41.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.42.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.41.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_ensembl.txt
gzip -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.refseq.summary
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.refseq.summary.gz 1,2,3,4  t bar true 
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g WGSAprogram29_VEP_summary_rowcompressed_summary_commandline refseq /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.refseq.summary.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/resources/hg38/
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_annotation_based_on_chr_pos_ref_alt_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.42.gz 1 2 3 4  /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.gz.vcf.vepout.refseq.summary.gz.rowcompressed.gz.summary.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.42.gz.addanno.gz true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.42.gz.addanno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.43.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.42.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/vep_refseq.txt
echo "Done. "
date
echo "Searching dbSNP .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_dbSNP_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.43.gz true 1 2 3 4 indel "/home/pmd-01/zhuliu/WGSA_08/resources/dbSNP/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.43.gz.adddbSNP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.44.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.43.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/dbsnp.txt
echo "Done. "
date
echo "Searching GWAS catalog .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GWAS_catalog_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.44.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GWAS_catalog/gwas_catalog_v1.0.2-associations_e93_r2019-01-31.tsv.var.hg38.indel.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.44.gz.addGWAS_catalog.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.45.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.44.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GWAS_catalog2.txt
echo "Done. "
date
echo "Searching GRASP2 .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GRASP_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.45.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/GRASP/GRASP2final.summary.addhg38.indel.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.45.gz.addGRASP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.46.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.45.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GRASP.txt
echo "Done. "
date
echo "Searching clinvar .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_clinvar_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.46.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/clinvar/hg38/clinvar_20190311.vcf.gz.summary.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.46.gz.addClinvar.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.47.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.46.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/clinvar4.txt
echo "Done. "
date
echo "Searching COSMIC .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_COSMIC_coding_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.47.gz true 1 2 3 4 "/home/pmd-01/zhuliu/WGSA_08/resources/COSMIC/hg38/CosmicCodingMuts.vcf.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.47.gz.addCOSMIC.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.48.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.47.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/cosmic.txt
echo "Done. "
date
echo "Searching GTEx eQTL ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_GTEX_eQTL_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.48.gz true 5 6 7 8 "/home/pmd-01/zhuliu/WGSA_08/resources/GTEx/GTEx_Analysis_v7_eQTL.summary2.gz.indel.gz.chr*.gz"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.48.gz.addGTEXeQTL.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.49.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.48.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GTEx4.txt
echo "Done. "
date
echo "Searching 1000 genomes phase 3 allele frequencies .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_1000genomes_phase3_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.49.gz true 1 2 3 4 "All.chr*.hg38.phase3.+AC+AN.1alt.left-normalized.vcf.gz.indel.gz" "/home/pmd-01/zhuliu/WGSA_08/resources/1000Gp3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.49.gz.add1000genome_p3.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.50.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.49.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/1000genome_p3.txt
echo "Done. "
date
echo "Searching UK10K cohorts allele frequencies .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_UK10K_frequencies2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.50.gz true 5 6 7 8 "/home/pmd-01/zhuliu/WGSA_08/resources/UK10K/" indel
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.50.gz.addUK10K.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.51.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.50.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/uk10k.txt
echo "Done. "
date
echo "Searching ESP6500 consortium allele frequencies .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ESP6500_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.51.gz true 5 6 7 8 indel "/home/pmd-01/zhuliu/WGSA_08/resources/ESP6500/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.51.gz.addESP6500.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.52.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.51.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ESP6500.txt
echo "Done. "
date
echo "Searching ExAC consortium allele frequencies .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_ExACgz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.52.gz true 5 6 7 8 indel "/home/pmd-01/zhuliu/WGSA_08/resources/ExACr0.3/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.52.gz.addExAC.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.53.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.52.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ExAC.txt
echo "Done. "
date
echo "Searching gnomAD consortium exomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_exomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.53.gz true 5 6 7 8 indel "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.53.gz.addgnomAD_exomes.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.54.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.53.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_exomes3.txt
echo "Done. "
date
echo "Searching gnomAD consortium genomes subset allele frequencies ..."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_gnomAD_genomes_commandline3 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.54.gz true 5 6 7 8 indel "/home/pmd-01/zhuliu/WGSA_08/resources/gnomAD/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.54.gz.addgnomAD_genomes.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.55.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.54.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/gnomAD_genomes3.txt
echo "Done. "
date
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/indel_summary_format.txt
mv -f "/home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/11.vcf.indel.snp.gz" /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.0.gz
echo "Searching dbscSNV .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_splicing_consensus_prediction_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.0.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/scSNV/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.0.gz.addSplicingPred.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.1.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.0.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/scSNV.txt
echo "Done. "
date
echo "Searching snoRNA/miRNA annotation .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.1.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/snoRNA_miRNA_hg38.bed.gz.chr*.gz" 1 1 5,6 sno_miRNA_name,sno_miRNA_type snoRNA_miRNA t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.1.gz.addsnoRNA_miRNA.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.2.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.1.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/snoRNA_miRNA.txt
echo "Done. "
date
echo "Searching miRNA target annotation .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.2.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/snoRNA_miRNA/Predicted_Targets_6cols.hg38.bed.gz.chr*.gz" 1 1 4,5 UTR3_miRNA_target,TargetScan_context++_score_percentile UTR3_miRNA_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.2.gz.addUTR3_miRNA_target.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.3.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.2.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/UTR3_miRNA_target.txt
echo "Done. "
date
echo "Searching GERP++ conservation scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_GERP_gz_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.3.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/GERP/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.3.gz.addGERP.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.4.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.3.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/GERP.txt
echo "Done. "
date
echo "Searching RegulomeDB scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_regulome_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.4.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/regulomeDB/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.4.gz.addRegulomeDB.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.5.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.4.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/RegulomeDB.txt
echo "Done. "
date
echo "Searching funseq-like noncoding scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_motif_breaking_funseq_nc_gz_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.5.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/funseq-like/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.5.gz.addfunseq-like-score.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.6.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.5.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/funseq.txt
echo "Done. "
date
echo "Searching CADD scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_CADD_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.6.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/CADDv1.4/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.6.gz.addCADD.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.7.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.6.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/CADD.txt
echo "Done. "
date
echo "Searching fathmm-MKL scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_FATHMM_MKL_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.7.gz true 5 6 8 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmMKL/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.7.gz.addFATHMM-MKL.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.8.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.7.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/MKL.txt
echo "Done. "
date
echo "Searching fathmm-XF scores .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg38_FATHMM_XF_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.8.gz true 1 2 4 "/home/pmd-01/zhuliu/WGSA_08/resources/fathmmXF/hg38/"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.8.gz.addFATHMM-XF.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.9.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.8.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/fathmmXF.txt
echo "Done. "
date
echo "Searching ORegAnno regulatory annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_gfflike_annotation_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.9.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/ORegAnno/ORegAnno_Combined_2015.12.22.tsv.gz.hg38.gz.chr*.gz" 2 16 4,12 ORegAnno_type,ORegAnno_PMID ORegAnno t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.9.gz.addORegAnno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.10.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.9.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ORegAnno.txt
echo "Done. "
date
echo "Searching ENCODE TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.10.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/Txn_Factor_ChIP/wgEncodeRegTfbsClusteredWithCellsV3.bed.gz.chr*.gz" 1 1 4,5,6 ENCODE_TFBS,ENCODE_TFBS_score,ENCODE_TFBS_cells ENCODE_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.10.gz.addENCODE_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.11.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.10.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_TFBS.txt
echo "Done. "
date
echo "Searching ENCODE Dnase annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.11.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/ENCODE/DNase_Clusters/wgEncodeRegDnaseClusteredV2.bed.gz.chr*.gz" 1 1 5,4 ENCODE_Dnase_score,ENCODE_Dnase_cells ENCODE_Dnase t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.11.gz.addENCODE_Dnase.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.12.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.11.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ENCODE_Dnase.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.12.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/human_permissive_enhancers_phase_1_and_2.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.12.gz.addFANTOM5_enhancer_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.13.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.12.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust enhancer annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.13.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/robust_enhancers.bed.gz.chr*.gz" 1 1 FANTOM5_enhancer_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.13.gz.addFANTOM5_enhancer_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.14.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.13.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_robust.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer target annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.14.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_gene_pair.bed.gz.chr*.gz" 2 1 4 FANTOM5_enhancer_target FANTOM5_enhancer_target t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.14.gz.addFANTOM5_enhancer_target.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.15.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.14.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_target.txt
echo "Done. "
date
echo "Searching FANTOM5 enhancer expression annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.15.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/Enhancers/enhancer_expression.summary.gz.chr*.gz" 2 1 4,5 FANTOM5_enhancer_expressed_tissue_cell,FANTOM5_enhancer_differentially_expressed_tissue_cell FANTOM5_enhancer_expression t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.15.gz.addFANTOM5_enhancer_expression.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.16.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.15.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_enhancer_expression.txt
echo "Done. "
date
echo "Searching FANTOM5 permissive CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.16.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/DPIcluster_hg19_20120116.permissive_set.GencodeV10_annotated.osc.gz.chr*.gz" 30 1 FANTOM5_CAGE_peak_permissive
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.16.gz.addFANTOM5_CAGE_peak_permissive.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.17.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.16.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_permissive.txt
echo "Done. "
date
echo "Searching FANTOM5 robust CAGE peaks .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_Yes_No_commandline2 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.17.gz true 5 6 "/home/pmd-01/zhuliu/WGSA_08/resources/FANTOM5/CAGE_peaks_annotation/hg19.cage_peak_phase1and2combined_coord.bed.gz.chr*.gz" 1 1 FANTOM5_CAGE_peak_robust
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.17.gz.addFANTOM5_CAGE_peak_robust.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.18.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.17.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/FANTOM5_CAGE_peak_robust.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build Overviews .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline6 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.18.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/Ensembl_Build_Overviews/homo_sapiens.GRCh38.Regulatory_Build.regulatory_features.20161111.gff.gz.bed.gz.chr*.gz" 2 1 8,4 Ensembl_Regulatory_Build_feature_type,Ensembl_Regulatory_Build_ID Ensembl_Regulatory_Build_Overviews t true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.18.gz.addEnsembl_Regulatory_Build_Overviews.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.19.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.18.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_Overviews.txt
echo "Done. "
date
echo "Searching Ensembl Regulatory Build TFBS annotations .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_bedlike_annotation_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.19.gz true 1 2 "/home/pmd-01/zhuliu/WGSA_08/resources/Ensembl_regulatory_build/TFBS_Summaries/homo_sapiens.GRCh38.motiffeatures.20161111.gff.gz.bed.gz.chr*.gz" 2 1 5,4 Ensembl_Regulatory_Build_TFBS,Ensembl_Regulatory_Build_TFBS_matrix Ensembl_Regulatory_Build_TFBS t
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.19.gz.addEnsembl_Regulatory_Build_TFBS.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.19.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/Ensembl_Regulatory_Build_TFBS.txt
echo "Done. "
date
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/type_specific.txt
echo "Searching Roadmap 15-state model .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g add_hg19_roadmap_15_state_model_commandline /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz true 5 6 /home/pmd-01/zhuliu/WGSA_08/resources/Roadmap-15-state_model/ "n"
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz.addRoadmap15State.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.21.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ append_non_empty_lines /home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.description.txt /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz.addRoadmap15State.column.txt
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.20.gz.addRoadmap15State.column.txt
echo "Done. "
date
echo "Preparing indel annotation output .."
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g row_compress_commandline5 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.21.gz 10,11,12 t bar true
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.21.gz.rowcompressed.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.22.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.21.gz
java -cp /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/:/home/pmd-01/zhuliu/WGSA_08/resources/javaclass/ -Xmx60g indel_add_compressed_anno_commandline4 /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.55.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.22.gz 10
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.55.gz.addAnno.gz /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.56.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.55.gz
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation2.in.22.gz
echo "Done. "
date
mv -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.56.gz "/home/pmd-01/zhuliu/WGSA_08/res/dbSNP/11.annotated.indel.gz"
rm -f /home/pmd-01/zhuliu/WGSA_08/work/dbSNP/11/annotation.in.36.*
echo "InDel annotation done. "
date
