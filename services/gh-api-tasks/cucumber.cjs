module.exports = {
  default: {
    paths: ['features/**/*.feature'],
    import: ['features/step_definitions/**/*.ts'],
    format: ['progress-bar', 'html:reports/cucumber-report.html'],
    requireModule: ['tsx/cjs'],
  },
};
