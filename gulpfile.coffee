gulp = require 'gulp'
coffee = require 'gulp-coffee'
Promise = require 'bluebird'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-istanbul'
del = require 'del'

sources =
  js: 'lib/**/*.js'
  coffee: 'src/**/*.coffee'
  test:
    unit: 'test/**/*.unit.coffee'
    integrationTest: 'test/**/*.integration.coffee'
    systemTest: 'test/system.coffee'

sources.test.all = (value for key, value of sources.test)

forceEnd = ->
  process.nextTick ->
    process.exit 0

gulp.task 'clean', (callback) ->
  del [sources.js], callback

gulp.task 'lint', ->
  return gulp.src sources.coffee
  .pipe coffeelint()
  .pipe coffeelint.reporter()
  .pipe coffeelint.reporter 'fail'

gulp.task 'compile', ->
  return gulp.src(sources.coffee)
  .pipe coffee({ bare: true })
  .pipe gulp.dest('lib/')

gulp.task 'watch', ['compile'], ->
  return gulp.watch sources.coffee, ['compile']

gulp.task 'unitTest', ['compile'], ->
  return gulp.src sources.test.unit
  .pipe mocha()

gulp.task 'test', ['compile'], ->
  return gulp.src sources.test.all
  .pipe mocha()
  .on 'end', forceEnd
  
gulp.task 'cover', ['compile'], ->
  return gulp.src sources.js
  .pipe istanbul()
  .pipe istanbul.hookRequire()
  .on 'finish', ->
    return gulp.src sources.test.all
    .pipe mocha()
    .pipe istanbul.writeReports()
    .on 'end', forceEnd
    
gulp.task 'build', ['clean', 'lint', 'cover']
