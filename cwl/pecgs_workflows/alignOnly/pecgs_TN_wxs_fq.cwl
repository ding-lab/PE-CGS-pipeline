class: Workflow
cwlVersion: v1.0
id: pecgs_TN_wxs_fq
inputs:
- id: sample
  type: string
- default: ''
  id: disease
  type: string?
- default: 40
  id: cpu
  type: int?
- id: tumor_wxs_fq_1
  type: File
- id: tumor_wxs_fq_2
  type: File
- id: normal_wxs_fq_1
  type: File
- id: normal_wxs_fq_2
  type: File
- id: known_sites
  secondaryFiles:
  - .tbi
  type: File
- id: reference
  secondaryFiles:
  - .amb
  - .ann
  - .bwt
  - .fai
  - .pac
  - .sa
  - ^.dict
  type: File
- default: flowcellABCDE
  id: wxs_normal_flowcell
  type: string?
- default: '1'
  id: wxs_normal_lane
  type: string?
- default: sequencerABCDE
  id: wxs_normal_index_sequencer
  type: string?
- default: lib1
  id: wxs_normal_library_preparation
  type: string?
- default: ILLUMINA
  id: wxs_normal_platform
  type: string?
- default: flowcellABCDE
  id: wxs_tumor_flowcell
  type: string?
- default: '1'
  id: wxs_tumor_lane
  type: string?
- default: sequencerABCDE
  id: wxs_tumor_index_sequencer
  type: string?
- default: lib1
  id: wxs_tumor_library_preparation
  type: string?
- default: ILLUMINA
  id: wxs_tumor_platform
  type: string?
- id: reference_dir
  type: Directory
- id: target_interval_list
  type: File
- id: common_biallelic
  type: File
- id: protein_coding_gene
  type: File
- id: pool_of_normals
  type: File
- id: microsatellite
  type: File
- default: 1
  id: minimal_homopolymer_size
  type: int?
- default: 1
  id: minimal_microsatellite_size
  type: int?
- default: false
  id: rescue_clinvar
  type: boolean?
- default: false
  id: rescue_cosmic
  type: boolean?
- id: tindaisy_vep_cache_version
  type: string
- id: tindaisy_vep_cache_gz
  type: File
- id: clinvar_annotation
  type: File
- id: classification_config
  type: File
- id: af_config
  type: File
- id: call_regions
  type: File
- id: canonical_BED
  type: File
- id: tindaisy_chrlist
  type: File
- id: strelka_config
  type: File
- id: centromere_bed
  type: File
- id: assembly
  type: string
- id: varscan_config
  type: File
- id: pindel_config
  type: File
- id: tindaisy_rescue_bed
  type: File
- id: centromere
  type: File
- id: tinjasmine_chrlist
  type: File
- id: Canonical_BED
  type: File
- id: ROI_BED
  type: File
- id: pindel_config_template
  type: File
- id: tinjasmine_vep_cache_gz
  type: File
- id: neoscan_ref_dir
  type: Directory
- id: neoscan_bed
  type: File
- default: dna
  id: neoscan_input_type
  type: string?
- id: charger_inheritance_gene_list
  type: File
- id: charger_pp2_gene_list
  type: File
- id: charger_pathogenic_variants
  type: File
- id: charger_hotspot3d_clusters
  type: File
- id: charger_clinvar_alleles
  type: File
label: pecgs_TN_wxs_fq
outputs:
- id: tumor_wxs_output_bam
  outputSource: align_tumor_wxs/output_bam
  secondaryFiles:
  - ^.bai
  type: File
- id: normal_wxs_output_bam
  outputSource: align_normal_wxs/output_bam
  secondaryFiles:
  - ^.bai
  type: File
requirements: []
steps:
- id: align_tumor_wxs
  in:
  - id: sample
    source: sample
    valueFrom: $(self).WXS.T
  - id: cpu
    source: cpu
  - id: fq_1
    source: tumor_wxs_fq_1
  - id: fq_2
    source: tumor_wxs_fq_2
  - id: known_sites
    source: known_sites
  - id: reference
    source: reference
  - id: flowcell
    source: wxs_tumor_flowcell
  - id: lane
    source: wxs_tumor_lane
  - id: index_sequencer
    source: wxs_tumor_index_sequencer
  - id: library_preparation
    source: wxs_tumor_library_preparation
  - id: platform
    source: wxs_tumor_platform
  label: align_tumor_wxs
  out:
  - id: output_bam
  run: ../../submodules/align-dnaseq/cwl/align_dnaseq.cwl
- id: align_normal_wxs
  in:
  - id: sample
    source: sample
    valueFrom: $(self).WXS.N
  - id: cpu
    source: cpu
  - id: fq_1
    source: normal_wxs_fq_1
  - id: fq_2
    source: normal_wxs_fq_2
  - id: known_sites
    source: known_sites
  - id: reference
    source: reference
  - id: flowcell
    source: wxs_normal_flowcell
  - id: lane
    source: wxs_normal_lane
  - id: index_sequencer
    source: wxs_normal_index_sequencer
  - id: library_preparation
    source: wxs_normal_library_preparation
  - id: platform
    source: wxs_normal_platform
  label: align_normal_wxs
  out:
  - id: output_bam
  run: ../../submodules/align-dnaseq/cwl/align_dnaseq.cwl