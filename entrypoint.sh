#!/bin/bash -l

# Future CLI options
# --output-dir (default ..)
# --output-c-dir (default ../hamr/c)
# --sel4-output-dir (default ../microkit)
# --run-transpiler (default true)
# --bit-width (default 32)
# --max-string-size (default 256)
# --max-array-size (default 1)
# --verbose (default false)
# --workspace-root-dir (default .)
# --runtime-monitoring (default true)

echo "aadl-dir: $1"
echo "platform: $2"
echo "package-name: $3"

# Since this is in the containerized Sireum, we know the paths
export SIREUM_HOME=/Sireum
SIREUM_HOME_BIN=${SIREUM_HOME}/bin
OSATE_BIN=${SIREUM_HOME_BIN}/linux/fmide/fmide

if [[ -n $1 ]]; then
	AADL_DIR=${GITHUB_WORKSPACE}/$1
else
	AADL_DIR=${GITHUB_WORKSPACE}
fi
echo "AADL_DIR = ${AADL_DIR}"

if [[ -n $2 ]]; then
	PLATFORM=$2
else
	PLATFORM=Microkit
fi
echo "PLATFORM = ${PLATFORM}"

if [[ -n $1 ]]; then
	PACKAGE_NAME=${GITHUB_WORKSPACE}/$1
else
	PACKAGE_NAME=${GITHUB_WORKSPACE}
fi
echo "PACKAGE_NAME = ${PACKAGE_NAME}"

# TODO: if aadl dir is parent not accessable, problem
OUTPUT_DIR="$(dirname "$AADL_DIR")"
OUTPUT_C_DIR=${OUTPUT_DIR}/hamr/c
OUTPUT_SEL4_DIR=${OUTPUT_DIR}/microkit

OSIREUM_CMD=(${OSATE_BIN} -nosplash --launcher.suppressErrors -data ${AADL_DIR} -application org.sireum.aadl.osate.cli)

if [ "XX ${PLATFORM}" = 'XX Microkit' ]; then
	OSIREUM_CMD+=(hamr codegen --platform ${PLATFORM} --output-dir ${OUTPUT_DIR})
else
	OSIREUM_CMD+=(hamr codegen --platform ${PLATFORM} --package-name ${PACKAGE_NAME} --output-dir ${OUTPUT_DIR})
	OSIREUM_CMD+=(--output-c-dir ${OUTPUT_C_DIR} --sel4-output-dir ${OUTPUT_SEL4_DIR})
	OSIREUM_CMD+=(--run-transpiler --bit-width 32 --max-string-size 256 --max-array-size 1)
fi
OSIREUM_CMD+=(--verbose --workspace-root-dir ${AADL_DIR})

if [ "XX $PLATFORM" = 'XX "JVM"' ]; then
	OSIREUM_CMD+=(--runtime-monitoring)
else
	echo "Note: runtime-monitoring support is not yet avialable for ${PLATFORM}"
fi

# For now, do not assume we wish to exclude component impl
# OSIREUM_CMD+=(exclude-component-impl)

if [ -f "$OUTPUT_DIR/hamr/slang/.idea" ]; then
	OSIREUM_CMD+=(--no-proyek-ive)
fi

# Finally, add the system definition file
OSIREUM_CMD+=(${AADL_DIR}/.system)
echo "=== .system ==="
cat ${AADL_DIR}/.system
echo "=== .system ==="

# Previous versions needed to remove the HAMR.aadl file
# echo "Removing HAMR.aadl as that conflicts with the one contributed by the HAMR OSATE plugin"
# rm -f ${AADL_DIR}/HAMR.aadl
echo "Removing CASE_Scheduling.aadl as that conflicts with the one contributed by the HAMR OSATE plugin"
rm -f ${AADL_DIR}/CASE_Scheduling.aadl

echo "OSIREUM_CMD = ${OSIREUM_CMD[@]}"
RESULTS=$(xvfb-run -e /dev/stdout -s "-screen 0 1280x1024x24 -ac -nolisten tcp -nolisten unix" "${OSIREUM_CMD[@]}" 2>&1)
EXIT_CODE=$?

echo "EXIT_CODE = ${EXIT_CODE}"
echo "RESULTS = ${RESULTS}"

# echo "timestamp=$(date)" >> $GITHUB_OUTPUT
# echo "status=${EXIT_CODE}" >> $GITHUB_OUTPUT
echo "status-messages=${RESULTS}" >> $GITHUB_OUTPUT

##############################

#// proc"git checkout HAMR.aadl".at(aadlDir).runCheck()
#// println("Restored HAMR.aadl")
git config --global --add safe.directory /home/runner/work
pushd ${AADL_DIR} && git checkout CASE_Scheduling.aadl && popd
echo "Restored CASE_Scheduling.aadl"

# Add the generated code to the git index, commit, and push
pushd ${AADL_DIR}
git config --global --add user.name "HAMR-Codegen"
git config --global --add user.email "HAMR-Codegen"
git add microkit
git commit -m "HAMR-Codegen from ${git_branch}.${git_hash}"
#git push
popd

#// Running under windows results in 23 which is an indication 
#// a platform restart was requested. Codegen completes 
#// successfully and the cli app returns 0 so 
#// not sure why this is being issued.
#if(results.exitCode == 0 || results.exitCode == 23) {
#  Os.exit(0)
#} else {
#  println(results.err)
#  Os.exit(results.exitCode)
#}

#############################

#exitStatus=1
#analysisStatus=$(jq .status $4)
#echo "analysisStatus: $analysisStatus"
#if [ "XX $analysisStatus" = 'XX "Analysis Completed"' ]; then
#	claimsTrue=$(jq "[.results[] | .status] | all" $4)
#	if [ "XX $claimsTrue" = 'XX "true"' ]; then
#		exitStatus=0
#	fi
#fi

echo "EXIT_CODE: $EXIT_CODE"
exit $EXIT_CODE
