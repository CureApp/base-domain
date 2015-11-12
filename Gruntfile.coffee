module.exports = (grunt) ->

    grunt.config.init

        mochaTest:
            options:
                reporter: 'spec'
                require: [
                    'espower-coffee/guess'
                    'coffee-script/register'
                    'spec/export-globals.js'
                ]

            spec:
                src: [
                    'spec/lib/*.coffee'
                    'spec/util.coffee'
                    'spec/master-data-resource.coffee'
                    'spec/fixture.coffee'
                ]

            single:
                src: [
                    grunt.option('file') ? 'spec/base-repository.coffee'
                ]


        yuidoc:
            options:
                paths: ['src']
                syntaxtype: 'coffee'
                extension: '.coffee'
            master:
                options:
                    outdir: 'doc'


        coffee:
            dist:
                expand: true
                cwd: 'src'
                src: ['**/*.coffee']
                dest: 'dist/'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true

            uglify_test:
                expand: true
                cwd: 'test/uglify-js/coffee'
                src: ['**/*.coffee']
                dest: 'test/uglify-js/build'
                ext: '.js'
                extDot: 'first'
                options:
                    bare: true


        copy:
            uglify_test:
                expand: true
                cwd: 'test/uglify-js/coffee'
                src: ['**/!(*.coffee)']
                dest: 'test/uglify-js/build'


        uglify:
            test:
                files:
                    'test/uglify-js/build/domain.min.js': 'test/uglify-js/build/**/*.js'



    grunt.loadNpmTasks 'grunt-mocha-test'
    grunt.loadNpmTasks 'grunt-contrib-yuidoc'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-copy'

    grunt.registerTask 'default', 'mochaTest:spec'
    grunt.registerTask 'single', 'mochaTest:single'
    grunt.registerTask 'build', ['coffee:dist']
    grunt.registerTask 'uglify-test', ['coffee:uglify_test', 'copy:uglify_test', 'uglify:test']
