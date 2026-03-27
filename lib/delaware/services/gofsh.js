// Import necessary modules from the gofsh library
const { getFhirProcessor, getResources, writeFSH, ensureOutputDir, loadExternalDependencies, FHIRDefinitions, stats, getRandomPun } = require('gofsh').utils;
const fs = require('fs');
const path = require('path');

// Function to display results in a styled format
function displayResults(pkg) {
  const proNum = pkg.profiles.length.toString().padStart(18);
  const extNum = pkg.extensions.length.toString().padStart(17);
  const logNum = pkg.logicals.length.toString().padStart(18);
  const resNum = pkg.resources.length.toString().padStart(18);
  const vsNum = pkg.valueSets.length.toString().padStart(17);
  const csNum = pkg.codeSystems.length.toString().padStart(18);
  const instNum = pkg.instances.length.toString().padStart(18);
  const invNum = pkg.invariants.length.toString().padStart(17);
  const mapNum = pkg.mappings.length.toString().padStart(18);
  const aliasNum = pkg.aliases.length.toString().padStart(18);
  const errNumMsg = `${stats.numError} Error${stats.numError !== 1 ? 's' : ''}`.padStart(12);
  const wrnNumMsg = `${stats.numWarn} Warning${stats.numWarn !== 1 ? 's' : ''}`.padStart(12);
  const wittyMessage = getRandomPun(stats.numError, stats.numWarn).padEnd(37);

  const results = [
    '╔═════════════════════════ GoFSH RESULTS ═════════════════════════╗',
    '║ ╭────────────────────┬───────────────────┬────────────────────╮ ║',
    '║ │      Profiles      │    Extensions     │      Logicals      │ ║',
    '║ ├────────────────────┼───────────────────┼────────────────────┤ ║',
    `║ │ ${proNum} │ ${extNum} │ ${logNum} │ ║`,
    '║ ╰────────────────────┴───────────────────┴────────────────────╯ ║',
    '║ ╭────────────────────┬───────────────────┬────────────────────╮ ║',
    '║ │     Resources      │     ValueSets     │     CodeSystems    │ ║',
    '║ ├────────────────────┼───────────────────┼────────────────────┤ ║',
    `║ │ ${resNum} │ ${vsNum} │ ${csNum} │ ║`,
    '║ ╰────────────────────┴───────────────────┴────────────────────╯ ║',
    '║ ╭────────────────────┬───────────────────┬────────────────────╮ ║',
    '║ │     Instances      │    Invariants     │      Mappings      │ ║',
    '║ ├────────────────────┼───────────────────┼────────────────────┤ ║',
    `║ │ ${instNum} │ ${invNum} │ ${mapNum} │ ║`,
    '║ ╰────────────────────┴───────────────────┴────────────────────╯ ║',
    '║ ╭────────────────────┬───────────────────┬────────────────────╮ ║',
    '║ │      Aliases       │                   │                    │ ║',
    '║ ├────────────────────┼───────────────────┼────────────────────┤ ║',
    `║ │ ${aliasNum} │                   │                    │ ║`,
    '║ ╰────────────────────┴───────────────────┴────────────────────╯ ║',
    '║                                                                 ║',
    '╠═════════════════════════════════════════════════════════════════╣',
    `║ ${wittyMessage} ${errNumMsg} ${wrnNumMsg} ║`,
    '╚═════════════════════════════════════════════════════════════════╝'
  ];

  results.forEach(line => console.log(line));
}

// Main function to convert FHIR resources to FSH
async function convertToFSH(inputDir, outputDir) {
  try {
    console.log(`Converting FHIR resources from ${inputDir} to FSH in ${outputDir}`);

    // Resolve input and output directories
    const resolvedInputDir = path.resolve(inputDir);
    const resolvedOutputDir = path.resolve(outputDir);

    // Ensure the input directory exists
    if (!fs.existsSync(resolvedInputDir)) {
      throw new Error(`Input directory does not exist: ${resolvedInputDir}`);
    }

    // Ensure the output directory exists
    const finalOutputDir = ensureOutputDir(resolvedOutputDir);

    // Load FHIR definitions
    const defs = new FHIRDefinitions();
    await defs.initialize();

    // Load the FHIR processor
    const processor = await getFhirProcessor(resolvedInputDir, defs, 'json-only');

    // Process the resources and generate a Package object
    const processingOptions = {
      indent: true, // Whether to indent the output
      alias: true // Generate aliases
    };
    const config = processor.processConfig();
    await loadExternalDependencies(defs, config);

    const pkg = await getResources(processor, config, processingOptions);

    // Write the FSH files to the output directory
    writeFSH(pkg, finalOutputDir, 'file-per-definition');

    // Display results
    displayResults(pkg);

    console.log('FSH conversion completed successfully!');
    console.log(`FSH files written to: ${finalOutputDir}`);
  } catch (error) {
    console.error('Error converting FHIR to FSH:', error.message);
    process.exit(1); // Exit with an error code
  }
}

// Get input and output directories from command-line arguments
const [inputDir, outputDir] = process.argv.slice(2);

if (!inputDir || !outputDir) {
  console.error('Usage: node gofsh.js <inputDir> <outputDir>');
  process.exit(1);
}

// Run the conversion
convertToFSH(inputDir, outputDir);
