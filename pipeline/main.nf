#!/usr/bin/env nextflow
// hash:sha256:f076d0d9bc773a7d28baccf566bd3f9e323006eebf552ab6aaf66ebc1c45f481

nextflow.enable.dsl = 1

params.reference_url = 's3://codeocean-public-data/genomes/saccharomyces_genome'

reference_to_star_alignment_1 = channel.fromPath(params.reference_url + "/*", type: 'any')

// capsule - STAR Alignment
process capsule_star_alignment_1 {
	tag 'capsule-5332793'
	container "registry.apps-edge.acmecorp.codeocean.dev/published/a0bb341b-6091-468f-8665-2c9a30a065c0:v1"

	cpus 1
	memory '8 GB'

	publishDir "$RESULTS_PATH", saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/' from reference_to_star_alignment_1

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=a0bb341b-6091-468f-8665-2c9a30a065c0
	export CO_CPUS=1
	export CO_MEMORY=8589934592

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	git clone --branch v1.0 "https://apps-edge.acmecorp.codeocean.dev/capsule-5332793.git" capsule-repo
	mv capsule-repo/code capsule/code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run ${params.capsule_star_alignment_1_args}

	echo "[${task.tag}] completed!"
	"""
}
