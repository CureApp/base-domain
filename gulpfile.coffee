gulp   = require 'gulp'
coffee = require 'gulp-coffee'
yuidoc = require 'gulp-yuidoc'
uglify = require 'gulp-uglify'

gulp.task 'build', ['coffee', 'copy']


gulp.task 'coffee', ->

    gulp.src 'src/**/*.coffee'
        .pipe(coffee bare: true)
        .pipe(gulp.dest 'dist')


gulp.task 'copy', ->
    gulp.src 'src/**/!(*.coffee)'
        .pipe(gulp.dest 'dist')


gulp.task 'yuidoc', ->

    gulp.src ['src/**/*.coffee']
        .pipe(yuidoc({
            syntaxtype: 'coffee'
            project:
                name: 'base-domain'
        }))
        .pipe(gulp.dest('doc'))
        .on('error', console.log)


gulp.task 'uglify-copy', ->
    gulp.src 'test/uglify-js/coffee/**/!(*.coffee)'
        .pipe(gulp.dest 'test/uglify-js/build')

gulp.task 'uglify-test', ['uglify-copy'], ->

    gulp.src 'test/uglify-js/coffee/**/*.coffee'
        .pipe(coffee bare: true)
        .pipe(uglify())
        .pipe(gulp.dest 'test/uglify-js/build')


module.exports = gulp
