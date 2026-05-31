module.exports = {
  default: {
    paths: ['features/**/*.feature'],
    import: ['features/step_definitions/**/*.ts'],
    format: ['progress'],
    publishQuiet: true,
  },
};
