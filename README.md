# pecgs-pipeline

A CWL pipeline for running dinglab tools downstream from fastqs/bams. Built for PE-CGS project, but also generally useful :).

Currently runs on WashU RIS compute1.

## Installation

Clone the repository with the following command (note that it is different from the usual github clone command).

```bash
git clone --recurse-submodules https://github.com/ding-lab/pecgs-pipeline.git
```

## Updating the pipeline

Due to submodule craziness, the easiest way to update the pipeline is to remove the repository and reinstall.

```bash
rm -rf pecgs-pipeline
git clone --recurse-submodules https://github.com/ding-lab/pecgs-pipeline.git
```

If you would like to try and update the pipeline without removing it, you can run the following.

```bash
git pull
git submodule update submodules/
```

This command will sometimes fail due to intermediary files, and this is a pain to try and fix. Usually the easier solution is just deleting the repository and reinstalling.


## Overview

#### Tools

The following tools are incorporated into the pecgs-pipeline:

+ DNA-seq alignment (input dependent)
  + Only run in pipelines where wxs/wgs fastqs are present as inputs
  + [github repo](https://github.com/estorrs/align-dnaseq)
+ Somatic variant calling
  + Runs TinDaisy and somaticwrapper variant callers
    + [TinDaisy github repo](https://github.com/ding-lab/TinDaisy)
    + [somaticwrapper github repo](https://github.com/estorrs/pecgs-somaticwrapper)
+ Germline variant calling
  + Runs TinJasmine variant caller
  + [github repo](https://github.com/ding-lab/TinJasmine)
+ Fusions
  + Runs dinglab fusion pipeline
  + [github repo](https://github.com/estorrs/pecgs-fusion)
    + original non-cwl fusion pipeline [repo](https://github.com/ding-lab/Fusion_hg38)
+ Bulk RNA-seq expression
  + runs Bobo's bulk RNA-seq expression pipeline
  + [github_repo](https://github.com/estorrs/pecgs-bulk-expression)
    + original non-cwl bulk expression pipeline [repo](https://github.com/ding-lab/HTAN_bulkRNA_expression)
+ Copy number variants (CNV)
  + Runs dinglab cnv pipeline (which is gatk4 based)
  + [github repo](https://github.com/estorrs/pecgs-cnv)
    + original non-cwl cnv pipeline [repo](https://github.com/ding-lab/GATK4SCNA)
+ Microsatellite instability
  + Runs [MSIsensor](https://github.com/ding-lab/msisensor)
+ Structural variants (WGS)
  + Runs [SomaticSV](https://github.com/ding-lab/SomaticSV)
+ Neoantigen discovery
  + Runs [Neoscan](https://github.com/ding-lab/neoscan/tree/cp1.v1.3)
+ Pathogenic germline variants
  + Runs [Charger](https://github.com/estorrs/pecgs-charger)
    + original non-cwl charger V0.5.4 [repo](https://github.com/ding-lab/CharGer/tree/7d7d2911b89261fa5dceea6395a5d188a82757f2)
+ Druggability
  + Runs [Druggability pipeline](https://github.com/estorrs/pecgs-druggability)
    + original non-cwl druggability pipeline [repo](https://github.com/ding-lab/druggability)

#### Inputs

There are multiple pipeline variants that are dependent on available input data types. Currently there are only three variants, though more may be available in the future.

The inputs to the pipeline are specified in a **run list** file. See an example run list [here](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/pecgs_TN_wxs_bam/run_list.txt). This is a tab-separated file with the following columns (some input related columns are dependent on pipeline variant, and are listed below):

**Important: please limit the number of cases in the run list to less than ~10-15 for each run of the pipeline. Cromwell leaves around a lot of temporary files that are quite large and can quickly fill up our lab's `/scratch1` allocation if too many cases are run simultaneously. If you have a large number of cases to run, please run them in batches one after another.**

**Important: please do not include spaces or special characters in the run id or case id, as this could lead to issues when the pipeline is naming files. Only use alphanumeric characters (A-Z, 0-9), hyphens (-), and underscores(_).** 

**Important: It is important that there are no missing values in the run list and sequencing info files. If you do do not have a value for a particular cell then make up a dummy value.** 

*Common columns*

+ run_id
  + a unique identifier for each sample being run in the batch. This id must be unique among samples in the batch. It is recommended the `run_id` be a concatenation of the `sample_id` and `run_uuid`, i.e. `{sample_id}_{run_uuid}`.
+ case_id
  + case name of the case being run.
+ run_uuid
  + [universally unique identifier (UUID)](https://en.wikipedia.org/wiki/Universally_unique_identifier) for the run. This identifier is for tracking purposes, so if you don't care too much about that you can just use integers or make up a random string here. For PE-CGS runs please use a valid uuid. In python this can be done using [uuid.uuid4()](https://docs.python.org/3/library/uuid.html) and in R with [UUIDgenerate](https://rdrr.io/cran/uuid/man/UUIDgenerate.html)

*Input dependent columns*

These columns will change depending on which pipeline variant is being used and are listed for each pipeline in the section below.

+ project
  + used in WXS pipelines. Specifies project specific configurations. Currently, this is used in selecting BED files for VAF rescue in TinDaisy and somaticwrapper. If you want the bed files to be correct, make sure the project name is correct. See the `disease` bullet point for more details.
+ disease
  + used in WXS pipelines. Specifies the cancer type of a given case. Is used in two places in the pipeline
    + Is used in the druggability pipeline for the `-at` annotate trials keyword. For the annotate trials keyword to be used, disease must be one of the following: ['MM', 'CRC', 'CHOL']. If disease is not one of the values in the previous list, then the disease will default to '' and annotate trials keyword will not be used in the druggability pipeline.
    + Is used to select the VAF rescue bed file to use with TinDaisy. If the project is PECGS, CHOL, MM, and CHOL are valid diseases and a bed file will be selected specific to those cancer types that has been made for the PECGS project. If project is TCGA, then all cancer type [abbreviations](https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/tcga-study-abbreviations) in TCGA are valid. Otherwise, a default list of 299 genes from the pancan driver paper will be used. The potential bed files that can be used are [here](https://github.com/estorrs/wombat/tree/master/wombat/beds).

For file and directory path inputs, there will be two columns in the run list: one specifying the filepath, and another specifying the [universally unique identifier (UUID)](https://en.wikipedia.org/wiki/Universally_unique_identifier) of the file. The file uuid is for tracking purposes, so if you don't care too much about that you can just use integers or make up a random string here. For PE-CGS runs please use the uuid for the file that is in the bammap.


The following pipelines are available:

+ **pecgs_TN_wxs_fq**
  + inputs
    + Tumor WXS fastqs
    + Normal WXS fastqs
  + run list columns
    + `run_id`, `case_id`, `project`, `disease`, `run_uuid`, `wxs_normal_R1.filepath`, `wxs_normal_R1.uuid`, `wxs_normal_R2.filepath`, `wxs_normal_R2.uuid`, `wxs_tumor_R1.filepath`, `wxs_tumor_R1.uuid`, `wxs_tumor_R2.filepath`, `wxs_tumor_R2.uuid`
  + [example run list](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/pecgs_TN_wxs_fq/run_list.txt)
+ **pecgs_TN_wxs_bam**
  + inputs
    + Tumor WXS bam
    + Normal WXS bam
  + run list columns
    + `run_id`, `case_id`, `project`, `disease`, `run_uuid`, `wxs_normal_bam.filepath`, `wxs_normal_bam.uuid`, `wxs_tumor_bam.filepath`, `wxs_tumor_bam.uuid`
  + [example run list](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/pecgs_TN_wxs_bam/run_list.txt)
+ **pecgs_TN_wgs_bam**
  + inputs
    + Tumor WGS bam
    + Normal WGS bam
  + run list columns
    + `run_id`, `case_id`, `project`, `run_uuid`, `wgs_normal_bam.filepath`, `wgs_normal_bam.uuid`, `wgs_tumor_bam.filepath`, `wgs_tumor_bam.uuid`
  + [example run list](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/pecgs_TN_wgs_bam/run_list.txt)
+ **pecgs_T_rna_fq**
  + inputs
    + Tumor RNA-seq fastqs
  + run list columns
    + `run_id`, `case_id`, `project`, `run_uuid`, `rna-seq_tumor_R1.filepath`, `rna-seq_tumor_R1.uuid`, `rna-seq_tumor_R2.filepath`, `rna-seq_tumor_R2.uuid`
  + [example run list](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/pecgs_T_rna_fq/run_list.txt)

#### Outputs

The pecgs pipelines output a variety of files associated with the various tools incorporated in the pipeline.

The outputs are the following and separated by pipeline input data type:

+ **WXS**
  + DNA-seq alignment (input dependent)
    + aligned, sorted, and indexed wxs tumor bam
    + aligned, sorted, and indexed wxs normal bam
  + Somatic variant calling
    + tindaisy_output_vcf_all
    + tindaisy_output_vcf_clean
    + tindaisy_output_maf_clean
    + somaticwrapper_dnp_annotated_maf
    + somaticwrapper_dnp_annotated_coding_maf
    + somaticwrapper_withmutect_maf
  + Germline variant calling
    + tinjasmine_output_vcf_all
    + tinjasmine_output_vcf_clean
    + tinjasmine_output_maf_clean
  + CNV
    + gene_level_cnv
  + Microsatellite instability
    + msisensor_output_summary
    + msisensor_output_dis
    + msisensor_output_somatic
    + msisensor_output_germline
  + Pathogenic variants
    + charger_filtered_tsv
    + charger_rare_threshold_filtered_tsv
  + Neoantigen discovery
    + neoscan_snv_summary
    + neoscan_indel_summary
  + Druggability
    + druggability_output
    + druggability_aux_trials_output
+ **WGS**
  + Somatic SV
    + somatic_sv_vcf
    + somatic_sv_evidence_bams
+ **RNA-seq**
  + Fusions
    + filtered_fusions
    + total_fusions
  + Bulk RNA-seq expression
    + readcounts_and_fpkm_tsv
    + output_bam

If you require an intermediate output for any of the tools, they can be extracted from the cromwell working directory of the sample of interest. This run directory is listed in `run_summary.txt`

## Running the pipeline

Quick Note: Example scripts for all the below steps/commands for each pipeline variant are available [here](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples)

First, if you haven't already, clone the repository with the following command (note that it is different from the usual github clone command).

```bash
git clone --recurse-submodules https://github.com/ding-lab/pecgs-pipeline.git
```

Then navigate inside the src/compute1 directory

```bash
cd pecgs-pipeline/src/compute1
```

There are four main steps to running the pecgs pipelines: 1) generation of run directory/scripts required to run the pipeline, 2) removal of large unnecessary intermediate files generated during pipeline run, 3) generation of pipeline run summary files, and 4) moving/copying pipeline run to another location (optional).

Compute1 will only allow a small number of jobs to run at the same time by default. To allow for more jobs to run in parallel you will need to adjust the number of jobs that can be run by the default job group. To do this run the below command (replace USERNAME with your compute1 username and N_JOBS with how many jobs you would like to run in parallel). A value of N_JOBS around ~50 is usually good (this number is NOT how many samples will be run in parallel, but how many pipeline steps across samples will be run in parallel. You may want to increase or decrease this number depending on how many samples you want to run in parallel.

```bash
bgmod -L N_JOBS /USERNAME/default
```

#### Step 1: Generation of run directory and scripts

The pecgs-pipeline is most easily run on compute1 from an interactive docker session. To launch this session run the following command:

```bash
export LSF_DOCKER_VOLUMES="/storage1/fs1/dinglab/Active:/storage1/fs1/dinglab/Active /scratch1/fs1/dinglab:/scratch1/fs1/dinglab"
export PATH="/miniconda/envs/pecgs/bin:$PATH"
bsub -q dinglab-interactive -G compute-dinglab -Is -a 'docker(estorrs/pecgs-pipeline:0.0.2)' '/bin/bash'
```
NOTE: if the directory you intend to use for pipeline outputs is not in `/storage1/fs1/dinglab/Active` or `/scratch1/fs1/dinglab` you will need to add that path to the LSF_DOCKER_VOLUMES environmental variable in the first line.

You should now be inside a running container.

To generate the run directory, execute the following command. Replace PIPELINE_NAME with the pipeline variant you would like to run (i.e. pecgs_TN_wxs_bam), RUN_LIST with the filepath of the run list describing samples you would like to run (see inputs section for more details), and RUN_DIR with the absolute filepath where you would like the runs to execute. The RUN_DIR **must** be on `/scratch1`. `/storage1` has caching issues that may cause some steps of the pipeline to fail.

```bash
python generate_run_commands.py make-run PIPELINE_NAME RUN_LIST RUN_DIR
```

NOTE: for additional arguments to generate_run_commands.py see **Additional arguments to generate_run_commands.py** section. Some of these arguments include being able to specify which compute1 queue to use and how to pass in sequencing info for fastq files.

Following execution of this command, a directory should now exist at whatever path was specified for RUN_DIR. Inside that directory you should see one file: `1.run_jobs.sh`. There should also be three directories: `inputs`, `logs`, and `runs`.

`inputs` holds input configs and files used while running the pipeline. `runs` is the directory where all runs will execute. `logs` will contain the log file for each run in the run list.

To start the run **open a new compute1 terminal** (i.e. not the same terminal running the container that was created in the step above).

Then navigate to RUN_DIR. To start the runs, from inside RUN_DIR run `1.run_jobs.sh`.

```bash
bash 1.run_jobs.sh
```

Your pipeline runs should now be running :).

To check on progress you can view log files for each run inside the `logs` directory.

You can see currently running jobs with the `bjobs` command.

For a more detailed look at the pipeline, you can get information from the cromwell server that is responsible for running the pipeline.

To look up more detailed information on each workflow, you will need to get the cromwell ID that is assigned to each run. To do so, run the following command from inside RUN_DIR.

```bash
egrep -H 'cwl \(Unspecified version\) workflow' logs/* | sed 's/^logs\/\(.*\).log:.* workflow \(.*\) .*$/\1, \2/'
```

The result of this command should give you two fields, the first of which is the `run_id` from the run list, and the second is the cromwell workflow id. The cromwell workflow id is what you can use with the below API calls to get more information on individual workflows.

###### Cromwell server commands

Replace {WORKFLOW_ID} in the below urls with the cromwell workflow id you are interested in.

To get the status of a workflow put the following in your browser `http://mammoth.wusm.wustl.edu:8000/api/workflows/v1/{WORKFLOW_ID}/status`

To get the outputs of a workflow put the following in your browser `http://mammoth.wusm.wustl.edu:8000/api/workflows/v1/{WORKFLOW_ID}/outputs`

To get a timing diagram for a workflow put the following in your browser `http://mammoth.wusm.wustl.edu:8000/api/workflows/v1/{WORKFLOW_ID}/timing`

To see metadata for a workflow put the following in your browser `http://mammoth.wusm.wustl.edu:8000/api/workflows/v1/{WORKFLOW_ID}/metadata?expandSubWorkflows=false`

You can also see additional GET endpoints at `http://mammoth.wusm.wustl.edu:8000`


#### Step 2: Deletion of large intermediate files

Cromwell leaves behind a lot of intermediary files that can be quite large. To clean up the workflow directory run the following command from **the first terminal used at the beginning of step 1**.

```bash
python generate_run_commands.py tidy-run PIPELINE_NAME RUN_LIST RUN_DIR
```

There should now be a file called `2.tidy_run.sh` in RUN_DIR.

This file will contain commands to remove all **finished and successfully completed** pipeline runs. If you have multiple runs in your run_list then only runs that finished and completed successfully will have files to be deleted inside `2.tidy_run.sh`.

If you are performing a large number of runs it is usually a good idea to periodically run the above command to clean out intermediary files, otherwise they may fill up memory in whatever directory you are using to execute your runs.

To run `2.tidy_run.sh`, in a compute1 terminal not inside a running container run this script to delete large intermediary files.

```bash
bash 2.tidy_run.sh
```

#### Step 3: Generation of analysis summary and run summary files

The pecgs-pipeline also has tooling to track output files and run metadata.

To generate result files run the following command from the terminal at the beginning of step 1.

```bash
python generate_run_commands.py summarize-run PIPELINE_NAME RUN_LIST RUN_DIR
```

After running this command, there should be three new files in RUN_DIR (assuming there are runs that have successfully completed): `analysis_summary.txt`, `run_summary.txt`, and `runlist.txt`.

+ `analysis_summary.txt`
  + A tab-separated txt file containing output files and various metadata.
  + [example analysis summary file](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/summary_files/analysis_summary.txt)
+ `run_summary.txt`
  + A tab-separated txt file containing run metadata for each run in the run list.
  + [example run summary file](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/summary_files/run_summary.txt)

Important Note: Only runs that have completed will be in the summary files. i.e. if you are running 10 runs and 4 have completed, outputs for those 4 runs will be included in the summary files, but not the 6 runs that are still ongoing. **If you run this command multiple times throughout a run new UUIDs will be assigned to each output file in analysis_summary.txt**.

#### Step 4: Copy/move analysis summary and run summary files (optional)

This step allows for the copying/moving of runs to a new location, along with automatic regeneration of analysis and run summary files so filepaths remain correct. This step is useful if you are running in the `/scratch1` on compute1 since all files in that directory are automatically deleted by RIS after 30 days.

```bash
python generate_run_commands.py move-run pecgs_TN_wxs_bam run_list.txt RUN_DIR --target-dir TARGET_DIR
```

After running this command, the RUN_DIR should now be moved inside TARGET_DIR, along with regenerated `run_summary.txt` and `analysis_summary.txt`.

The default behavior is to copy RUN_DIR, but if you want to move it, you can include the `--no-copy` flag. I would recommend against this, as it's generally safer in this situation to copy and then manually go back and remove the original directory.

## Examples

Example inputs and commands for each pipeline are available at the following links: [pecgs_TN_wxs_fq](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_TN_wxs_fq), [pecgs_TN_wxs_bam](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_TN_wxs_bam), and [pecgs_T_rna_fq](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_T_rna_fq)

A run directory for the [pecgs_TN_wxs_fq](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_TN_wxs_fq) test example with all logs, inputs, runs, and generated scripts/summary files can be found at `/storage1/fs1/dinglab/Active/Projects/estorrs/wombat/tests/data/pecgs_TN_wxs_fq/run`.

A run directory for the [pecgs_TN_wxs_bam](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_TN_wxs_bam) test example with all logs, inputs, runs, and generated scripts/summary files can be found at `/storage1/fs1/dinglab/Active/Projects/estorrs/wombat/tests/data/pecgs_TN_wxs_bam/run`.

A run directory for the [pecgs_TN_wgs_bam](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_TN_wgs_bam) test example with all logs, inputs, runs, and generated scripts/summary files can be found at ``.

A run directory for the [pecgs_T_rna_fq](https://github.com/ding-lab/pecgs-pipeline/tree/master/examples/pecgs_T_rna_fq) test example with all logs, inputs, runs, and generated scripts/summary files can be found at `/storage1/fs1/dinglab/Active/Projects/estorrs/wombat/tests/data/pecgs_T_rna_fq/run`.


**Alignment-only pipeline**

* Doing a whole-exome alignment, for example, can be accomplished by replacing `cwl/pecgs_workflows/pecgs_TN_wxs_fq.cwl` with `cwl/pecgs_workflows/alignOnly/pecgs_TN_wxs_fq.cwl` and using the `pecgs_TN_wxs_fq` as the pipeline name in Steps 1-4 above.

*   Pseudo-code for running the pipeline manually stepwise:

    First launch the pecgs-pipeline Docker image. Use `estorrs/pecgs-pipeline:0.0.2` unless you are running the summarize-run step, in which case use `estorrs/pecgs-pipeline:0.0.1` instead due to a bug.

       export PROJECT_DIR=/path/to/project/directory
       export PIPELINE=pecgs_TN_wxs_fq
       export RUN_LIST=/path/to/your/pecgs_TN_wxs_fq.tsv
       export RUN_DIR=/path/to/your/run/directory
       export RUN_LIST_TXT=${RUN_DIR}/runlist.txt
       export TARGET_DIR=/path/to/where/you/store/pecgs/runs    # Note: RUN_DIR will appear inside TARGET_DIR
       mkdir -p ${RUN_DIR}
       cd ${PROJECT_DIR}/pecgs-pipeline/src/compute1
       ##
       ## Run one of the commands:
       ##
       python generate_run_commands.py make-run  $PIPELINE  $RUN_LIST  $RUN_DIR
       python generate_run_commands.py tidy-run $PIPELINE $RUN_LIST $RUN_DIR
       python generate_run_commands.py summarize-run $PIPELINE $RUN_LIST $RUN_DIR
       python generate_run_commands.py move-run  $PIPELINE   $RUN_LIST_TXT   $RUN_DIR   --target-dir $TARGET_DIR


## Additional arguments to generate_run_commands.py

usage: generate_run_commands.py [-h] [--sequencing-info SEQUENCING_INFO] [--input-config INPUT_CONFIG] [--proxy-run-dir PROXY_RUN_DIR] [--additional-volumes ADDITIONAL_VOLUMES] [--cromwell-port CROMWELL_PORT] {make-run,tidy-run,summarize-run} {pecgs_TN_wxs_fq_T_rna_fq,pecgs_TN_wxs_bam_T_rna_fq} run_list run_dir

positional arguments:
+ {make-run,tidy-run,summarize-run,move-run}
  + Which command to execute. make-run will generate scripts needed to run pipeline. tidy-run will clean up large, uneccessary input files. summarize-run will create summary files with run metadata. move-run will move run to new directory and regenerate summary files.
+ {pecgs_TN_wxs_fq, pecgs_TN_wxs_bam, pecgs_TN_wgs_bam, pecgs_T_rna_fq}
  + Which pipeline version to run.
+ run_list
  + Filepath of table containing run inputs.
+ run_dir
  + Directory on compute1 that will be used for the pipeline runs.

optional arguments:
+ -h, --help
  + show this help message and exit
+ --sequencing-info
  + Sequencing info for fastqs if you want aligned bams to have correct metadata. Table must have a row for every dna-seq fastq and the following columns: run_id, sample_id, run_uuid, experimental_strategy, sample_type, flowcell, lane, index_sequencer, library_preparation, platform. If inputs are wxs or wgs fastqs and no sequencing info is provided then default dummy values will be used during alignment. An example sequencing info table is located [here](https://github.com/ding-lab/pecgs-pipeline/blob/master/examples/ht191/sequencing_info.txt).
+ --input-config
  + YAML file containing inputs that will override the default pipeline parameters. All default parameters are listed [here](https://github.com/estorrs/wombat/blob/master/wombat/templates/compute1.defaults.pecgs_TN_wxs_bam_T_rna_fq.yaml).
+ --proxy-run-dir
  + Use if running this script on a system that is not compute1. Will write inputs to a proxy directory that can then be copied to compute1.
+ --additional-volumes
  + Additional volumnes to map on compute1 on top of /storage1/fs1/dinglab and /scratch1/fs1/dinglab. For example if your input files do not have /storage1/fs1/dinglab and /scratch1/fs1/dinglab in their filepath then you need to include their directory here.
+ --queue
  + Which queue to run the jobs in on compute1. Default is general.
+ --target-dir
  + Target directory to move run to. Used in move-run.
+ --no-copy
  + Default behavior is to copy run directory to the target directory, but if --no-copy flag is included then run will be moved, deleting the original directory.

## Common Issues

+ Getting a `bash: /usr/bin/java: No such file or directory` error.
  + This likely means `1.run_jobs.sh` was run from inside an already running container. This script must **not** be run from a running container/interactive session.












